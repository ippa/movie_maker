#!/usr/bin/ruby
require File.join("..", "lib", "movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0)
@movie = Movie.new(:screen => @screen, :background => Color[:black], :target_framerate => 200)

#
# generate 5 seconds of rain, each raindrop moving from top to bottom in 1 second (1000ms), 50ms between each drop.
#
(1..100).each do |nr|
	x = rand(800)
	start_at = nr / 20.0
	stop_at = nr / 20.0 + 1
	
	@raindrop = Sprite.new("raindrop.png")	
	@movie.resource(@raindrop).move([x,0]).between(start_at, stop_at).move([x,650])
end

@movie.play