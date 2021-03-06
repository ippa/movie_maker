module MovieMaker
	module Rubygame
	
		#
		# A basic spriteclass using rubygames Sprites::Sprite
		# Autoloads a surface and initializes @rect
		#
		class Sprite
			include ::Rubygame::Sprites::Sprite
			
			attr_reader :image, :file
			attr_accessor :rect, :angle, :width_scaling, :height_scaling
			def initialize(file, x=0, y=0)
				super()
				@file = file
				@image = Surface.autoload(file)
				@rect = Rect.new(x,y,*@image.size)
				@image.set_colorkey(@image.get_at(0,0))
				@angle = 0.0
				@width_scaling = 1.0
				@height_scaling = 1.0
			end
			
			#
			# Rubygame X/Y setters/getters
			#
			def x=(value); 	@rect.centerx = value;	end
			def x;					@rect.centerx;					end
			def y=(value); 	@rect.centery = value;	end
			def y;					@rect.centery;					end
			
			def realign_center
				old_center = @rect.center
				@rect.size = @image.size
				@rect.center = old_center
			end
			
		end
		
		#
		# TTRSprite creates a rubygame sprite from a string/font
		# Use this if you wanna move,rotate and zoom texts/letters
		#
		class TTFSprite
			include ::Rubygame::Sprites::Sprite
			
			attr_reader :image
			attr_accessor :rect, :angle, :width_scaling, :height_scaling
			def initialize(string, options={})
				super()
				@string = string
				@color = options[:color] || Color[:black]
				@size = options[:size] || 15
				@position = options[:position] || [0,0]
				@fontname = options[:fontname] || "FreeSans.ttf"
				@font = options[:font] || nil
				
				if @font.nil?
					@font = TTF.new(File.join("fonts", @fontname), @size)
				end
				
				@rect = Rect.new(@position[0], @position[1], *@font.size_text(string))
				@image = Surface.new(@rect.size, 0, [SRCCOLORKEY])
				@font.render(@string, true, @color).blit(@image,[0,0])
				@image.set_colorkey(@image.get_at(0,0))
				
				@angle = 0.0
				@width_scaling = 1.0
				@height_scaling = 1.0
			end

			#
			# Rubygame X/Y setters/getters
			#
			def x=(value); 	@rect.centerx = value;	end
			def x;					@rect.centerx;					end
			def y=(value); 	@rect.centery = value;	end
			def y;					@rect.centery;					end

			def realign_center
				old_center = @rect.center
				@rect.size = @image.size
				@rect.center = old_center
			end
			
		end		
	end
	
	module Gosu
	
		#
		# A basic spriteclass using rubygames Sprites::Sprite
		# Autoloads a surface and initializes @rect
		#
		class Sprite			
			attr_reader :image, :file
			attr_accessor :x, :y, :angle, :width_scaling, :height_scaling, :color, :draw_mode
			def initialize(file, options = {})
				@x = options[:x] || 0
				@y = options[:y] || 0
				@draw_mode = options[:draw_mode] || :additive
				
				@file = file
				@image = Surface.autoload(@file)
				@angle = 0.0
				@width_scaling = 1.0
				@height_scaling = 1.0
				@color = ::Gosu::Color.new(0xffffffff)
			end
			
			# Only relevant with rubygame
			def realign_center
				nil
			end
			
		end
		
		#
		# Use this if you wanna move,rotate and zoom texts/letters
		#
		class TTFSprite
			attr_reader :image
			attr_accessor :x, :y, :angle, :width_scaling, :height_scaling, :color, :draw_mode
			def initialize(string, options={})
				@string = string
				@color = options[:color] || Color[:black]
				@size = options[:size] || 15
				@position = options[:position] || [0,0]
				@fontname = options[:fontname] || "FreeSans.ttf"
				@font = options[:font] || nil
				
				@x = options[:x] || @position[0]
				@y = options[:y] || @position[1]
				@draw_mode = options[:draw_mode] || :additive
				
				if @font.nil?
					@font = TTF.new(File.join("fonts", @fontname), @size)
				end
				
				@angle = 0.0
				@width_scaling = 1.0
				@height_scaling = 1.0
				@color = ::Gosu::Color.new(0xffffffff)
				#@rect = Rect.new(@position[0], @position[1], *@font.size_text(string))
				#@image = Surface.new(@rect.size, 0, [SRCCOLORKEY])
				#@font.render(@string, true, @color).blit(@image,[0,0])
			end

			# Only relevant with rubygame
			def realign_center
				nil
			end
			
		end		
	end

end