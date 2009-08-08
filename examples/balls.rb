#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0)
@background = Surface.autoload("cloth_background.png")

movie = Movie.new(:screen => @screen, :background => @background)
movie.resource(Sprite.new("ball.png")).move([100,100]).between(0,6).move([600,100])
movie.resource(Sprite.new("ball.png")).move([100,200]).between(1,6).move([600,200])
movie.resource(Sprite.new("ball.png")).move([100,300]).between(2,6).move([600,300])
movie.resource(Sprite.new("ball.png")).move([100,400]).between(3,6).move([600,400])
movie.resource(Sprite.new("ball.png")).move([100,500]).between(4,6).move([600,500])
movie.play