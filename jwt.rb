require 'openssl'
require 'jwt'

######
# first we load up the private and public keys that we will use to sign
# and verify our JWT token
# using RS256 algo
######

signing_key = OpenSSL::PKey.read(ENV['PRV_KEY'])
verify_key = OpenSSL::PKey.read(ENV['PUB_KEY'])

set :signing_key, signing_key
set :verify_key, verify_key

# enable sessions which will be our default for storing the token
enable :sessions

# this is to encrypt the session, but not really necessary just for token
# because we aren't putting any sensitive info in there
set :session_secret, 'super secret'

helpers do
  # protected just does a redirect if we don't have a valid token
  def protected!
    return if authorized?
    redirect to('/login')
  end
  # helper to extract the token from the session, header or request param
  # if we are building an api, we would obviously want
  # to handle header or request param

  def extract_token
    # check for the access_token header
    request.env['access_token'] ||
      request['access_token'] ||
      session['access_token']
  end

  # check the token to make sure it is valid with our public key
  def authorized?
    @token = extract_token
    begin
      payload, header = JWT.decode(@token, settings.verify_key, true)
      @exp = header['exp']
      # check to see if the exp is set (we don't accept forever tokens)
      if @exp.nil?
        puts "Access token doesn't have exp set"
        return false
      end
      @exp = Time.at(@exp.to_i)
      # make sure the token hasn't expired
      if Time.now > @exp
        puts 'Access token expired'
        return false
      end
      @user_id = payload['user_id']
    rescue JWT::DecodeError
      puts 'DecodeError'
      return false
    end
  end
end
