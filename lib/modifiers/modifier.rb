module Modifiers
  class Modifier
    def initialize(target, name)
      @target = target
      @name = name
      @original_method = target.send(:instance_method, name)
      @original_visibility = self.class.visibility_of(name, target)
    end

    def self.visibility_of(sym, target)
      if target.private_method_defined?(sym)
        :private
      elsif target.protected_method_defined?(sym)
        :protected
      elsif target.method_defined?(sym)
        :public
      else
        raise NoMethodError
      end
    end

    def call(instance, *args, &block)
      bound_method = @original_method.bind(instance)
      bound_method.define_singleton_method(:invoke) { bound_method.call(*args) }
      if block
        instance.instance_exec(bound_method, *args, &block)
      else
        bound_method.invoke
      end
    end
    attr_reader :original_visibility

    private

    attr_reader :original_method
  end
end
