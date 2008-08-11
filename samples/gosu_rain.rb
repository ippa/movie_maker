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
		(1..100).each do |nr|
			x = rand(800)
			start_at = nr / 20.0
			stop_at = nr / 20.0 + 1
	
			@movie.between(start_at, stop_at).move(Sprite.new("raindrop.png"), :from => [x,0], :to => [x,650])
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


