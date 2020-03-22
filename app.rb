require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require 'json'
require 'sinatra/json'
require 'dotenv'
require 'cloudinary'
# require 'pry'
require 'sinatra/activerecord'
require './models'

enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
end

helpers do
  def current_admin
    Admin.find_by(id: session[:admin])
  end
end

set :server, 'thin'
set :sockets, []

get '/' do
  erb :index
end

get '/websocket' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        settings.sockets.each do |s|
          s.send(msg)
        end
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end

get '/signin' do
  erb :signin
end

post '/admin' do
  admin = Admin.find_by(name: params[:name])
  if admin.password == params[:password]
    session[:admin] = admin.id
  end

  @menters = Menter.all
  erb :admin
end

post '/add_quiz' do

  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile] #paramsはハッシュ形式でのデータ送信するパラメーター、ではimgは？
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url'] #ここもそう、upload[]？
  end

  menter = Menter.create(
    name: params[:name],
    img: img_urls,
    question: params[:questionn],
    one: params[:one],
    two: params[:two],
    three: params[:three],
    four: params[:four]
  )

  redirect '/admin'
end
