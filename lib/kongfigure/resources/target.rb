module Kongfigure::Resources
  class Target < Base
    attr_accessor :target, :weight

    def self.build(hash)
      target        = new(hash["id"], hash["kongfigure_ignore_fields"])
      target.target = hash["target"]
      target.weight = hash["weight"]
      target
    end

    def api_name
      "targets"
    end

    def api_attributes
      {
        "target" => target,
        "weight" => weight
      }.compact
    end
  end
end
