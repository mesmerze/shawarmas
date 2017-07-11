require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/model'
require 'yaml'
require 'ostruct'
# require 'URI'
require 'net/http'

get('/') do
  # uri = URI('https://oauth.vk.com/authorize')
  # params = {client_id: 6109521,
  #           display: 'page',
  #           redirect_uri: '/index',
  #           response_type: 'token'}
  # uri.query = URI.encode_www_form(params)
  # http = Net::HTTP.new(uri.host, uri.port)
  # http.use_ssl = true
  # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  # request = Net::HTTP::Get.new(uri.request_uri)
  # response = http.request(request)
  # @data = response.body

  erb :hello
end

get('/index') do
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
