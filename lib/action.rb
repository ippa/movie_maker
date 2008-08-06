#
# One Action specifies a certain action, for example the movement of a sprite
# Or to show a sprite, rotate, zoom or hide etc
#
#
module Rubygame
	module MovieMaker
		#
		# All actions inherit from this base-class and Should call super in their initialize.
		# Takes an option-hash: 
		# :start_at - start at X millisec into the movie
		# :stop_at - stop at X millisec into the movie
		# :sprite - the actuall spriteobject, needs to answer to x,x=,y,y= and image
		# :screen - the screenobject, so it knows where to blit itself
		# :background - the backgroundsurface so it can undraw itself properly
		# 
		# Provides 2 basic methods: draw and undraw
		#
		class SpriteAction
			attr_accessor :sprite, :background, :screen, :x, :y
			attr_reader :start_at, :stop_at
			def initialize(options = {})
				@sprite = options[:object]
				@background = options[:background]
				@screen = options[:screen]
				@start_at = options[:start_at]
				@stop_at = options[:stop_at]
				@duration = (@stop_at||0) - (@start_at||0)
			end
			
			# Actually blit the sprite onto the screen
			def draw
				@sprite.image.blit(@screen, @sprite.rect)
			end
			
			# undraw the sprite by blitting the background over it
			def undraw
				@background.blit(@screen, @sprite.rect, @sprite.rect)
			end
	
		end
		
		#
		# Moves a sprite from X,Y --> X2,Y2
		#
		class Move < SpriteAction
		
			def initialize(options = {})
				super
				@from = options[:from]
				@to = options[:to]
				@from_x = @from[0]
				@from_y = @from[1]
				@to_x = @to[0]
				@to_y = @to[1]
				
				@x = @from_x
				@y = @from_y
				
				setup
			end
			
			def setup
				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f				
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				@sprite.rect.centerx = @from_x + time * @x_step
				@sprite.rect.centery = @from_y + time * @y_step
			end
			
		end

		#
		# Moves a sprite from X,Y --> X2,Y2
		#
		class MoveFacingDirection < SpriteAction
		
			def initialize(options = {})
				super
				@from = options[:from]
				@to = options[:to]
				@from_x = @from[0]
				@from_y = @from[1]
				@to_x = @to[0]
				@to_y = @to[1]
				
				@image = @sprite.image
				setup
			end
			
			def setup
				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f				
				@angle = 360 - (Math.atan(@y_step / @x_step) * 180.0/Math::PI) + 90
				@sprite.image = @image.rotozoom(@angle,[1,1], true)
				old_center = @sprite.rect.center
				@sprite.rect.size = @sprite.image.size
				@sprite.rect.center = old_center
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				@sprite.rect.centerx = @from_x + time * @x_step
				@sprite.rect.centery = @from_y + time * @y_step
			end
			
		end

		# Rotate a sprite
		class Rotate < SpriteAction
			def initialize(options = {})
				super
				@angle = options[:angle]
				@direction = options[:direction] || :clockwise
				@image = @sprite.image
				setup
			end
			
			def setup
				@angle_step = @angle.to_f / @duration.to_f
				@angle_total = 0
			end
			
			def update(time)
				@sprite.image = @image.rotozoom(@angle_total, [1,1], true)	if @direction == :counterclockwise
				@sprite.image = @image.rotozoom(-@angle_total, [1,1], true)	if @direction == :clockwise
				@angle_total = @angle_step * time
				
				old_center = @sprite.rect.center
				@sprite.rect.size = @sprite.image.size
				@sprite.rect.center = old_center
			end
			
		end
		
		# Zoom a sprite
		class Zoom < SpriteAction
			
			def initialize(options = {})
				super
				@scale_from = options[:scale_from]
				@scale_to = options[:scale_to]
				@image = @sprite.image
				@scale = ((@scale_from||1) - (@scale_to||2)).abs
				setup
			end
			
			def setup
				@scale_step = @scale.to_f / @duration.to_f
				@scale_step = -@scale_step if	@scale_to < @scale_from
				
				@scale_total = @scale_from
			end
			
			def update(time)
				@sprite.image = @image.rotozoom(0, [@scale_total, @scale_total], true)
				@scale_total = @scale_from + @scale_step * time
				
				old_center = @sprite.rect.center
				@sprite.rect.size = @sprite.image.size
				@sprite.rect.center = old_center
			end
			
		end


		# Shows a sprite
		class Show < SpriteAction
			def initialize(options = {})
				super
			end
			
			def update(time)
			end
		end

		# Fades a sprite 
		class Fade < SpriteAction
		
			def initialize(options = {})
				super
				@from = options[:from]
				@to = options[:to]
				@alpha = 255
			end
			
			def update(time)
				@sprite.image.set_alpha(@alpha)
				@alpha -= 1	if @alpha > 0
			end
		end


		#
		#
		#
		class SimpleAction			
			attr_reader :start_at, :stop_at
			def initialize(options = {})
				@start_at = options[:start_at]
				@stop_at = options[:stop_at]
				@duration = (@stop_at||0) - (@start_at||0)
			end
		end

		#
		# Plays a sound
		#
		class PlaySound < SimpleAction
			attr_reader :playing
			def initialize(options = {})
				super
				@sound = options[:object]
				@playing = false
			end
			
			def play
				@sound.play
				@playing = true
			end
			
			def stop
				@sound.stop
			end
			
		end
		
	end
end