#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
Sound.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0, [HWSURFACE, DOUBLEBUF])
@background = Surface.autoload("outdoor_scene.bmp")
@axe = Sprite.new("axe.png")
@chop = Sound["chop.wav"]

movie = Movie.new(:screen => @screen, :background => @background)
#
# Monsterline that demonstrates moviemakes chaining
#
# OLD: movie.between(0, 2).move(@axe, :from => [0,200], :to => [700,350]).rotate(@axe, :angle => 370*2, :direction => :clockwise).after.play_sound(@chop)

movie.resource(@axe).move([0,200]).between(0, 2).move([700,350]).rotate(370*2).then.play_sound(@chop)
movie.play(:stop_at => 4)