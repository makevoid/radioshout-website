# encoding: utf-8

require 'bundler/setup'
Bundler.require :default

class Selenium::WebDriver::Wait
  DEFAULT_TIMEOUT = 5
end


class Radioshout < Sinatra::Base

  @@path = File.expand_path "../", __FILE__


  ROOT = 'http://localhost:3001'
  html = ""
  # Headless.ly do


  def get_url(path="/")
    html = ""
    Headless.ly do
      driver = Selenium::WebDriver.for :firefox
      driver.navigate.to "#{ROOT}#{path}"
      # puts driver.title
      # sleep 1
      wait = Selenium::WebDriver::Wait.new #timeout: 5
      wait.until { driver.find_element id: "fiveapi_loaded" }
      # wait.until { driver.find_element css: ".img_box" }

      # html = driver.page_source
      # sleep 0.5
      html = driver.page_source
    end
    html
  end

  get "/" do
    get_url "/"
  end

  get "/eventi" do
    get_url "/eventi"
  end

  # get "/*" do
  #   pass if request.path_info =~ /\.(js|css|sass|haml|ttf|otf|woff|eof|png|ico)$/
  #   get_url request.path_info
  # end
end