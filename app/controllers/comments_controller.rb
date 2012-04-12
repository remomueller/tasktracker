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

    if @sticky and not params[:comment].blank?
      @sticky.comments.create(class_name: 'Sticky', class_id: @sticky.id, user_id: current_user.id, description: params[:comment])
      @position = params[:position]
      @comments = @sticky.comments.page(params[:page]).per(params[:per])
      params[:action] = 'search' # Trick for pagination
    else
      render nothing: true
    end
  end

  # def create
  #   @comment = current_user.comments.new(params[:comment])
  #   if @comment.save
  #     redirect_to(@comment, notice: 'Comment was successfully created.')
  #   else
  #     render action: "new"
  #   end
  # end

  def update
    @comment = current_user.all_comments.find_by_id(params[:id])
    if @comment
      if @comment.update_attributes(params[:comment])
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
end
