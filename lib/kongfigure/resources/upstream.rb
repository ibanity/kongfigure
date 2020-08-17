module Kongfigure::Resources
  class Upstream < Base
    attr_accessor :name, :hash_on, :hash_fallback, :hash_on_cookie_path, :slots, :healthchecks, :targets,
                  :hash_fallback, :hash_on_header, :hash_fallback_header, :hash_on_cookie

    def self.build(hash)
      upstream                      = new(hash["id"], hash["kongfigure_ignore_fields"])
      upstream.name                 = hash["name"]
      upstream.hash_on              = hash["hash_on"]
      upstream.hash_fallback        = hash["hash_fallback"]
      upstream.hash_on_cookie_path  = hash["hash_on_cookie_path"]
      upstream.slots                = hash["slots"]
      upstream.healthchecks         = hash["healthchecks"]
      upstream.hash_on_header       = hash["hash_on_header"]
      upstream.hash_fallback        = hash["hash_fallback"]
      upstream.hash_fallback_header = hash["hash_fallback_header"]
      upstream.hash_on_cookie       = hash["hash_on_cookie"]
      upstream.targets              = Kongfigure::Resources::Target.build_all(hash["targets"] || [])
      upstream
    end

    def identifier
      name
    end

    def to_s
      if targets.size > 0
        "#{name} with targets #{targets.map(&:target).join(', ')}"
      else
        "#{name} without target"
      end
    end

    def api_name
      "upstreams"
    end

    def api_attributes
      {
        "name"                 => name,
        "hash_on"              => hash_on,
        "hash_fallback"        => hash_fallback,
        "hash_on_cookie_path"  => hash_on_cookie_path,
        "slots"                => healthchecks,
        "hash_on_header"       => hash_on_header,
        "hash_fallback_header" => hash_fallback_header,
        "hash_on_cookie"       => hash_on_cookie
      }.compact
    end

    def has_target?(target)
      targets && targets.include?(target)
    end
  end
end
