#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker

Rubygame.init()
Surface.autoload_dirs = [ "media" ]
	
@screen = Screen.set_mode([800, 600], 0)
@background = Surface.autoload("cloth_background.png")

movie = Movie.new(:screen => @screen, :background => @background)
movie.between(0,6).move(Sprite.new("ball.png"), :from => [100,100], :to => [600,100])
movie.between(1,6).move(Sprite.new("ball.png"), :from => [100,200], :to => [600,200])	
movie.between(2,6).move(Sprite.new("ball.png"), :from => [100,300], :to => [600,300])	
movie.between(3,6).move(Sprite.new("ball.png"), :from => [100,400], :to => [600,400])	
movie.between(4,6).move(Sprite.new("ball.png"), :from => [100,500], :to => [600,500])	

movie.play