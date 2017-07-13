require 'sinatra'
require 'sinatra/activerecord'
# require './config/environments'
require './models/user'
require 'yaml'
require 'ostruct'
require 'net/http'
require 'vk'
require './jwt.rb'
get('/') do
  erb :index
end

get('/login') do
  if params[:code]
    code = params[:code]
    uri = URI('https://oauth.vk.com/access_token')
    shmarams = { client_id: ENV['APP_ID'],
                 client_secret: 'MsuqFHPDMEY0jpE2Jeyy',
                 redirect_uri: 'https://shawarmas.herokuapp.com/login',
                 code: code
    }
    uri.query = URI.encode_www_form(shmarams)
    http = Net::HTTP.get_response(uri)
    my_hash = JSON.parse(http.body)
    @users = User.all
    headers = {
        exp: Time.now.to_i + 60 #expire in 360 seconds
      }

    unless @users.where(user_id: my_hash['user_id'])
      @user = User.new(my_hash)
      @user.save
      @token = JWT.encode({user_id: my_hash['user_id']},
                           settings.signing_key,
                           "RS256",
                           headers)
      session['access_token'] = @token
    else
      @token = JWT.encode({user_id: my_hash['user_id']},
                           settings.signing_key,
                           "RS256",
                           headers)
      session['access_token'] = @token
    end
    redirect('/index')
  end
  erb :login
end

get('/index') do
  protected!
  Vk.app_id = 6109521
  Vk.app_secret = 'MsuqFHPDMEY0jpE2Jeyy'
  vk = Vk.client
  @profile = vk.request 'users.get', user_ids: @user_id
  puts @profile.each { |user| user['first_name'] }.first['first_name']
  # puts @profile[response['id']] #=> {"response"=>[{"id"=>12345, "first_name"=>"Виталий", "last_name"=>"Михайлов"}]}
  erb :index
end

post('/submit') do
  @user = User.new(params[:user])
  if @user.save
    redirect('/users')
  else
    'Error'
  end
end

get('/users') do
  @users = User.all
  erb :users
end

get('/stolica') do
  erb :stolica
end

get('/gustoza') do
  erb :gustoza
end

get('/hasan') do
  erb :hasan
end
