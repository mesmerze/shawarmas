require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/static_assets'
require './models/user'
require './models/profile'
require 'yaml'
require 'ostruct'
require 'net/http'
require 'pry'
require 'vk'
require 'dotenv/load'
require './jwt.rb'

EXP_TIME = 60

def vk_unavailable(uri)
  Net::HTTP.get_response(uri)
rescue StandardError
  flash[:error] = 'Something went wrong! Please try again later'
  redirect('/login')
end

get('/') do
  protected!
  Vk.app_id = ENV['APP_ID']
  Vk.app_secret = ENV['APP_SECRET']
  vk = Vk.client
  @data = vk.request 'users.get',
                     user_ids: @user_id,
                     fields: 'photo_400_orig,city,screen_name,country'
  @user = User.find_by(user_id: @user_id)
  if @user.profile.nil?
    @user.create_profile(photo: @data[0]['photo_400_orig'],
                         city: @data[0]['city']['title'],
                         screen_name: @data[0]['screen_name'],
                         country: @data[0]['country']['title'],
                         first_name: @data[0]['first_name'],
                         last_name: @data[0]['last_name'])
  end
  erb :index
end

get('/profile') do
  protected!
  @user = User.find_by(user_id: @user_id)
  erb :profile
end

get('/logout') do
  session['access_token'] = ''
  redirect('/login')
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
    http = vk_unavailable(uri)
    my_hash = JSON.parse(http.body)
    headers = { exp: Time.now.to_i + EXP_TIME } # expire in 60 seconds
    User.find_or_create_by(user_id: my_hash['user_id']) do |user|
      user.access_token = my_hash['access_token']
      user.expires_in = my_hash['expires_in']
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
