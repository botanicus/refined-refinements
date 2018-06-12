# frozen_string_literal: true

module RR
  class Homepath
    def initialize(path)
      if path.start_with?('~')
        @path = File.expand_path(path)
      else
        @path = path # Can be relative.
      end
    end

    def to_s
      @path.sub(ENV['HOME'], '~')
    end
    alias_method :inspect, :to_s

    def expand
      @path
    end

    def exist?
      File.exist?(@path)
    end
  end

  # FIXME: So far colours don't take arguments.
  if defined?(ColourExts)
    ColourExts.colours.define_singleton_method(:homepath) do |path|
      HomePath.new(path).to_s
    end
  end
end
