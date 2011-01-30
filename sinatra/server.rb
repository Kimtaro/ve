require 'rubygems'
require 'sinatra'
require 'json'

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")

get '/:language/words' do
  words
end

post '/:language/words' do
  words
end

private

def words
  words = Sprakd.get(params[:text], params[:language], :words)

  result = JSON.generate(words.collect(&:as_json))
  if params[:callback]
    result = "#{params[:callback]}(#{result})"
  end
  
  result
end