#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), 'lib')
['rubygems','gosu','rubygame'].each do |gem|
	require gem
end

['action','sprite','core_extensions', 'gosu_clock'].each do |lib|
	require File.join(File.dirname(__FILE__), 'lib', lib)
end

#
# MovieMaker
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
module MovieMaker

	class Movie

		
		attr_accessor :actions
		attr_reader :screen, :background, :clock, :updated_count, :stop_at
		
		#
		# Takes an options-hash as argument:
		# :screen	=> the screen to draw on 
		# :target_framerate => what framerate should it aim for, defaults to 60
		# :background => Color or Imageinstance
		# :framework	=> :rubygame (default) or :gosu
		#
			
		def initialize(options = {})
			@screen = options[:screen] || nil
			@framework = options[:framework] || :rubygame	# this can also be :gosu
			@target_framerate = options[:target_framerate] || 100
			@background = options[:background] || nil
			if options[:background].kind_of? ::Rubygame::Color::ColorRGB
				@background = Surface.new(@screen.size)
				@background.draw_box_s([0,0],[@screen.width,@screen.height], options[:background])
			end
				
			@actions = []
			@onetime_actions = []
			@update_actions = []
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
			
			# Convert all start_at's filled with :now to current timestamp (meaning they'll start .. "now")
			@actions.each do |action|
				action.start_at = @clock.lifetime	if action.start_at.is_a? Symbol and action.start_at == :now
			end
			
			setup
				
			while @clock.lifetime < @movie_stop_at
				@tick = @clock.tick()
				
				title = "[framerate: #{@clock.framerate.to_i}] [Spriteupdates last tick: #{@updated_count}]"
				
				if @framework == :rubygame
					@screen.title = title 
					rubygame_update(@clock.lifetime)	
				else
					@screen.caption = title
					gosu_update(@clock.lifetime)
					gosu_draw(@clock.lifetime)
				end
					
				yield	 if block_given?
			end
		end
			
		#
		# Starts the clock which time will be sent to all events update()'s
		# Also paint a background, if any.
		#
		def setup
			@clock = ::Gosu::Clock.new
			@clock.target_framerate = @target_framerate
			if @framework == :rubygame
				@background.blit(@screen, [0, 0])	if @background
				@screen.update
			end
		end
		
		def playing?(current_time)
			current_time <= stop_at 
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

			#@onetime_actions.select { |action| !action.playing?(current_time) and action.started?(current_time) }.each do |action|
			@onetime_actions.select { |action| action.started?(current_time) and !action.finalized?}.each do |action|
				action.finalize
			end
			
			dirty_rects = []
			# Only undraw/update actions that are active on the timeline
			@update_actions.select { |action| action.playing?(current_time) }.each do |action|
				dirty_rects << @background.blit(@screen, action.sprite.rect, action.sprite.rect) 
				action.update(current_time)
				#puts "update(#{current_time}): #{action.start_at} - #{action.stop_at}" + action.class.to_s
				@updated_count += 1
				
				#
				# Rotozoom lies here because of 2 reasons:
				# - Action can't do the actual imagemanipulation since Gosu does it drawtime
				# - By moving it out of the action, we can have more then 1 action manipulting rotozoom parameeters
				#
				if action.sprite.angle != 0 || action.sprite.width_scaling != 1 || action.sprite.height_scaling != 1
					
					action.sprite.image = action.image.rotozoom(	action.sprite.angle, 
																												[action.sprite.width_scaling, action.sprite.height_scaling],
																												true)
					action.sprite.realign_center
				end
			end
				
			@update_actions.select { |action| action.started?(current_time) }.each do |action|
				dirty_rects << action.sprite.image.blit(@screen, action.sprite.rect)
			end
				
			@screen.update_rects(dirty_rects)
		end
			
		#
		# gosu_update - GOSU specific updateloop
		#
		def gosu_update(current_time)
			@updated_count = 0

			@onetime_actions.select { |action| action.started?(current_time) and !action.finalized? }.each do |action|
				#puts "onetime action: #{action.start_at} - #{action.stop_at}" + action.class.to_s
				action.finalize
			end
				
			@update_actions.select { |action| action.playing?(current_time) }.each do |action|
				#puts "update(#{current_time}): #{action.start_at} - #{action.stop_at}" + action.class.to_s
				action.update(current_time)	
				@updated_count += 1
			end
				
		end
		#
		# gosu_update - GOSU specific updateloop
		#
		def gosu_draw(current_time)
			@background.draw(0, 0, 0)	if	@background
			@update_actions.select { |action| action.started?(current_time) }.each do |action|
				action.sprite.image.draw_rot(	action.sprite.x, 
																			action.sprite.y, 
																			1, 
																			action.sprite.angle, 0.5, 0.5, 
																			action.sprite.width_scaling, 
																			action.sprite.height_scaling, 
																			action.sprite.color,
																			:additive)
			end
		end
			
			
		#
		# Stops/resets the movie- NOT YET IMPLEMENTED
		#
		def stop
		end
			
		#
		# Pauses the movie, which should resume with a call to play() - NOT YET IMPLEMENTED
		#
		def pause
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
		def method_missing(method, *args)
			
			## ".move" (the string) ==> Move.new (the class)
			klass = MovieMaker::Action.const_get(camelize(method))
			
			options = { :start_at => @start_at, 
									:stop_at => @stop_at,
									:screen => @screen,
									:background => @background,
									:object => @resource,
									:framework => @framework || :rubygame
								}
												
			standard_args = []
			args.each do |arg|
				if arg.is_a? Hash
					options.merge!(arg)
				else
					standard_args << arg
				end
			end
			
			
			action = klass.new(options, *standard_args)
			#puts "ACTION: #{action.class} - #{standard_args}"
			
			@actions << action
			#
			# Separate actions that needs 1-time trigger
			#
			if @resource.kind_of? Sound or @stop_at == @start_at
				@onetime_actions << action
			#
			# And thoose who needs constant update/drawing
			#
			else
				@update_actions << action
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
			@stop_at = start_at
			self
		end

		#
		# Start following action right away and specify how long is should run
		#
		def during(length)
			if @stop_at==0
				@start_at = :now
			else
				@start_at = @stop_at
			end
			
			@stop_at = @stop_at + length
			self
		end
			
		#
		# Start following action after the last one finishes
		#
		# Example:
		# @movie.between(0,1).move(@stone, :from => [0,0], :to => [0,400]).then.play_sound(@crash)
		#
		def then
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
		
		#
		# Sprite/Sound/Resource selection
		#
		def resource(resource)
			@resource = resource
			@start_at = 0
			@stop_at = 0
			self
		end
		alias :sprite :resource
		alias :sound :resource

	end
end

#
# Test the MovieMaker class, a first crude spec
# This code will change alot as I use it as a quick way of testing various new stuff out.
#
if $0 == __FILE__
	include MovieMaker						# A must for actions to work
	include Rubygame							# for easy access to rubygame stuff
	include MovieMaker::Rubygame	# for easy access to moviemakers special rubygamesprites
	
	Surface.autoload_dirs = [ File.join("samples", "media"), "media" ]
	Sound.autoload_dirs = [ File.join("samples", "media"), "media" ]
	
	@screen = Screen.set_mode([800, 600], 0)
	@background = Surface.autoload("outdoor_scene.png")
	
	movie = Movie.new(:framework => :rubygame,
										:screen => @screen,
										:background => @background,
										:target_framerate => 200)
	
	(0..2).each do |nr|
		@spaceship = Sprite.new("spaceship_noalpha.png")

		## New style!
		movie.resource(@spaceship).between(0,4).move([400+rand(300),rand(350)]).rotate(360).then.play_sound(Sound["hit.wav"])
		
	end
	movie.play(:stop_at => 5)
end