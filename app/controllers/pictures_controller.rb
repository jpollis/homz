class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  layout :resolve_layout

  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
    @comment =  Comment.new
  end

  # GET /pictures/new
  def new
    session[:zip] = params[:zip] if params[:zip]
    @picture = Picture.new
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)

    respond_to do |format|
      if @picture.save
        require "google/cloud/vision"
        project_id = "homz-direct"
        vision = Google::Cloud::Vision.new project: project_id
        file_name = @picture.attachment.url.prepend("https:").split('?')[0]
        labels = vision.image(file_name).labels
        @picture.raw_json = labels.to_json

        labels.each do |label|
          if label.score > 0.80
            PictureTag.create(tag_name: label.description, rating: label.score, picture_id: @picture.id)
          end
        end

        @picture.save

        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        # format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        # format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        # format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        # format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: 'Picture was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end

  private

  def resolve_layout
    case action_name
    when "new"
      "app_no_container_no_flow"
    else
      "app_no_container"
    end
  end


    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:location,:attachment,:user_id, :property_id)
    end
end
