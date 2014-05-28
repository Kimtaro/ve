# Encoding: UTF-8

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

get '/' do
  content_type 'application/json', :charset => 'utf-8'

  howto = {
    "meta" => {"status" => 200},
    "usage" => "/:language/:function?text=X",
    "languages" => {}
  }

  Ve::Manager.languages.each do |lang|
    lang_functions = {"#{lang}" => [], }

    Ve::Manager.functions_for_language(lang).each do |func|
      functional = Ve::Manager.provider_for(lang, func).works?
      lang_functions[lang.to_s] << {"name" => func.to_s, "functional" => functional}
    end

    howto["languages"].merge!(lang_functions)
  end

  howto.to_json
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

  if !Ve::Manager.functions_for_language(params[:language]).include?(params[:function].to_sym)
    status 404
    content_type 'application/json', :charset => 'utf-8'
    return '{"meta": {"status": 404}}'
  end

  result = Ve.in(params[:language]).send(params[:function], params[:text])
  verbose = params[:verbose] == 'true'

  case params[:function].to_sym
  when :words
    json = JSON.generate(result.collect { |w| w.as_json(verbose) })
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
