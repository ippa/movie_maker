require 'rubygems'
require 'hoe'
require File.dirname(__FILE__) + '/lib/movie_maker.rb'

include MovieMaker

Hoe.plugin :git
Hoe.spec "movie_maker" do
  developer "ippa", "ippa@rubylicio.us"
  self.readme_file   = 'README.rdoc'
  self.rubyforge_name = "movie_maker"
  self.version = MovieMaker::VERSION
end

desc "Build a working gemspec"
task :gemspec do
  system "rake git:manifest"
  system "rake debug_gem | grep -v \"(in \" | grep -v \"erik\" > movie_maker.gemspec"
end
