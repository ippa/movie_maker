#!/usr/bin/ruby
require 'rubygems'
require 'rubygame'
require File.join(File.dirname(__FILE__), 'lib', 'action')
require File.join(File.dirname(__FILE__), 'lib', 'sprite')

#
# Rubygame::MovieMaker
# A class to make simple rubygamemovies (moving around sprites in a timed fashion, playing sounds etc)
# Rubygame solves all the heavy lifting for us when it comes to drawing on the screen.
# MovieMaker adds makes timing and setup of a scene esay. Use it for intros, ingame animations and simple "demos".
# Namingconventions tries to follow Rubygame.
#
# This class is responsible for:
#
# - Keeping track of actions (move, hide, show, play a sound etc)
# - Playing them according to userspecified timing (2 actions can start at the same time)
# - Keeping track of what sprite/surface to paint to, framerate etc
#
module Rubygame
	module MovieMaker
		class Movie
			#
			# Takes an options-hash as argument:
			# :screen	=> the screen to draw on 
			# :target_framerate => what framerate should it aim for, defaults to 60
			#
			
			attr_accessor :actions
			attr_reader :screen, :background, :clock, :timer
			def initialize(options = {})
				@actions = []
				@screen = options[:screen] || nil
				
				@background = options[:background] || nil
				if options[:background].kind_of? Rubygame::Color::ColorRGB
					@background = Surface.new(@screen.size)
					@background.draw_box_s([0,0],[@screen.width,@screen.height], options[:background])
				end
					
				@sprites = {}
				@target_framerate = options[:target_framerate] || 100
				@tick = 0
				@timer = 0
			end
			
			def total_playtime
				@actions.inject(0) { |time, action| action.stop_at > time ? action.stop_at : time }
			end
						
			def play(loop_until = nil)
				loop_until = total_playtime	if loop_until.nil?
				
				setup
				
				while @clock.lifetime < loop_until
					update(@clock.lifetime)
					@tick = @clock.tick()
					#@screen.title = "framerate: %d - lifetime: %d - currently updating %d objects" % [@clock.framerate, @clock.lifetime, @updated_count]
					yield	 if block_given?
				end
			end
			
			def setup
				@clock = Clock.new
				@clock.target_framerate = @target_framerate
				@background.blit(@screen, [0, 0])	if @background
			end
			
			def update(current_time)
				@updated_count = 0
				@actions.each do |action|
					if action.respond_to? :play
						action.play	if	current_time > action.start_at && !action.playing
					elsif current_time > action.stop_at
						action.draw						
					#
					# Only undraw/update/draw if action has started. 
					# compare global clock with actions start_at attribute!
					#
					elsif current_time > action.start_at && current_time < action.stop_at
						action.undraw
						action.update(current_time - action.start_at)
						action.draw
						@updated_count += 1
					end
				end
				@screen.flip
			end
			
			def stop
			end
			
			#
			# Various ways of adding actions to the movie timeline
			#
			def []=(start_at, stop_at, action=nil)
				resource_name = start_at
				resource = stop_at
				if resource_name.is_a? Symbol
					@sprites[resource_name] = resource								if resource.is_a? Sprite
					@sprites[resource_name] = Sprite.new(resource)		if resource.is_a? String
				#else
				#	action.target_surface = @screen
				#	action.background = @background
				#	action.surface.set_colorkey(action.surface.get_at(0,0))   # this needs to be more flexible
				#	action.start_at = start_at
				#	action.stop_at = stop_at
				#	@actions << action
				end
			end

			def [](resource_name)
				@sprites[resource_name.to_sym]
			end
	
			def between(start_at, stop_at)
				@start_at = start_at
				@stop_at = stop_at
				self
			end
			
			def at(start_at)
				@start_at = start_at
				@stop_at = nil
				self
			end

			def during(length)
				@start_at = @clock.lifetime	## this probably needs to be set when the movie Starts.
				@stop_at = length
				self
			end
			
			def after
				@start_at = @stop_at
				self
			end
			
			def add_action(action)
				@actions << action
			end
			
			# Ripped from rails Inflector
			def classify(table_name)
				# strip out any leading schema name
				camelize(singularize(table_name.to_s.sub(/.*\./, '')))
			end
			
			def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
				if first_letter_in_uppercase
					lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
				else
					lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
				end
			end
			
			#
			# Makes Object-initializing out of incomming missing actions
			# ie.  @movie.rotate(*arg) => Rotate.new(*arg)
			# This makes for standalone extendable actions, one class per action
			#
			# Ex. movie.between(0,2000).move(:ball, :from => [100,100], :to => [500,100])
			#
			def method_missing(method, *arg)
				#klass = Kernel.const_get(method.to_s.capitalize)
				klass = Kernel.const_get(camelize(method))
				
				sprite	= arg.first
				sprite = self[arg.first]	if arg.first.is_a? Symbol
				
				default_options = { :start_at => @start_at, 
														:stop_at => @stop_at,
														:screen => @screen,
														:background => @background,
														:object => sprite
													}
				options = arg[1] || {}
				options = default_options.merge(options)
				#puts options.inspect
				@actions << klass.new(options)				
				self
			end
		end
	end
end

#
# Test the MovieMaker class, a first crude spec
#
if $0 == __FILE__
	include Rubygame
	include MovieMaker
	Rubygame.init()
	Surface.autoload_dirs = [ File.join("samples", "media"), "media" ]
	Sound.autoload_dirs = [ File.join("samples", "media"), "media" ]
	
	#
	# 
	#
	@screen = Screen.set_mode([800, 600], 0)
	@background = Surface.autoload("outdoor_scene.png")
	@axe = Sprite.new("axe.png")
	@chop = Sound["chop.wav"]
	
	movie = Movie.new(:screen => @screen, :background => @background)
	movie.between(0, 2000).move(@axe, :from => [0,200], :to => [700,350])
	movie.between(0, 2000).rotate(@axe, :angle => 370*2, :direction => :clockwise)
	movie.at(2000).play_sound(@chop)
	
	#movie.between(0,1000).move(@ball, :from => [100,100], :to => [500,100])	
	#movie.between(1000,2000).move(@ball, :from => [500,100], :to => [500,500])
	#movie.between(2000,3000).move(@ball, :from => [500,500], :to => [100,500])
	#movie.between(3000,4000).move(@ball, :from => [100,500], :to => [100,100])
		
	movie.play(4000)
end