# frozen_string_literal: true

# Allows filtering by specified columns.
module Filterable
  extend ActiveSupport::Concern

  included do
    def self.filter(filters)
      scope = all
      filters.each_pair do |key, value|
        scope = scope.where(key => value) if column_names.include?(key.to_s) && value.present?
      end
      scope
    end
  end
end
