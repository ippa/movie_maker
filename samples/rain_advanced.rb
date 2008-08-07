#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
Sound.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0, [HWSURFACE, DOUBLEBUF])
movie = Movie.new(:screen => @screen, :background => Color[:black])

start_at = stop_at = 0
(1..1000).each do |nr|
	x = rand(800)
	start_at = nr / 50.0
	stop_at = nr / 50.0 + 1.0
	
	@raindrop = Sprite.new("raindrop_small.png")
	movie.between(start_at, stop_at).move_facing_direction(@raindrop, :from => [x,0], :to => [x+100+(nr/5)+rand(50),650])
end
movie.between(0, stop_at).play_sound(Sound["rain2.wav"])
movie.play