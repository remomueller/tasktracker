# frozen_string_literal: true

# Allows a series of tasks to be setup that are then launched together as a
# group.
class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index]
  before_action :set_viewable_template, only: [:show]
  before_action :set_editable_template, only: [:edit, :update, :destroy]
  before_action :redirect_without_template, only: [:show, :edit, :update, :destroy]

  def copy
    template = current_user.all_viewable_templates.find_by_id(params[:id])
    respond_to do |format|
      if template and @template = current_user.templates.new(template.copyable_attributes)
        format.html { render 'new' }
        format.json { render json: @template }
      else
        format.html { redirect_to templates_path }
        format.json { head :no_content }
      end
    end
  end

  def selection
    @template = current_user.all_templates.find_by_id(params[:group][:template_id])
  end

  def add_item
    @template = current_user.templates.new(template_params)
    @item = { description: '', interval: 0, units: 'days' }
  end

  # GET /templates
  # GET /templates.json
  def index
    @order = scrub_order(Template, params[:order], 'templates.name')
    template_scope = (params[:editable_only] == '1') ? current_user.all_templates : current_user.all_viewable_templates
    @templates = template_scope.search(params[:search]).filter(params).order(@order).page(params[:page]).per(params[:format] == 'json' ? -1 : 40 )
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = current_user.templates.new(template_params)
  end

  # GET /templates/1/edit
  def edit
  end

  def items
    @template = current_user.templates.new(template_params)
  end

  # POST /templates
  # POST /templates.json
  def create
    @template = current_user.templates.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: 'Template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @template }
      else
        format.html { render action: 'new' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /templates/1
  # PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.json { render action: 'show', location: @template }
      else
        format.html { render :edit }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    @template.destroy

    respond_to do |format|
      format.html { redirect_to templates_path(project_id: @template.project_id) }
      format.json { head :no_content }
    end
  end

  private

  def set_viewable_template
    @template = current_user.all_viewable_templates.find_by_id(params[:id])
  end

  def set_editable_template
    @template = current_user.all_templates.find_by_id(params[:id])
  end

  def redirect_without_template
    empty_response_or_root_path(templates_path) unless @template
  end

  def template_params
    params[:template] ||= { blank: '1' }

    unless params[:template][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:template][:project_id])
      params[:template][:project_id] = project ? project.id : nil
    end

    params.require(:template).permit(
      :name, :project_id, :avoid_weekends,
      { item_tokens: [:description, :owner_id, :interval, :units, :due_at_string, :duration, :duration_units, tag_ids: []] }
    )
  end
end
