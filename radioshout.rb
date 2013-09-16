path = File.expand_path '../', __FILE__
PATH = path

require "#{path}/config/env.rb"

class Radioshout < Sinatra::Base
  include Voidtools::Sinatra::ViewHelpers

  @@path = PATH

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

  def render_fiveapi(output)
    dom = Nokogiri::HTML output
    elem = dom.search(".fiveapi_element").first
    if elem
      type = elem["data-type"]
      if type == "collection"
        output = render_collection dom, elem
      else
        output = render_article dom, elem
      end
    end

    output
  end

  def render_collection(dom, elem)
    name = elem["data-name"]
    content = Collection.get name
    unless content
      puts "ERROR: collection #{name} not found, proceeding anyway..."
      return dom.inner_html 
    end
    content = content.map do |cont|
      "<div><h2>#{cont[:title]}</h2><p>#{cont[:text]}</p></div>"
    end
    elem.inner_html = content.join(" ")
    dom.inner_html
  end

  def render_article(dom, elem)
    article_id = elem["data-id"]
    article = Article.get article_id.to_i
    if article
      elem.content = article[:text]
    else  
      elem.content = "Article not found"
    end
    dom.inner_html
  end

  def jshaml_to_rbhaml(content)
    # change js objects into ruby hashes
    regex = /(['"][\w_-]*?['"])\s*:\s(['"][\w_-]*?['"]|[\w.)(_-]*?)/
    content.gsub!(regex, "\\1 => \\2")

    # remove haml. scope (dioboia)
    content.gsub!(/haml\./, '')

    content
  end

  # serve cors views

  Dir.glob("#{PATH}/views/*.haml").each do |view|
    name = File.basename view
    get "/views/#{name}" do
      send_file "#{PATH}/views/#{name}"
    end
  end

  # serve static routes (yay seo!)

  def self.load_routes
    routes = File.read "#{@@path}/public/routes.json"
    JSON.parse routes
  end

  @@routes = load_routes
  @@routes.each do |url, view|
    get url do
      content = File.open "#{@@path}/views/#{view}.haml", "r:UTF-8"
      content = jshaml_to_rbhaml content

      output = haml content, layout: :layout_sinatra
      output = render_fiveapi output
      output
      # haml view.to_sym, layout: :layout_sinatra
    end
  end

  # standard routes

  get "/" do
    @articles = Collection.get :articoli
    # haml :index
    haml :index_sinatra, layout: :layout_sinatra
  end

  # helpers

  def partial(name, value={})
    locals = if value.is_a? Hash
      value
    else
      hash = {}; hash[name] = value
      hash
    end
    haml name.to_sym, locals: locals
  end


  helpers do
    def location
      "loool?"
    end

    def location_article_id(location)
      request.path.split("/")[-1].split("-")[0]
    end
  end

  helpers do
    # def location_article_id
    #   request.path.split("/")[-1].split("-")[0]
    # end

    def request_host
      if request.port != 80
        request.host_with_port
      else
        request.host
      end
    end

    MONTHS = %w(_ gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre)

    def date_formatted
      date.strftime "%d #{month} <span class='year'>%Y</span>"
    end

    def format_date(date, type=:long)
      date = Date.parse date
      month = MONTHS[date.month].capitalize
      date_format = case type
        when :long  then "%d #{month} %Y"
        when :short then "%d/%m/%y"
      end
      date.strftime date_format
    end

    def article_preview(text)
      text = text.gsub /\[picasa_(\d+)\]/, ''
      max_length = 520
      if text.length > max_length
        txt = text.split(/\[(file|image)_(\d+)\]/)
        text = "[file_#{txt[2]}] #{txt[3]}" if txt
        "#{text[0..max_length]}..."
      else
        text
      end
    end
  end


end