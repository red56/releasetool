module Releasetool
  class Version
    attr_reader :ident
    def initialize(ident)
      raise "Not a valid version identifier: #{ident.inspect}" unless ident.is_a?(String)
      @ident = ident
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
  end
end
