#!/usr/bin/ruby
require File.join("..", "rubygame_movie_maker")

include Rubygame
include MovieMaker
include MovieMaker::Rubygame

TTF.setup()
Rubygame.init()
Surface.autoload_dirs = [ "media" ]
Sound.autoload_dirs = [ "media" ]

@raindrop = Sprite.new("raindrop.png")
@drip = Sound["drip.wav"]
@screen = Screen.set_mode([800, 600], 0, [HWSURFACE])
@movie = Movie.new(:screen => @screen, :background => Color[:black], :target_framerate => 200)

@echo_delay = 0.4
#
# create 10 raindrops after eachother with echo soundeffects
#
(0..5).each do |nr|
	x = 100+rand(600)
	fall_time = 2
	start_at = nr * fall_time
	stop_at = nr * fall_time + fall_time
	@movie.between(start_at,stop_at).move(@raindrop, :from => [x, -100], :to => [x, 650])
	@movie.at(stop_at).play_sound(@drip.dup).delay(@echo_delay).play_sound(@drip.dup, :volume=>0.6).delay(@echo_delay).play_sound(@drip.dup,:volume => 0.3).delay(@echo_delay).play_sound(@drip.dup,:volume => 0.2)
end
@movie.play(:stop_at => 13)
