#!/usr/bin/env ruby
require File.join("..", "rubygame_movie_maker")
require 'base.rb'

class GameWindow < Gosu::MovieMakerWindow
	def initialize
		super
		setup_movie
	end
	
	def setup_movie
		@movie = Movie.new(:framework => :gosu, :screen => $screen)
		
		start_at = stop_at = 0
		(1..500).each do |nr|
			x = rand(800)
			start_at = nr / 50.0
			stop_at = nr / 50.0 + 1.0
	
			@raindrop = Sprite.new("raindrop_small.png")
			@movie.resource(@raindrop).move([x,0]).between(start_at, stop_at).move_facing_direction([x+100+(nr/5)+rand(50),650])
		end
		@movie.at(0).play_sound(Sample["rain2.wav"])
	end
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu	# Among others add sprites image to global $screen
	GameWindow.new.show
end


