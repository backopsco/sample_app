require 'sinatra'
require 'oauth2'
require 'json'
require 'byebug'

enable :sessions

CLIENT_ID = '422a6f1976acf86ac01d4169684b7202d55a5e5b1698b41047459211eea31ec3'
CLIENT_SECRET = 'a3967bfe9eb7bfc2986fbc042f99028fda9e5c3fb641e2ca439c9305f5fabae3'

get '/' do
  redirect '/tasks'
end

get '/auth/callback' do
  access_token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
  session[:access_token] = access_token.token
  session[:refresh_token] = access_token.refresh_token

  redirect '/tasks'
end

get '/tasks' do
  if session[:access_token]
    @tasks = get_response('tasks').body
  else
    redirect client.auth_code.authorize_url(redirect_uri: redirect_uri)
  end

  erb :tasks
end

def get_response(url)
  access_token_client = OAuth2::AccessToken.new(client, session[:access_token], refresh_token: session[:refresh_token])
  access_token_client.get("/api/external/#{url}")
end

def client
  OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site: 'http://lvh.me:3000',
      authorize_url: '/oauth2/authorize',
      token_url: '/oauth2/token'
  )
end

def redirect_uri
  uri = URI.parse('http://localhost:5000')
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end
