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
		(0..10).each do |nr|
			start_at = nr * 2
			stop_at = nr * 2 + 10
	
			@movie.between(start_at, stop_at).move(Sprite.new("red_triangle.png"), :from => [0,0], :to => [800,650])
			@movie.between(start_at, stop_at).move(Sprite.new("blue_triangle.png"), :from => [800,0], :to => [0,650])
			@movie.between(start_at, stop_at).move(Sprite.new("green_triangle.png"), :from => [800,600], :to => [0,0])
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


