require 'json'

path = File.expand_path "../", __FILE__
@@path = path

routes = File.read "#{path}/public/routes.json"
routes = JSON.parse routes



def jshaml_to_rbhaml(content)
  # change js objects into ruby hashes
  regex = /(['"][\w-_]*?['"])\s*:\s(['"][\w-_]*?['"]|[\w.()-_]*?)/
  content.gsub!(regex, "\\1 => \\2")

  # remove haml. scope (dioboia)
  content.gsub!(/haml\./, '')

  content
end

# test_string = "asd asd { 'data-type': 'collection', 'data-name': \"radio\" } asd"
# puts jshaml_to_rbhaml test_string

exit

require 'haml'
require 'sinatra'

helpers do
  def location
    "loool?"
  end

  def location_article_id(location)
    request.path.split("/")[-1].split("-")[0]
  end
end


routes.each do |url, view|
  get url do
    content = File.read "#{@@path}/views/#{view}.haml"
    content = jshaml_to_rbhaml content

    haml content, layout: :layout_sinatra
    # haml view.to_sym, layout: :layout_sinatra
  end
end

