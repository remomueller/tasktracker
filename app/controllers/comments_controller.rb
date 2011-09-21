class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def add_comment_table
    @object = current_user.send("all_viewable_"+params[:class_name].to_s.titleize.pluralize.gsub(' ', '_').downcase).find_by_id(params[:class_id])
    if @object and not params[:comment].blank?
      @object.new_comment(current_user, params[:comment])
      @position = params[:position]
      @comments = @object.comments
      render "comments/add_comment_table"
    else
      render :nothing => true
    end
  end

  def add_comment
    @object = current_user.send("all_viewable_"+params[:class_name].to_s.titleize.pluralize.gsub(' ', '_').downcase).find_by_id(params[:class_id])
    if @object and not params[:comment].blank?
      @object.new_comment(current_user, params[:comment])
      @position = params[:position]
      @comments = @object.comments.page(params[:page]).per(5)
      params[:action] = 'search' # Trick for pagination
      render "comments/add_comment"
    else
      render :nothing => true
    end
  end


  def search
    @object = current_user.send("all_viewable_"+params[:class_name].to_s.titleize.pluralize.gsub(' ', '_').downcase).find_by_id(params[:class_id])
    if @object
      comments_scope = current_user.all_viewable_comments.with_class_name(params[:class_name]).with_class_id(params[:class_id])
      @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
      @search_terms.each{|search_term| comments_scope = comments_scope.search(search_term) }
      @comments = comments_scope.page(params[:page]).per(5)
    else
      render :nothing => true
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
    # @comment = current_user.comments.new
    flash[:notice] = 'Comments should be added directly to Projects or Stickies!'
    redirect_to root_path
  end

  def edit
    @comment = current_user.all_comments.find_by_id(params[:id])
    redirect_to root_path unless @comment
  end

  # def create
  #   @comment = current_user.comments.new(params[:comment])
  #   if @comment.save
  #     redirect_to(@comment, :notice => 'Comment was successfully created.')
  #   else
  #     render :action => "new"
  #   end
  # end

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
    @comment = current_user.all_deletable_comments.find_by_id(params[:id])
    if @comment
      @comment.destroy
      redirect_to comments_path
    else
      redirect_to root_path
    end
  end
end
