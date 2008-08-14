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
		0.upto(200) do |start|
			
			@star_5 = Sprite.new("star_5.png")	# x,y = 0,0 is default
			@star_6 = Sprite.new("star_6.png")
			start = start / 10.0
			stop = start + 2
			angle = 90 * rand(10)
			downwards_acceleration = 0.05 + rand(0.1)
			zoom_from = 0.2
			zoom_to = 1.0 + rand(2.0)
			color = ::Gosu::Color.new(100 + rand(155),rand(255),rand(255),rand(255))
			
			@movie.resource(@star_5).color(color).zoom(zoom_from).between(start, stop).move([500,100]).accelerate([0,downwards_acceleration]).rotate(angle).zoom(zoom_to).then.color(0x000000)
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


