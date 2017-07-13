require 'sinatra'
require 'sinatra/activerecord'
require './models/user'
require 'yaml'
require 'ostruct'
require 'net/http'
require 'vk'
require './jwt.rb'
require 'dotenv/load'

get('/') do
  protected!
  Vk.app_id = ENV['APP_ID']
  Vk.app_secret = ENV['APP_SECRET']
  vk = Vk.client
  @profile = vk.request 'users.get', user_ids: @user_id
  erb :index
end

get('/login') do
  if params[:code]
    code = params[:code]
    uri = URI('https://oauth.vk.com/access_token')
    shmarams = { client_id: ENV['APP_ID'],
                 client_secret: ENV['APP_SECRET'],
                 redirect_uri: "#{ENV['APP_LOC']}/login",
                 code: code }
    uri.query = URI.encode_www_form(shmarams)
    http = Net::HTTP.get_response(uri)
    my_hash = JSON.parse(http.body)
    @users = User.all
    headers = { exp: Time.now.to_i + 60 } # expire in 60 seconds
    unless @users.where(user_id: my_hash['user_id'])
      @user = User.new(my_hash)
      @user.save
    end
    @token = JWT.encode({ user_id: my_hash['user_id'] },
                        settings.signing_key,
                        'RS256',
                        headers)
    session['access_token'] = @token
    redirect('/')
  end
  erb :login
end

get('/stolica') do
  protected!
  erb :stolica
end

get('/gustoza') do
  protected!
  erb :gustoza
end

get('/hasan') do
  protected!
  erb :hasan
end
