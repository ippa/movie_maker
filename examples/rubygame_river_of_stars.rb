#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0)
@background = Surface.autoload("cloth_background.png")

@movie = Movie.new(:screen => @screen, :background => Color[:black], :framework => :rubygame)
0.upto(20) do |start|
	@star = Sprite.new("star_5.png")	# x,y = 0,0 is default
	@movie.resource(@star)						# all following actions are applied to this resource
	#@movie.color( Color.new(100 + rand(155),rand(255),rand(255),rand(255)) )
	@movie.zoom(0.2)
	@movie.between(start/10.0, start/10.0 + 2)
	@movie.velocity([10,0])
	@movie.acceleration([0, 0.05 + rand(0.1)])
	@movie.rotate(angle = 90 * rand(10))
	@movie.zoom(1.0 + rand(2.0))
	@movie.then.color(0x00FFFFFF)
end

@movie.play