#!/usr/bin/env ruby
require File.join("..", "rubygame_movie_maker")
require 'gosu_base.rb'

class GameWindow < Gosu::MovieMakerWindow
	def initialize
		super
		setup_movie
	end
	
	def setup_movie
		@movie = Movie.new(:framework => :gosu, :screen => $screen, :draw_mode => :additive, :loop => true)
		0.upto(40) do |nr|		
			@star = Sprite.new("star_6.png", :x => rand(800), :y => -10)
			color = Color.new(0x66484D18)
			flash = Color.new(0xFFFFFFFF)
			
			@start = nr/4.0
			zoom = 0.1+rand(0)/5
			
			# this resource will follow through all steps bellow
			@movie.resource(@star)
			
			# setup (before a between)
			@movie.zoom(zoom).color(color)
			
			# the "movie" (resource is still choosen)
			@movie.between(@start, @start+10).velocity([0,1.2+rand(0)/5]).rotate(200-rand(400))
		
			# A falling star
			if rand(10) == 0
				@movie.at(@start+2+rand(4)).zoom(zoom+0.3).color(flash).during(1).rotate(720).zoom(0.01).fade_out
			end
		end
		
		@movie.restart_at(@start)
		
	end
	
end

if $0 == __FILE__
	include MovieMaker
	include MovieMaker::Gosu
	GameWindow.new.show
end


