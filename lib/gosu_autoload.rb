#
# Rubygames Named Resources for GOSU
# Assumes a global variable $screen having the Gosu::Window instance.
# Quick 'n easy access to sprites, sounds and tiles!
#
begin
	require 'named_resource'	# Part of rubygame 2.3+
rescue
	require 'rubygame'
end

class Image
	include Rubygame::NamedResource
	
	def self.autoload(name)
		(path = find_file(name)) ? Gosu::Image.new($screen, path, true) : nil
	end
end
Surface = Image

class Sample
	include Rubygame::NamedResource
	
	def self.autoload(name)
		(path = find_file(name)) ? Gosu::Sample.new($screen, path) : nil
	end
end
Sound = Sample

class Tile
	include Rubygame::NamedResource
	
	def self.autoload(name)
		(path = find_file(name)) ? Gosu::Image.load_tiles($screen, path, 32, 32, true) : nil
	end
end