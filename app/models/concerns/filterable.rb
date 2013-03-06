module Filterable
  extend ActiveSupport::Concern

  included do
    def self.filter(filters)
      scope = self.all
      filters.each_pair do |key, value|
        scope = scope.where(key => value) if self.column_names.include?(key.to_s) and not value.blank?
      end
      scope
    end
  end
end
