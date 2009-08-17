# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{movie_maker}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ippa"]
  s.date = %q{2009-08-17}
  s.description = %q{Automate image movements/effects and sounds over a period of time, useful for games.}
  s.email = ["ippa@rubylicio.us"]
  s.extra_rdoc_files = ["History.txt"]
  s.files = ["History.txt", "README.rdoc", "Rakefile", "examples/axe.rb", "examples/balls.rb", "examples/echoes.rb", "examples/gosu_base.rb", "examples/gosu_rain.rb", "examples/gosu_river_of_stars.rb", "examples/gosu_triangles.rb", "examples/gosu_wish_upon_a_star.rb", "examples/ippagaming_intro.rb", "examples/media/23700__hazure__chop.wav", "examples/media/Establo.ttf", "examples/media/FeaturedItem.ttf", "examples/media/FreeSans.ttf", "examples/media/Hursheys.ttf", "examples/media/axe.png", "examples/media/axe.svg", "examples/media/ball.png", "examples/media/ball.svg", "examples/media/black.bmp", "examples/media/blue_triangle.png", "examples/media/blue_triangle.svg", "examples/media/chop.wav", "examples/media/cloth_background.png", "examples/media/drawing.svg", "examples/media/drip.wav", "examples/media/green_triangle.png", "examples/media/green_triangle.svg", "examples/media/hit.wav", "examples/media/ippa_gaming.png", "examples/media/ippa_gaming.svg", "examples/media/oil_drip.wav", "examples/media/outdoor_scene.bmp", "examples/media/outdoor_scene.png", "examples/media/outdoor_scene.svg", "examples/media/rain-bak1.wav", "examples/media/rain.wav", "examples/media/rain2.wav", "examples/media/raindrop.png", "examples/media/raindrop.svg", "examples/media/raindrop_small.bmp", "examples/media/raindrop_small.png", "examples/media/red_triangle.png", "examples/media/red_triangle.svg", "examples/media/spaceship_noalpha.png", "examples/media/star_5.png", "examples/media/star_5.svg", "examples/media/star_6.png", "examples/media/star_6.svg", "examples/rain.rb", "examples/rain_advanced.rb", "examples/rubygame_river_of_stars.rb", "examples/zoom.rb", "lib/movie_maker.rb", "lib/movie_maker/action.rb", "lib/movie_maker/core_extensions.rb", "lib/movie_maker/gosu_autoload.rb", "lib/movie_maker/gosu_clock.rb", "lib/movie_maker/named_resource.rb", "lib/movie_maker/sprite.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ippa/movie_maker/tree/master}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{movie_maker}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Automate image movements/effects and sounds over a period of time, useful for games.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
