class TagsController < ApplicationController

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find params[:id]
  end

  def unused
    
  end

  def edit
    @tag = Tag.find params[:id]
  end

  def create
  end

  def complete_tags
    @tags = Tag.all
    render :partial => "auto_completed"
  end

end
