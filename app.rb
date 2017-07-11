require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/model'
require 'yaml'
require 'ostruct'

get('/') do
  erb :index
end

post('/submit') do
  @model = Model.new(params[:model])
  if @model.save
    redirect('/models')
  else
    'Error'
  end
end

get('/models') do
  @models = Model.all
  erb :models
end
