class TagsController < ApplicationController
  before_filter :authenticate_user!

  def index
    # current_user.update_attribute :tags_per_page, params[:tags_per_page].to_i if params[:tags_per_page].to_i >= 10 and params[:tags_per_page].to_i <= 200
    tag_scope = current_user.all_viewable_tags
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| tag_scope = tag_scope.search(search_term) }

    tag_scope = tag_scope.with_project(@project.id, current_user.id) if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    @order = scrub_order(Tag, params[:order], 'tags.name')
    tag_scope = tag_scope.order(@order)

    @count = tag_scope.count
    @tags = tag_scope.page(params[:page]).per( 20 ) #current_user.tags_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @tags }
    end
  end

  def show
    @tag = current_user.all_viewable_tags.find_by_id(params[:id])
    redirect_to root_path unless @tag
  end

  def new
    @tag = current_user.tags.new(post_params)
  end

  def edit
    @tag = current_user.all_tags.find_by_id(params[:id])
    redirect_to root_path unless @tag
  end

  def create
    @tag = current_user.tags.new(post_params)

    if @tag.save
      redirect_to(@tag, notice: 'Tag was successfully created.')
    else
      render action: "new"
    end
  end

  def update
    @tag = current_user.all_tags.find_by_id(params[:id])

    if @tag
      if @tag.update_attributes(post_params)
        redirect_to(@tag, notice: 'Tag was successfully updated.')
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @tag = current_user.all_tags.find_by_id(params[:id])
    @tag.destroy if @tag

    respond_to do |format|
      format.html { redirect_to tags_path }
      format.json { head :no_content }
    end
  end

  def post_params
    params[:tag] ||= {}

    unless params[:tag][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:tag][:project_id])
      params[:tag][:project_id] = project ? project.id : nil
    end

    params[:tag].slice(
      :name, :description, :color, :project_id
    )
  end
end
