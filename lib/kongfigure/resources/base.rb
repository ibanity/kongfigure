module Kongfigure::Resources
  class Base

    attr_accessor :id, :kongfigure_ignore_fields, :plugins, :updated, :unchanged

    def initialize(id, kongfigure_ignore_fields = nil)
      @id                       = id
      @kongfigure_ignore_fields = (kongfigure_ignore_fields || []).map { |field| field.split(".") }
      @kongfigure_ignore_fields.push("id")
      @plugins                  = []
      @updated                  = false
      @unchanged                = false
    end

    def plugin_allowed?
      true
    end

    def self.build_all(resources_hash)
      resources_hash.map do |resource_hash|
        build(resource_hash)
      end
    end

    def ==(other_object)
      differences       = deep_diff(other_object.api_attributes, api_attributes, kongfigure_ignore_fields)
      differences_count = differences.flatten.size
      if differences_count > 0
        ap api_attributes
        ap other_object.api_attributes
        ap differences
      end
      differences_count == 0
    end

    def display_name
      identifier
    end

    def mark_as_updated
      @updated = true
    end

    def mark_as_unchanged
      @unchanged = true
    end

    def has_to_be_deleted?
      @updated == false && @unchanged == false
    end

    def api_name
      raise NotImplementedError
    end
    private

    def deep_diff(a, b, ignore_nested_keys=[], level=0)
      ignore_nested_keys = ignore_nested_keys.inject([]) do |ignore_nested_keys, ignore_nested_key|
        current_key = ignore_nested_key[level]
        if a.has_key?(current_key) || b.has_key?(current_key)
          ignore_nested_keys.push(ignore_nested_key[level..ignore_nested_key.size])
        end
        ignore_nested_keys
      end
      ignore_keys = ignore_nested_keys.select {|ignore_nested_key| ignore_nested_key.size == 1}.flatten
      (a.keys | b.keys).each_with_object([]) do |k, diff|
        if a[k] != b[k]
          if a[k].is_a?(Hash) && b[k].is_a?(Hash)
            diff.push(deep_diff(a[k], b[k], ignore_nested_keys, level + 1))
          elsif !ignore_keys.include?(k) && !b[k].nil? && k != "id"
            diff.push([a[k], b[k], k, level])
          end
        end
        diff
      end
    end
  end
end
