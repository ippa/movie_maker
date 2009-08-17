#!/usr/bin/ruby
require File.join("..", "lib", "movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
Sound.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([1024, 768], 0, [HWSURFACE, DOUBLEBUF])
movie = Movie.new(:screen => @screen, :background => Color[:white])

#
# Not finished yet
#
@ippa_gaming = Sprite.new("ippa_gaming.png")
@black = Sprite.new("black.bmp")
movie.between(1,3).fade(@ippa_gaming)
movie.between(1,3).show(@ippa_gaming)

movie.play
