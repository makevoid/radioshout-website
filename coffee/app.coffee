g = window

$.ajaxSetup { cache: false }

$("body").on "sass_loadeds", ->
  # g.fivetastic.dev_mode() # comment this in production
  $("body").off "page_loaded"

  images_resize()
  setTimeout ->
    apply_markdown()
  , 200

  # $.get "http://jscrape.it/js/jscrape/jscrape.js", (data) ->
  #   eval data
  #
  # $.get "http://shoutcast.mixstream.net/js/status/usa7-vn:8012", (data) ->
  #   console.log data
  #   $("#stream .status").html data

  # megafix
  $("body").on "page_js_loaded", ->
    gal_build()
    $("#content").css({ opacity: 0 })
    $("#content").animate({ opacity: 1 }, 1000)
    images_resize()

    setTimeout ->
      apply_markdown()
    , 200
    setTimeout ->
      change_color()
    , 200

  setTimeout ->
    change_color("now")
  , 400

box_images = ->
  $(".article, .event").each (idx, article) ->
    article = $(article)
    link = article.find("h2 a").attr("href") || article.find("h3 a").attr("href")
    img = article.find("img")
    img.wrap("<div class='img_box'></div>")
    img.wrap("<a href='#{link}'></a>") if link

    # TODO:
    # $(".article img, .event img").imagesLoaded =>

    height = Math.max img.height(), 500
    console.log height
    article.find(".img_box").height height



# require_api = (api) ->
#   $.get "/fivetastic/api/lastfm.coffee", (coffee) ->
#     eval CoffeeScript.compile(coffee)
#
# # APIS: fb, lastfm, delicious, twitter
# require_api "lastfm"




apply_markdown = ->
  $(".markdown").each  ->
    name = $(this).data("name")
    $.get "/pages/#{name}.md", (data) =>
      # console.log data
      text = markdown.toHTML data
      $(this).html text

restore_gal = ->
  $("#img_gal img").css "opacity", 0
  $("#img_gal img:first-child").css "opacity", 1

cur_idx = 0


titles = []

gal_build = ->
  return unless @collection #&& @collection[0]["collection"] == "articoli"
  images = for article in @collection
    img = article.images[0]
    img.title = article.title if img
    img
  images = _(images).compact()
  $("#img_gal img").remove()
  titles = []
  for image in images
    titles.push image.title
    $("#img_gal").append("<img src='#{hostz}#{image.url}'>")
    $("#img_gal img").css({opacity: 0})
    $("#img_gal img:first").css({opacity: 1})
  $(".caption").html titles[cur_idx]

gal_anim = ->
  time = 5000
  # time = 1000
  gal_build() if $("#img_gal img").length < 1

  setTimeout =>
    images = _($("#img_gal img")).map (el) -> el
    cond = cur_idx >= images.length-1
    next_idx = if cond then 0 else cur_idx+1
    $(".caption").html titles[next_idx]
    $(images[cur_idx]).css "opacity", 0
    $(images[next_idx]).css "opacity", 1
    # console.log "hiding #{cur_idx}, showing #{next_idx}"
    cur_idx = if cond then 0 else cur_idx + 1

    gal_anim()
  , time


images_resize = ->
  $(".img_box")

  # setTimeout ->
  #   height = $("#img_gal").width() / 4 * 2.5
  #   $("#img_gal").height height
  # , 10

$(window).on "resize", ->
  images_resize()



########
# fiveapi

# $(document).ajaxSend (event, xhr, settings) ->
#   settings.xhrFields = { withCredentials: true }


unless window.console || console.log
  window.console = {}
  console.log = ->

puts = console.log

# models

# mollections

# collections

# views


# console.log hostz

if location.hostname == "localhost"
  # dev
  hostz = "localhost:3000"
  local = "localhost:3001"
else
  # prod
  hostz = "fiveapi.com"
  local = "radioshout.mkvd.net"

hostz = "http://#{hostz}"
local = "http://#{local}"

# articles_per_page = 6
articles_per_page = 18

# fiveapi requires jquery/zepto

$("body").on "page_loaded", ->
  hover_nav()

  $.get "#{hostz}/fiveapi.js", (data) ->
    eval data
    configs = {
      user: "radioshout",
      project: { radioshout: 2 },
      collections: {
        eventi: 6,
        programmi: 7,
        chi_siamo: 9,
        radio: 10,
        foto: 11,
        video: 12,
        audio: 13,
        articoli: 14,
        podcasts: 15,
      }
    }
    window.fiveapi = new Fiveapi( configs )
    fiveapi.activate()

    # default sort keys: published_at, id DESC

    # #TODO: debug code, remove in production
    # $("#fiveapi_edit").trigger "click"
    # fiveapi.start_edit_mode()
    # setTimeout ->
    #     $(".articles a").first().trigger "click"
    #   , 200

    # fiveapi.start_edit_mode()
    # setTimeout ->
    #     $(".articles a").first().trigger "click"
    #   , 200

    $(".nav img, .nav img span").hover ->
      $(this).parent().find("span").show()
    , ->
      $(this).parent().find("span").hide()

    $("body").on "got_collection2", ->
      gal_anim()
      $("body").off "got_collection2"

    $("body").on "got_collection", ->
      setTimeout ->
        box_images()
        gal_build()
      , 200

    setTimeout ->
      get_elements()
    , 100

    $("body").on "page_js_loaded", ->
      hover_nav()
      get_elements()


colors = {
  "/":            "rgba(179, 229, 230, 0.7)"
  #{}"/":            "rgba(78,  230, 173, 0.9)"
  "/la_radio":    "rgba(204, 155, 0,   0.9)",
  "/programmi":   "rgba(204, 155, 0,   0.9)",
  "/foto":        "rgba(204, 155, 0,   0.9)",
  "/palinsesto":  "rgba(204, 155, 0,   0.9)",
  "/podcasts":    "rgba(204, 155, 0,   0.9)",
  "/eventi":      "rgba(153, 153, 51,  0.9)",
  "/events":      "rgba(153, 153, 51,  0.9)",
  "/shout_world": "rgba(204, 102, 51,  0.9)",
  "/video":       "rgba(204, 102, 51,  0.9)",
  "/audio":       "rgba(204, 102, 51,  0.9)",
  "/articoli":    "rgba(204, 102, 51,  0.9)",
  "/chi_siamo":   "rgba(153, 153, 153, 0.9)",
  "/collabs":     "rgba(153, 153, 153, 0.9)",
  "/staff":       "rgba(153, 153, 153, 0.9)",
  "/arci":        "rgba(204, 204, 51, 0.9)"
}

hover_nav = ->
  # todo: selected state has to replace color dinamically
  $("#header nav a").removeClass("selected")
  $("#header nav a").each (idx, a) ->
    path = $(a).attr("href")
    if (location.pathname == path)
      $(a).addClass("selected")


change_color = (at) ->
  time = 300
  time = 0 if at == "now"

  last_elem = null

  # nav
  $("#header nav a").each (idx, a) ->
    path = $(a).attr("href")
    color = colors[path]
    $(a).animate({backgroundColor: color}, time)
    $(a).css({borderBottom: "1px solid #{color}"})

  # bg and hs
  path = "/#{location.pathname.split("/")[1]}"#
  color = colors[path]
  if color
    dark_color = $.xcolor.darken($.xcolor.darken($.xcolor.darken(color)))
    $("#inner_container h2, #inner_container h3, a.btn").animate({backgroundColor: dark_color}, time)
    $("#content_outer").animate({backgroundColor: color}, time)

g.change_color = change_color

load_vendors = ->
  # FIXME: rewrite with iced coffee || deferred get?
  $.get "/vendor/jquery-xcolor.js", (data) ->
    $.get "/vendor/jquery_imagesloaded.js", (data) ->
      eval data

load_vendors()


hamls = {}


bind_audio = (file_id) ->
  $("#audio_btn_#{file_id}").off "click"
  $("#audio_btn_#{file_id}").on "click", ->
    audio = $("#audio_#{file_id}").get(0)
    if audio.paused
      audio.play()
      $(this).html "||"
    else
      audio.pause()
      $(this).html ">"

audio_view = (file) ->
  url = "#{hostz}#{file.url}"
  "<audio id='audio_#{file.id}'> <source src='#{url}' type='audio/mp3'></source> </audio><div id='audio_btn_#{file.id}' class='audio_btns'>&gt;</div>"

file_view = (file) ->
  url = "#{hostz}#{file.url}"
  "<img src='#{url}' />"

write_images = (obj) =>
  for image in obj.images
    regex = new RegExp "\\[(file|image)_#{image.id}\\]"
    view = if image.name.match(/mp3/) then audio_view(image) else file_view(image)
    obj.text = obj.text.replace regex, view
    $("#audio_#{image.id}").available ->
      bind_audio image.id
    _.delay(bind_audio, 300, image.id)
  obj

write_videos = (text) ->
  # [youtube_2b_8yOZJn8A]
  text.replace /\[youtube_(.+)\]/, "<iframe src='http://www.youtube.com/embed/$1' allowfullscreen></iframe>"

markup = (obj) ->
  obj.text = markdown.toHTML obj.text
  obj = write_images obj
  obj.text = write_videos obj.text
  obj.text

singularize = (word) ->
  word.replace /s$/, ''

get_elements = ->
  get_article()
  per_page = if location.pathname == "/chi_siamo" ||  location.pathname ==  "/collabs"
    50
  else
    articles_per_page

  filters = { limit: per_page, offset: 0 }
  get_collection(filters)

render_pagination = (pag) ->
  total_pages = pag["entries_count"] / pag["limit"]
  current_page = pag["offset"]*pag["limit"]
  pages_view =  for i in [1..total_pages]
    "<a>#{i}</a>"
  pagination = "

    #{pages_view.join(" ")}

  "
  $(".pagination[data-collection=#{pag["collection"]}]").html(pagination)
  $(".pagination[data-collection=#{pag["collection"]}] a").on "click", ->
    page = $(this).html()-1
    limit = articles_per_page
    get_collection { limit: limit, offset: limit*page }

get_article = ->
  article_id = fiveapi.article_from_page()
  if article_id
    fiveapi.get_article article_id, (article) ->
      got_article article_id, article

get_collection = (filters={}) ->
  coll_name = fiveapi.collection_from_page()
  if coll_name
    fiveapi.get_collection coll_name, filters, (collection) ->
      filters.entries_count = collection["count"]
      filters.collection = coll_name
      render_pagination(filters)
      got_collection coll_name, collection["articles"]

load_haml = (view_name, callback) ->
  if hamls[view_name]
    callback hamls[view_name]
  else
    $.get "#{local}/views/#{view_name}.haml", (data) =>
      hamls[view_name] = data
      callback hamls[view_name]

render_haml = (view_name, obj={}, callback) ->
  # TODO: cache request
  obj.text = markup obj
  load_haml view_name, (view) =>
    html = haml.compileStringToJs(view) obj
    callback html

got_article = (id, article) ->
  view = "#{singularize article.collection}_article"
  render_haml view, article, (html) ->
    $(".fiveapi_element[data-type=article]").append html

got_collection = (name, collection) ->
  collection_elem = $(".fiveapi_element[data-type=collection]")
  collection_elem.html("")
  @collection = collection
  $("body").trigger "got_collection"
  $("body").trigger "got_collection2"
  _(collection).each (elem) ->
    render_haml name, elem, (html) ->
      collection_elem.append html


# helpers

haml.location_article_id = (location) ->
  _(location.pathname.split("/")).reverse()[0].split("-")[0]

haml.format_date = (date) ->
  date = new Date(date)
  "#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear()}"

haml.article_preview = (text) ->
  max_length = 520
  txt = text.split(/(<img.*?>)/)[1]
  if text.length > max_length
    # txt = text.split(/\[(file|image)_\d+\]/)[1]
    text = txt if txt
    "#{text.substring(0, max_length)}..."
  else
    text = txt if txt
    text