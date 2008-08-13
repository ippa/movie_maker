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
		0.upto(20) do |start|
			@red = Sprite.new("red_triangle.png")
			@green = Sprite.new("green_triangle.png")
			@blue = Sprite.new("blue_triangle.png")
			stop = start + 5
			
			#@movie.between(start, stop).resource(@red).move(:from => [0,0], :to => [800,650]).rotate(:angle => 1000).zoom(:scale_from => 0.1, :scale_to => 2)
			#@movie.between(start, stop).resource(@red).move_to([800,650]).rotate(1000).zoom(0.1, 2)
			
			@movie.between(start, stop).move(@red, :from => [0,0], :to => [800,650]).rotate(@red, :angle => 1000).zoom(@red, :scale_from => 0.1, :scale_to => 2)
			@movie.between(start, stop).move(@green, :from => [800,0], :to => [0,650]).rotate(@green, :angle => 1000).zoom(@green, :scale_from => 0.1, :scale_to => 2)
			@movie.between(start, stop).move(@blue, :from => [800,600], :to => [0,0]).rotate(@blue, :angle => 1000).zoom(@blue, :scale_from => 0.1, :scale_to => 2)
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


