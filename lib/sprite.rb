module Rubygame
	module MovieMaker
	
		#
		# A basic spriteclass using rubygames Sprites::Sprite
		# Autoloads a surface and initializes @rect
		#
		class Sprite
			include Sprites::Sprite
			
			attr_reader :image
			attr_accessor :rect
			def initialize(file, x=0, y=0)
				super()
				@image = Surface.autoload(file)
				@rect = Rect.new(x,y,*@image.size)
				@image.set_colorkey(@image.get_at(0,0))
			end
			
		end
		
		#
		# TTRSprite creates a rubygame sprite from a string/font
		# Use this if you wanna move,rotate and zoom texts/letters
		#
		class TTFSprite
			include Sprites::Sprite
			
			attr_reader :image
			attr_accessor :rect
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
			end
			
		end
		
	end
end