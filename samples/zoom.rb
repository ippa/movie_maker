#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

TTF.setup()
Rubygame.init()
Surface.autoload_dirs = [ "media" ]
Sound.autoload_dirs = [ "media" ]

@screen = Screen.set_mode([800, 600], 0, [HWSURFACE])
@font = TTF.new(File.join("media", "FeaturedItem.ttf"), 200)

@ttf_sprites = []
%w{I P P A}.each_with_index do |letter, index| 
	@ttf_sprites << TTFSprite.new(letter, :font => @font, :color => Color[:white], :position => [200+(index*100),100])
end

movie = Movie.new(:screen => @screen, :background => Color[:black])

@ttf_sprites.each_with_index do |sprite, index|
	movie.between(index, index+1).zoom(sprite, :scale_from => 5, :scale_to => 0.1).then.play_sound(Sound["hit.wav"])
end
movie.play(:stop_at => 6)
