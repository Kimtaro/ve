require 'rubygems'
require 'sinatra'
require 'JSON'

require File.expand_path(File.dirname(__FILE__) + "/../sprakd/lib/sprakd")

get '/:language/words' do
  words = Sprakd.get(params[:text], params[:language], :words)

  result = JSON.generate(words.collect(&:as_json))
  if params[:callback]
    result = "#{params[:callback]}(#{result})"
  end
  
  result
end

