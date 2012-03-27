class TemplatesController < ApplicationController
  before_filter :authenticate_user!

  def selection
    @template = current_user.all_templates.find_by_id(params[:template_id])
  end

  def add_item
    @template = current_user.templates.new(params[:template])
    @item = { description: '', interval: 0, units: 'days' }
  end

  def index
    template_scope = if User::VALID_API_TOKENS.include?(params[:api_token])
      if user = User.find_by_api_token(params[:api_token], params[params[:api_token]])
        user.all_viewable_templates
      else
        Template.none
      end
    else
      user = current_user
      user.all_viewable_templates
    end

    user.update_attribute :templates_per_page, params[:templates_per_page].to_i if params[:templates_per_page].to_i >= 10 and params[:templates_per_page].to_i <= 200

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| template_scope = template_scope.search(search_term) }

    template_scope = template_scope.with_project(@project.id, user.id) if @project = user.all_viewable_projects.find_by_id(params[:project_id])

    @order = Template.column_names.collect{|column_name| "templates.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "templates.name"
    template_scope = template_scope.order(@order)

    respond_to do |format|
      format.html { @templates = template_scope.page(params[:page]).per(user.templates_per_page) }
      format.js { @templates = template_scope.page(params[:page]).per(user.templates_per_page) }
      format.json do
        render json: template_scope.current.collect{|t| { name: [t.name, (t.project ? t.project.name : nil)].compact.join(' - '), id: t.id } }
      end
    end
  end

  def show
    @template = current_user.all_viewable_templates.find_by_id(params[:id])
    redirect_to root_path unless @template
  end

  def new
    @template = current_user.templates.new(params[:template])
  end

  def edit
    @template = current_user.all_templates.find_by_id(params[:id])
    redirect_to root_path unless @template
  end

  def items
    @template = current_user.templates.new(params[:template])
  end

  def create
    @template = current_user.templates.new(params[:template])

    if @template.save
      redirect_to @template, notice: 'Template was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @template = current_user.all_templates.find_by_id(params[:id])
    if @template
      if @template.update_attributes(params[:template])
        redirect_to @template, notice: 'Template was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @template = current_user.all_templates.find_by_id(params[:id])
    if @template
      @template.destroy
      redirect_to templates_path
    else
      redirect_to root_path
    end
  end
end
