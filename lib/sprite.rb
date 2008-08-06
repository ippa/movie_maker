module Rubygame
	module MovieMaker
	
		class Sprite
			include Sprites::Sprite
			
			attr_reader :image
			attr_accessor :x, :y, :rect
			def initialize(file, x=0, y=0)
				super()
				@image = Surface.autoload(file)
				@x = x
				@y = y
				@rect = Rect.new(@x,@y,*@image.size)
			end
			
		end
		
		class TTFSprite
			include Sprites::Sprite
			
			attr_reader :image
			attr_accessor :x, :y, :rect
			
			def initialize(string, options={})
				super()
				@string = string
				@color = options[:color] || Color[:black]
				@size = options[:size] || 15
				@position = options[:position] || [0,0]
				@x = @position[0]
				@y = @position[1]
				@fontname = options[:fontname] || "FreeSans.ttf"
				@font = options[:font] || nil
				
				if @font.nil?
					@font = TTF.new(File.join("fonts", @fontname), @size)
				end
				
				@rect = Rect.new(@x, @y, *@font.size_text(string))
				@image = Surface.new(@rect.size, 0, [SRCCOLORKEY])
				@font.render(@string, true, @color).blit(@image,[0,0])
			end
			
		end
		
	end
end