= rubygame_movie_maker README

== What is it?
A class to make automate spritemovement / effects / sound over a timeline.
Rubygame solves all the heavy lifting for us when it comes to drawing on the screen.
movie_maker adds makes timing and setup of a scene esay. 

Use it for intros, ingame animations and simple "demos". Namingconventions tries to follow Rubygame.

== Features:
move, zoom, rotate, play_sound, show, fade 50% done.

So a bit limited atm. see samples/ dir for examples on how to use currently supported features.

== Use it for:
=== Intros
Build up your game with a intro 

=== ingame animations
You can make the movie play by calling update on it in your gameloop -- just like you do with your rubygame sprites/spritegroups. Note - this remains to be tested in an example.

=== Simple demos for your local demoparty


== Simple example
@sprite = Sprite.new("sprite.png")  # create your sprite (should include rubygames Sprites::Sprite)

# Sets up the movie, give it your initiated @screen-object and @background. MovieMaker supports autocreation of simple colored background as you can see bellow

@movie = Rubygame::MovieMaker.new(:screen => @screen, :background => Color[:black]) 

# 1 sec (1000ms) into the movie, start moving the sprite from x/y: 0,0 (top left of the screen)
# during 9 seconds (until 10000ms into the movie), set the speed so it will reach position x/y 800,600.
@movie.between(1000,10000).move(@sprite, :from => [0,0], :to =>[800,600])

# Play the movie you're created, blocks until it's done
@movie.play


== Chaining Simple example
movie_maker supports various chaining of actions, we could for example modify our last example like this:

# Between seconds 1-9, move the sprite across the screen, rotate it 360 degrees at the same time, and when it's done, play a sound woff. Without the ".after."-chaining the sound would have been played after 1 seconds, not 10.
@movie.between(1000,10000).move(@sprite, :from => [0,0], :to => [800,600]).rotate(@sprite, :angle => 360).after.play_sound(Sound[:woff])


== Requirements
Rubygame 2.3+

== License

Same as rubygame.
