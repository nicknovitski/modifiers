require 'modifiers/define_modifier'

module Modifiers
  module Memoized
    private

    def ivar(method_name)
      "@#{method_name}".to_sym
    end

    def init_memo(method_name)
      instance_variable_set(ivar(method_name), {}) unless instance_variable_defined?(ivar(method_name))
    end

    def memoizer_for(method_name)
      instance_variable_get(ivar(method_name))
    end

    def memoizer_fetch(method_name, key, &block)
      memoizer_for(method_name).fetch(key, &block)
    end
  end

  define_modifier(:memoized, Memoized) do |*args, &block|
    init_memo(__method__)
    memoizer_fetch(__method__, args) { memoizer_for(__method__)[args] = super(*args, &block) }
  end
end
