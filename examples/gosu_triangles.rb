#!/usr/bin/env ruby
require File.join("..", "lib", "movie_maker")
require 'gosu_base.rb'

class GameWindow < Gosu::MovieMakerWindow
	def initialize
		super
		setup_movie
	end
	
	def setup_movie
		@movie = Movie.new(:framework => :gosu, :screen => $screen)
		0.upto(5) do |start|
			
			@red = Sprite.new("red_triangle.png")
			@green = Sprite.new("green_triangle.png")
			@blue = Sprite.new("blue_triangle.png")
			stop = start + 4
						
			@movie.resource(@red).move([0,0]).zoom(0.1).between(start, stop).move([800,650]).rotate(1000).zoom(3).fade_out
			@movie.resource(@green).move([800,0]).zoom(0.1).between(start, stop).move([0,650]).rotate(1000).zoom(3).fade_out
			@movie.resource(@blue).move([800,600]).zoom(0.1).between(start, stop).move([0,0]).rotate(1000).zoom(3).fade_out
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


