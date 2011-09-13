require 'sinatra'
require 'sprockets'
require 'sass'

module Gaskit
  class App < Sinatra::Base
    set :root, Gaskit.root
    set :sprockets, Sprockets::Environment.new(root) { |env|
      env.append_path(root.join('app', 'assets', 'stylesheets'))
      env.append_path(root.join('app', 'assets', 'javascripts'))
      env.append_path(root.join('app', 'assets', 'images'))
    }

    helpers do
      def asset_path(source)
        if Gaskit.env.production?
          settings.sprockets.path(source, true, "assets")
        else
          settings.sprockets.path("#{source}?#{Time.now.to_i}", false, "assets")
        end
      end
    end

    before do
      if request.media_type == 'application/json'
        request.body.rewind
        body = request.body.read
        params.merge!(ActiveSupport::JSON.decode(body)) unless body.blank?
      end
    end

    get '/' do
      erb :dashboard
    end

    get '/stories' do
      json Story.all
    end

    post '/stories' do
      story = Story.new(params)
      story.save
      json story
    end

    put '/stories/:id' do
      story = Story.get!(params['id'])
      story.attributes = params
      story.save!
      json story
    end

    delete '/stories/:id' do
      story = Story.get!(params['id'])
      story.destroy
      :ok
    end

    get '/users' do
      User.ensure_i_exist
      json User.all
    end

  private

    def json(data)
      content_type :js
      data.to_json
    end

  end
end