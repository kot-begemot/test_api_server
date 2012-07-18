class VideosController < ApplicationController

  respond_to :html, :json

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @videos }
    end
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = Video.find(params[:id])
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
    @video = Video.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @video }
    end
  end

  # POST /videos
  # POST /videos.json
  def create
    respond_to do |format|
      format.html do
        @video = Video.new(params[:video])
        if @video.save
          @video.delay.download_and_convert
          redirect_to @video, notice: 'Video was successfully created.'
        else
          render action: "new"
        end
      end
      format.json do
        @video = Video.new JSON.parse(request.body.read)
        if @video.save
          @video.delay.download_and_convert
          render json: @video, status: :created, location: @video
        else
          render json: @video.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
