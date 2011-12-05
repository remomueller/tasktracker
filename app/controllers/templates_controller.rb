class TemplatesController < ApplicationController
  before_filter :authenticate_user!

  def generate_stickies
    @template = current_user.all_templates.find_by_id(params[:id])
    @frame = (@template ? @template.project.frames.find_by_id(params[:frame_id]) : nil)
    @frame_id = @frame.id if @frame
    frame_name = (@frame ? @frame.name + ' - ' + @frame.short_time : 'Backlog')
    if @template
      @template.generate_stickies!(@frame_id)
      redirect_to @template, notice: @template.items.size.to_s + ' ' + ((@template.items.size == 1) ? 'sticky' : 'stickies') + " successfully created and added to #{frame_name}."
    else
      redirect_to root_path
    end
  end

  def add_item
    @template = current_user.all_templates.new
    @item = { description: '', interval: 0, units: 'days' }
  end

  def index
    current_user.update_attribute :templates_per_page, params[:templates_per_page].to_i if params[:templates_per_page].to_i >= 10 and params[:templates_per_page].to_i <= 200
    template_scope = current_user.all_viewable_templates
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| template_scope = template_scope.search(search_term) }
    
    @order = Template.column_names.collect{|column_name| "templates.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "templates.name"
    template_scope = template_scope.order(@order)
    
    @templates = template_scope.page(params[:page]).per(current_user.templates_per_page)
  end

  def show
    @template = current_user.all_templates.find_by_id(params[:id])
    redirect_to root_path unless @template
  end

  def new
    @template = current_user.all_templates.new(params[:template])
  end
  
  def edit
    @template = current_user.all_templates.find_by_id(params[:id])
    redirect_to root_path unless @template
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
