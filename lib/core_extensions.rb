module Rubygame
	class Surface
	
		def rotozoom_cached(angle, zoom, smooth=true, file="default")
			@@rotozoom_cached_surfaces ||= {}
			@@rotozoom_cached_surfaces[file] ||= []
			key = angle.to_i.abs
			
			## DEBUG
			#puts "[#{file}][#{key}]: HIT"	if @@rotozoom_cached_surfaces[file][key]
			#puts "[#{file}][#{key}]: MISS"	if !@@rotozoom_cached_surfaces[file][key]
			
			@@rotozoom_cached_surfaces[file][key] ||= self.rotozoom(angle, zoom, smooth)
		end

	end
end