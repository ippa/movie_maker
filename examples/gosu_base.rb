#!/usr/bin/env ruby
require File.join("..", "lib", "movie_maker")

#
# Usefull stuff for the Gosu examples
#
module Gosu
	class MovieMakerWindow < Gosu::Window
		def initialize
			$screen = super(800, 600, false)
			
			# Make Surface & Sound behave like shortcuts to GOSUs Image & Sample
			require 'gosu_autoload'
			
			# Set our autoloading dirs for quick and easy access to images and samples
			Surface.autoload_dirs = [ File.join("samples", "media"), "media" ]
			Sound.autoload_dirs = [ File.join("samples", "media"), "media" ]
	
			@clock = ::Gosu::Clock.new
			@clock.target_framerate = 200

			self
		end
	
		def update
			@tick = @clock.tick()
			
			#if @movie.playing?(@clock.lifetime)
				@movie.gosu_update(@clock.lifetime)
				self.caption = "[framerate: #{@clock.framerate.to_i}] [Spriteupdates: #{@movie.updated_count}] [#{@clock.lifetime} : #{@movie.stop_at}]"
			#else
			#	close
			#end
		end
		
		def draw
			@movie.gosu_draw(@clock.lifetime)
		end
	end
end
