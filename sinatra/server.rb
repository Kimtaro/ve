require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'rack/cors'

require File.expand_path(File.dirname(__FILE__) + "/../lib/ve")

use Rack::Cors do
  allow do
    origins '*'
  end
end

get '/:language/:function' do
  run
end

post '/:language/:function' do
  run
end

private

def run
#  Ve.source = Ve::Local # Default
#  Ve.source = Ve::Remote.new(:url => 'http://ve.kimtaro.com/', :access_token => 'XYZ')
#  result = Ve.get(params[:text], params[:language], params[:function].to_sym)
  result = Ve.in(params[:language]).words(params[:text])

  case params[:function].to_sym
  when :words
    json = JSON.generate(result.collect(&:as_json))
  else
    json = result
  end

  if params[:callback]
    json = "#{params[:callback]}(#{json})"
    content_type 'application/javascript', :charset => 'utf-8'
  else
    content_type 'application/json', :charset => 'utf-8'
  end

  json
end
