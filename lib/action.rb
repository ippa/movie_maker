#
# One Action specifies a certain action, for example the movement of a sprite
# Or to show a sprite, rotate, zoom or hide etc
#
#
module MovieMaker
	#module Action
		#
		# All actions inherit from this base-class and Should call super in their initialize.
		# Takes an option-hash: 
		# :start_at - start at X millisec into the movie
		# :stop_at - stop at X millisec into the movie
		# :sprite - the actuall spriteobject, needs to answer to x,x=,y,y= and image
		# :screen - the screenobject, so it knows where to blit itself
		# :background - the backgroundsurface so it can undraw itself properly
		#
		#
		class SpriteAction
			attr_accessor :sprite, :background, :screen
			attr_reader :start_at, :stop_at, :image
			def initialize(options = {})
				@sprite = options[:object]
				@background = options[:background]
				@screen = options[:screen]
				@start_at = (options[:start_at]||0) * 1000
				@stop_at = (options[:stop_at]||0) * 1000
				@duration = @stop_at - @start_at
				@image = @sprite.image
			end
			
			def started?(current_time)
				current_time >= self.start_at
			end

			def playing?(current_time)
				(current_time >= self.start_at) && (current_time < self.stop_at)
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
				
				@sprite.x = @from_x
				@sprite.y = @from_y
				
				setup
			end
			
			def setup
				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f				
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				time -=  self.start_at
				@sprite.x = @from_x + time * @x_step
				@sprite.y = @from_y + time * @y_step
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
				
				setup
			end
			
			def setup
				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f				
				@sprite.angle = 360 - (Math.atan(@y_step / @x_step) * 180.0/Math::PI) + 90
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				time -=  self.start_at
				@sprite.x = @from_x + time * @x_step
				@sprite.y = @from_y + time * @y_step
			end
			
		end

		#
		# ROTATE
		#
		class Rotate < SpriteAction
			attr_reader :direction
			def initialize(options = {})
				super
				@to_angle = options[:angle]
				@direction = options[:direction] || :clockwise
				#@cache = options[:cache] || false
				
				setup
			end
			
			def setup
				@angle_step = @to_angle.to_f / @duration.to_f
				
				#
				# Fill the cache with all angles
				#
				#if @cache
				#	(0..360).each do |angle|
				#		@image.rotozoom_cached(angle, [1,1], true, @sprite.file)
				#	end
				#end
			end
			
			def update(time)
				time -= self.start_at
				@sprite.angle = (@angle_step * time)	if @direction == :counterclockwise
				@sprite.angle = (-@angle_step * time)	if @direction == :clockwise				
			end
			
		end

		#
		# PULSATE
		#
		class Pulsate < SpriteAction
			attr_reader :direction
			def initialize(options = {})
				super
				@pulse_duration = options[:duration]
				@times = options[:times] || 1		
				setup
			end
			
			def setup
				@angle_step = @to_angle.to_f / @duration.to_f
			end
			
			def update(time)
				time -= self.start_at
				@sprite.angle = (@angle_step * time)	if @direction == :counterclockwise
				@sprite.angle = (-@angle_step * time)	if @direction == :clockwise				
			end
			
		end

		# Zoom a sprite
		class Zoom < SpriteAction
			
			def initialize(options = {})
				super
				@scale_from = options[:scale_from] || 1
				@scale_to = options[:scale_to] || 2
				@scale = (@scale_from - @scale_to).abs
				setup
			end
			
			def setup
				@scale_step = @scale.to_f / @duration.to_f
				@scale_step = -@scale_step 	if	@scale_to < @scale_from
				@scale_total = @scale_from
			end
			
			def update(time)
				time -= self.start_at
				scale = @scale_from + @scale_step * time
				@sprite.width_scaling = scale
				@sprite.height_scaling = scale
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
				@start_at = (options[:start_at]||0) * 1000
				@stop_at = (options[:stop_at]||0) * 1000
				@duration = @stop_at - @start_at
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
				@volume = options[:volume] || 1.0
				@repeats = options[:repeats] || 1
				@fade_in = options[:fade_in] || nil
				@stop_after = @duration				
				@sound.volume = @volume
				@playing = false
			end
			
			def started?(current_time)
				current_time > self.start_at
			end

			def playing?
				@playing
			end
						
			def play
				@sound.play
				@playing = true
			end
			
			def stop
				@sound.stop
			end
			
		end
		
	#end
end