require 'sinatra'
require 'oauth2'
require 'json'
enable :sessions

CONSUMER_KEY = '8d6a4bf754f7d2ca127eb4023b42d22e605888e4311a9a1f6931cefae9e53c17'
CONSUMER_SECRET = 'cc76b167e9497faab509648e4dc90d7d81736e96f541112db48675b7371c435c'

get '/' do
  redirect '/tasks'
end

get '/auth/callback' do
  access_token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
  session[:access_token] = access_token.token
  redirect '/tasks'
end

get '/tasks' do
  if session[:access_token]
    @tasks = get_response('tasks')
  else
    redirect client.authorize_url
  end

  erb :tasks
end

def get_response(url)
  access_token = session[:access_token]
  access_token = OAuth2::AccessToken.new(client, access_token)
  access_token.get("/api/external/#{url}")
end

def client
  OAuth2::Client.new(
      CONSUMER_KEY, CONSUMER_SECRET,
      site: 'http://lvh.me:3000',
      authorize_url: '/oauth2/authorize',
      token_url: '/oauth2/token'
  )
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end
