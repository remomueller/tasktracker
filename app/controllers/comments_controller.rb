class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @comments = current_user.all_comments
  end

  def show
    @comment = current_user.all_comments.find_by_id(params[:id])
    redirect_to root_path unless @comment
  end

  def new
    @comment = current_user.comments.new
  end

  def edit
    @comment = current_user.all_comments.find_by_id(params[:id])
    redirect_to root_path unless @comment
  end

  def create
    @comment = current_user.comments.new(params[:comment])
    if @comment.save
      redirect_to(@comment, :notice => 'Comment was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @comment = current_user.all_comments.find_by_id(params[:id])
    if @comment
      if @comment.update_attributes(params[:comment])
        redirect_to(@comment, :notice => 'Comment was successfully updated.')
      else
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @comment = current_user.all_comments.find_by_id(params[:id])
    if @comment
      @comment.destroy
      redirect_to(comments_url)
    else
      redirect_to root_path
    end
  end
end
