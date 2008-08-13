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
			def initialize(options = {}, *ignore)
				@sprite = options[:object]
				@background = options[:background]
				@screen = options[:screen]
				@start_at = (options[:start_at]||0) * 1000
				@stop_at = (options[:stop_at]||0) * 1000
				@cache = options[:cache] || false
				
				@duration = @stop_at - @start_at
				@playing = true
				@finalized = false
				@setup_done = false
				@image = @sprite.image # used in MovieMaker#play
			end
			
			def finalized?
				@finalized
			end
			
			def started?(current_time)
				current_time >= self.start_at
			end

			def playing?(current_time)
				@playing and (current_time >= self.start_at) and (current_time < self.stop_at)
			end
		end
		
		#
		# Moves a sprite to a set of coordinates
		#
		class Move < SpriteAction
		
			def initialize(options = {}, coordinates = [0,0])
				super(options)
				@to_x = coordinates[0]
				@to_y = coordinates[1]
			end
			
			def setup
				@from_x = @sprite.x
				@from_y = @sprite.y
				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f
				@setup_done = true
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				setup	unless @setup_done
				time -=  self.start_at
				@sprite.x = @from_x + time * @x_step
				@sprite.y = @from_y + time * @y_step
			end
			
			def finalize
				@sprite.x = @to_x
				@sprite.y = @to_y
				@finalized = true
			end
			
		end

		#
		# Moves a sprite from X,Y --> X2,Y2
		#
		class MoveFacingDirection < SpriteAction
		
			def initialize(options = {}, coordinates = [0,0])
				super(options)
				@to_x = coordinates[0]
				@to_y = coordinates[1]
			end
			
			def setup
				@from_x = @sprite.x
				@from_y = @sprite.y

				@x_step = (@to_x - @from_x).to_f / @duration.to_f
				@y_step = (@to_y - @from_y).to_f / @duration.to_f				
				@sprite.angle = 360 - (Math.atan(@y_step / @x_step) * 180.0/Math::PI) + 90
				@setup_done = true
			end
			
			# The core of the MoveClass, the actual move-logic
			def update(time)
				time -=  self.start_at
				setup	unless @setup_done
				
				@sprite.x = @from_x + time * @x_step
				@sprite.y = @from_y + time * @y_step
			end
			
			def finalize
				@finalized = true
			end
			
		end

		#
		# ROTATE
		#
		class Rotate < SpriteAction
			attr_reader :direction
			def initialize(options = {}, angle = 360)
				super(options)
				@angle = angle
			end
			
			def setup
				@angle_step = @angle.to_f / @duration.to_f
				@setup_done = true
			end
			
			def update(time)
				time -= self.start_at
				setup	unless @setup_done
				@sprite.angle = -(@angle_step * time)
			end
			
			def finalize
				@sprite.angle = @angle
				@finalized = true
			end
		end

		#
		# PULSATE
		#
		class Pulsate < SpriteAction
			attr_reader :direction
			def initialize(options = {})
				super(options)
				@pulse_duration = options[:duration] || 1
				@times = options[:times] || 1		
			end
			
			def setup
				@setup_done = true
			end
			
			def update(time)
				time -= self.start_at
				setup	unless @setup_done
			end
			
		end

		# Zoom a sprite
		class Zoom < SpriteAction
			
			def initialize(options = {}, factor = 1)
				super(options)
				@factor = factor
			end
			
			def setup
				@scale_from = @sprite.width_scaling || 1
				@scale = (@scale_from - @factor).abs

				@scale_step = @scale.to_f / @duration.to_f
				@scale_step = -@scale_step 	if	@factor < @scale_from
		
				@setup_done = true
			end
			
			def update(time)
				time -= self.start_at
				setup	unless @setup_done
	
				scale = @scale_from + @scale_step * time
				#puts "#{scale} = #{@scale_from} + #{@scale_step} * #{time}"
				@sprite.width_scaling = scale
				@sprite.height_scaling = scale
			end
			
			def finalize
				@sprite.width_scaling = @factor
				@sprite.height_scaling = @factor
				@finalized = true
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
		class FadeTo < SpriteAction
		
			def initialize(options = {})
				super(options)
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
			def initialize(options = {}, sound = nil)			
				super(options)
				@sound = sound || options[:object]
				@volume = options[:volume] || 1.0
				@repeats = options[:repeats] || 1
				@fade_in = options[:fade_in] || nil
				@stop_after = @duration				
				
				@sound.volume = @volume	if @sound.respond_to? :volume
			end
			
			def started?(current_time)
				current_time > self.start_at
			end

			def finalized?
				@finalized
			end

			def playing?(current_time)
				@playing
			end
						
			def finalize
				@sound.play
				@finalized = true
			end
			
			def stop
				@sound.stop
			end
			
		end
		
	#end
end