module Releasetool
  class Version
    attr_reader :ident
    def initialize(ident)
      raise "Not a valid version identifier: #{ident.inspect}" unless ident.is_a?(String)
      @ident = ident
    end

    def next_patch
      self.class.normalized(segments[0], segments[1], incremented(segments[2]))
    end

    def next_minor
      self.class.normalized(segments[0], incremented(segments[1]), 0)
    end

    def next_major
      self.class.normalized(incremented(segments[0]), 0, 0)
    end

    def to_s
      if @ident[0] == "v"
        @ident
      else
        "v#{@ident}"
      end
    end

    def to_s_without_v
      if @ident[0] == "v"
        @ident[1..-1]
      else
        @ident
      end
    end

    def ==(other)
      other.is_a?(Releasetool::Version) && ident == other.ident
    end

    def self.normalized(major, minor, patch)
      new("v#{major}.#{minor}.#{patch}")
    end

    private
    def incremented(v)
      raise "Can't work out next version from #{self}" unless v.to_i.to_s == v
      v.to_i + 1
    end

    def segments
      @segments ||= to_s_without_v.split(".")
    end
  end
end
