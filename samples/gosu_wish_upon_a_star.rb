#!/usr/bin/env ruby
require File.join("..", "rubygame_movie_maker")
require 'gosu_base.rb'

class GameWindow < Gosu::MovieMakerWindow
	def initialize
		super
		setup_movie
	end
	
	def setup_movie
		@movie = Movie.new(:framework => :gosu, :screen => $screen)
		0.upto(100) do |nr|		
			@star = Sprite.new("star_6.png")
			color = Color.new(0x33F8ED38)
			flash = Color.new(0x88FFFFFF)
			x = rand(800)
			start = nr/4.0
			zoom = 0.2+rand(0)/5
			
			@movie.resource(@star)																	# this resource will follow through all steps bellow
			@movie.zoom(zoom).move([x,0]).color(color)							# setup (before a between)
			@movie.between(start, start+7).move([x,700]).rotate(200-rand(400))	# the "movie" (resource is still choosen)
			if rand(10) == 0 # A falling star
				@movie.at(start+2+rand(4)).zoom(zoom+0.3).color(flash).during(1).rotate(720).zoom(0.01).fade_out
			end
		end
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


