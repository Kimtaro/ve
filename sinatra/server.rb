require 'rubygems'
require 'sinatra'
require 'json'

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")

get '/:language/:function' do
  run
end

post '/:language/:function' do
  run
end

private

def run
#  Sprakd.source = Sprakd::Local # Default
#  Sprakd.source = Sprakd::Remote.new(:url => 'http://sprakd.kimtaro.com/', :access_token => 'XYZ')
#  result = Sprakd.get(params[:text], params[:language], params[:function].to_sym)
  result = Sprakd.in(params[:language]).words(params[:text])

  case params[:function].to_sym
  when :words
    json = JSON.generate(result.collect(&:as_json))
  else
    json = result
  end

  if params[:callback]
    json = "#{params[:callback]}(#{result})"
  end

  json
end