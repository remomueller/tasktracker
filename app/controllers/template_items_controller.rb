# frozen_string_literal: true

# Allows template items to be added to templates.
class TemplateItemsController < ApplicationController
  before_action :authenticate_user!
  # TODO: Move methods from templates_controller to here instead
end
