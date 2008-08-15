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
			
			@star = Sprite.new("star_5.png")	# x,y = 0,0 is default
			@movie.resource(@star)
			@movie.color( Color.new(100 + rand(155),rand(255),rand(255),rand(255)) )
			@movie.zoom(0.2)
			@movie.between(start/10.0, start/10.0 + 2)
			@movie.velocity([10,0])
			@movie.accelerate([0, 0.05 + rand(0.1)])
			@movie.rotate(angle = 90 * rand(10))
			@movie.zoom(1.0 + rand(2.0))
			@movie.fade_out.then.color(0x00FFFFFF)
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


