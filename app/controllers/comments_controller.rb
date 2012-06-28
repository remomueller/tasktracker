class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def search
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:sticky_id])
    if @sticky
      comments_scope = @sticky.comments
      @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
      @search_terms.each{|search_term| comments_scope = comments_scope.search(search_term) }
      @comments = comments_scope.page(params[:page]).per(params[:per])
    else
      render nothing: true
    end
  end

  def index
    current_user.update_attribute :comments_per_page, params[:comments_per_page].to_i if params[:comments_per_page].to_i >= 10 and params[:comments_per_page].to_i <= 200
    comments_scope = current_user.all_viewable_comments
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| comments_scope = comments_scope.search(search_term) }
    @comments = comments_scope.page(params[:page]).per(current_user.comments_per_page)
  end

  def show
    @comment = current_user.all_viewable_comments.find_by_id(params[:id])
    redirect_to root_path unless @comment
  end

  def new
    flash[:notice] = 'Comments should be added directly to Stickies!'
    redirect_to root_path
  end

  def edit
    @comment = current_user.all_comments.find_by_id(params[:id])
    redirect_to root_path unless @comment
  end

  def create
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:sticky_id])
    @position = params[:position]
    @comment = @sticky ? @sticky.comments.new(post_params) : Comment.new(post_params)

    if @comment.save
      @comments = @sticky.comments.page(params[:page]).per(params[:per])
      params[:action] = 'search' # Trick for pagination
    else
      render nothing: true
    end
  end

  def update
    @comment = current_user.all_comments.find_by_id(params[:id])
    if @comment
      if @comment.update_attributes(post_params)
        redirect_to(@comment, notice: 'Comment was successfully updated.')
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @comment = current_user.all_deletable_comments.find_by_id(params[:id])
    if @comment
      @comment.destroy
      redirect_to comments_path
    else
      redirect_to root_path
    end
  end

  private

  def post_params
    params[:comment] ||= {}

    params[:comment][:user_id] = current_user.id

    params[:comment].slice(
      :description, :user_id
    )
  end
end
