#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0, [HWSURFACE, DOUBLEBUF])
movie = Movie.new(:screen => @screen, :background => Color[:black])

#
# generate 5 seconds of rain, each raindrop moving from top to bottom in 1 second (1000ms), 50ms between each drop.
#
(1..100).each do |nr|
	x = rand(800)
	start_at = nr * 50
	stop_at = nr*50 + 1000
	
	@raindrop = Sprite.new("raindrop.png")	
	movie.between(start_at, stop_at).move(@raindrop, :from => [x,0], :to => [x,650])
end

movie.play