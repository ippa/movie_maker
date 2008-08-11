#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'rubygame'
require File.join(File.dirname(__FILE__), 'lib', 'action')
require File.join(File.dirname(__FILE__), 'lib', 'sprite')
require File.join(File.dirname(__FILE__), 'lib', 'core_extensions')

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
			# :background => Color or Imageinstance
			# :framework	=> :rubygame (default) or :gosu
			#
			
			attr_accessor :actions
			attr_reader :screen, :background, :clock
			def initialize(options = {})
				@screen = options[:screen] || nil
				@framework = options[:framework] || :rubygame	# this can also be :gosu
				@target_framerate = options[:target_framerate] || 100
				@background = options[:background] || nil
				if options[:background].kind_of? Rubygame::Color::ColorRGB
					@background = Surface.new(@screen.size)
					@background.draw_box_s([0,0],[@screen.width,@screen.height], options[:background])
				end
					
				@actions = []
				@onetime_actions = []
				@sprites = {}
				@tick = @start_at = @stop_at = 0
			end
			
			#
			# Calculates the length of the movie by checking stop_at-times of all @actions that the movie consists of.
			#
			# TODO: 
			# - current the method at() doesn't provide at stop_at, which makes total_playtime fail
			#
			def stop_at
				@movie_stop_at ||= @actions.inject(0) { |time, action| action.stop_at > time ? action.stop_at : time }
			end
						
			#
			# Loops through the movie's full timeline and updates all the @actions 
			# This method blocks until the movie ends
			#
			# To play the movie Within your own gameloop, use update()
			#
			def play(options = {})
				@framework ||= options[:framework] || :rubygame    							# this can also be :gosu
				@movie_stop_at ||= options[:stop_at] ? options[:stop_at] * 1000.0 : stop_at
											
				setup
				
				while @clock.lifetime < @movie_stop_at
					rubygame_update(@clock.lifetime)
					@tick = @clock.tick()
					@screen.title = "[framerate: #{@clock.framerate.to_i}] [Spriteupdates last tick: #{@updated_count}]"
					yield	 if block_given?
				end
			end
			
			#
			# Starts the clock which time will be sent to all events update()'s
			# Also paint a background, if any.
			#
			def setup
				@clock = Clock.new
				@clock.target_framerate = @target_framerate
				@background.blit(@screen, [0, 0])	if @background
				@screen.update
			end
			
			#
			# rubygame_update() - Rubygame specific update
			# Rubygame specific include: blit, sprite rects, dirty_rects and update_rects
			#
			# - goes through all @actions and calls undraw/update/draw.
			# - goes through all @onetime_actions and calls play on them once.
			#
			# Several optimizations are possible here:
			# - sort @actions after start_at so update doesn't have to loop through all events each time
			#   only until start_at isn't lower then current_time anymore
			# - remove "played-out" actions from @actions
			# - remove "played-out" actions from @onetime_actions
			#
			#
			def rubygame_update(current_time)
				@updated_count = 0
				dirty_rects = []

				# Only undraw/update actions that are active on the timeline
				@actions.select { |action| action.playing?(current_time) }.each do |action|
					dirty_rects << @background.blit(@screen, action.sprite.rect, action.sprite.rect) 
					action.update(current_time)	
					@updated_count += 1
				end
				
				@actions.select { |action| action.started?(current_time) }.each do |action|
					dirty_rects << action.sprite.image.blit(@screen, action.sprite.rect)
				end
				
				@screen.update_rects(dirty_rects)
				
				@onetime_actions.select { |action| !action.playing? and action.started?(current_time) }.each do |action|
					action.play
				end
			end
			
			#
			# gosu_update - GOSU specific updateloop
			#
			def gosu_update(current_time)
				@updated_count = 0
				
				@background.draw(0, 0, 0)
				@actions.select { |action| action.started?(current_time) }.each do |action|
					action.update(current_time)	
					action.sprite.image.draw_rot(action.sprite.x, action.sprite.y, 1, 0)
					@updated_count += 1
				end
				
				@onetime_actions.select { |action| !action.playing? and action.started?(current_time) }.each do |action|
					action.play
				end
			end
			
			
			#
			# Stops/resets the movie
			# NOT YET IMPLEMENTED
			#
			def stop
			end
			
			#
			# Pauses the movie, which should resume with a call to play()
			# NOT YET IMPLEMENTED
			#
			def pause
			end
			
			#
			# Fix this to behave like a shortcut to between() or at()?
			#
			def []=(start_at, stop_at, action=nil)
				resource_name = start_at
				resource = stop_at
				if resource_name.is_a? Symbol
					@sprites[resource_name] = resource								if resource.is_a? Sprite
					@sprites[resource_name] = Sprite.new(resource)		if resource.is_a? String
				end
			end

			def [](resource_name)
				@sprites[resource_name.to_sym]
			end
	
						
			def add_action(action)
				@actions << action
			end
			
			#
			# Ripped from rails Inflector
			# Used to convert move()-calls to a new instance of class Move
			# and play_sound()-calls to a new instance of PlaySound .. etc.
			#
			def classify(table_name)
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
				klass = Kernel.const_get(camelize(method))
				
				object	= arg.first
				object = self[arg.first]	if arg.first.is_a? Symbol
				
				default_options = { :start_at => @start_at, 
														:stop_at => @stop_at,
														:screen => @screen,
														:background => @background,
														:object => object
													}
				options = arg[1] || {}
				options = default_options.merge(options)
				action = klass.new(options)
								
				#
				# Separate actions that needs 1-time trigger
				#
				if object.kind_of? Sound		
					@onetime_actions << action
				#
				# And thoose who needs constant update/drawing
				#
				else
					@actions << action
				end
				 
				self
			end

			#
			# Bellow are methods to time actions and make them chainable
			#
			
			#
			# Start following action start_at millisecs into the movie
			# .. and stop it stop_at millisecs into the movie.
			#
			def between(start_at, stop_at)
				@start_at = start_at
				@stop_at = stop_at
				self
			end
			
			#
			# Starts action at a start_time millisecs into the movie, no specific stop time
			#
			# Example:
			# @movie.at(2000).play_sound(@moo_sound)
			#
			def at(start_at)
				@start_at = start_at
				@stop_at = nil
				self
			end

			#
			# Start following action right away and specify how long is should run
			#
			def during(length)
				@start_at = @clock.lifetime	## this probably needs to be set when the movie Starts.
				@stop_at = length
				self
			end
			
			#
			# Start following action after the last one finishes
			#
			# Example:
			# @movie.between(0,1).move(@stone, :from => [0,0], :to => [0,400]).after.play_sound(@crash)
			#
			def after
				@start_at = @stop_at
				self
			end
			
			#
			# Start following action after the last one finishes + a millisecs delay argument
			#
			# Example:
			#
			# @movie.at(1).play_sound(@drip).delay(0.1).play_sound(@drip, {:volume => 0.5}).delay(0.1).play_sound(@drip, {:volume => 0.2})
			#
			def delay(time)
				@start_at = @stop_at||@start_at + time
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
	Rubygame.init
	Surface.autoload_dirs = [ File.join("samples", "media"), "media" ]
	Sound.autoload_dirs = [ File.join("samples", "media"), "media" ]
	
	@screen = Screen.set_mode([800, 600], 0)
	@background = Surface.autoload("outdoor_scene.png")
	#@background = Color[:black]
	
	movie = Movie.new(:framework => :rubygame, 
										:screen => @screen, 
										:background => @background, 
										:target_framerate => 200)
	
	(0..3).each do |nr|
		@spaceship = Sprite.new("spaceship_noalpha.png")
		movie.between(0, 4).move(@spaceship, :from => [0,rand(300)], :to => [400+rand(300),rand(350)])
		#movie.between(0, 4).rotate(@spaceship, :angle => 360, :direction => :clockwise, :cache => true)
	end
	movie.play
end