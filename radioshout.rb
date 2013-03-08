path = File.expand_path '../', __FILE__
PATH = path

require "#{path}/config/env.rb"

class RiotVan < Sinatra::Base
  include Voidtools::Sinatra::ViewHelpers

  #Haml::Options.defaults[:format] = :html5

  # partial :comment, { comment: "blah" }
  # partial :comment, comment

  before do
    headers "Access-Control-Allow-Origin" =>  "*"
  end

  not_found do
    haml :error_404
  end

  error do
    haml :error_500
  end

  def redirect_without_www
    redirect "http://#{request.host.sub(/^www./, '')}#{request.path}" if request.host =~ /^www./
  end

  before do
    redirect_without_www
  end


end