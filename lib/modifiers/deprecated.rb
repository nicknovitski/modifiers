require 'modifiers/define_modifier'

module Modifiers
  module Deprecated
    private

    def kaller
      caller[4]
    end

    def file
      match_caller(/(.*?):/i)
    end

    def line
      match_caller(/:(\d+).*?$/i)
    end

    def match_caller(pattern)
      kaller.match(pattern)[1].to_s
    end

    def location
      [file, line].join(':')
    end

    def target
      is_a?(Module) ? "#{self}." : "#{self.class}#"
    end
  end

  define_modifier(:deprecated, Deprecated) do |*args, &block|
    warn "deprecated method #{target}#{__method__} called from #{location}"
    super(*args, &block)
  end
end
