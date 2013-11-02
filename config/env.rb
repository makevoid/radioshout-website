# econding: utf-8

path = File.expand_path '../../', __FILE__
APP = "riotvan"

require "bundler/setup"
Bundler.require :default
module Utils
  def require_all(path)
    Dir.glob("#{path}/**/*.rb") do |model|
      require model
    end
  end
end
include Utils

require "#{path}/lib/monkeypatches"


env = ENV["RACK_ENV"] || "development"

FIVEAPI_HOST = if env == "development"
  "localhost:3000"
  # "fiveapi.com"
else
  "fiveapi.com"
end

# DataMapper.setup :default, "mysql://localhost/riotvan_#{env}"
require_all "#{path}/models"
# DataMapper.finalize

## TODO: move in lib

# Morpher

# usage:
#
#   # view (haml)
#   
#   - palinsesto = File.open("views/palinsesto.textile", "r:UTF-8").read
#   = morph_html RedCloth.new(palinsesto).to_html}
#

# rb

module Morpher
  def morph_html(html)
    doc = Nokogiri::HTML html
    doc.search("td").each do |td|
      if td.inner_text.strip == "x"
        td['class'] = "program"
        td.content = ""
      elsif td.inner_text =~ /®/
        td['class'] = "replica"
      elsif td.inner_text =~ /♪/ || td.inner_text =~ /:(.+)-(.+):/
        # do nothing for now:  ♪
      else
        td['class'] = "program"
      end
    end
    doc.to_html
  end
end

include Morpher

