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

