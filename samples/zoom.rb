#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker

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

duration = 1000
@ttf_sprites.each_with_index do |sprite, index|
	offset = index * duration
	movie.between(offset, offset+duration).zoom(sprite, :scale_from => 5, :scale_to => 0.1).after.play_sound(Sound["hit.wav"])
end
movie.play(4000)
