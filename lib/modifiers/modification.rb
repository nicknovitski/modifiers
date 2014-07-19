require 'modifiers/method_invocation'

module Modifiers
  class Modification
    def initialize(klass:, method:)
      @klass = klass
      @original_method = klass.send(:instance_method, method)
      @original_visibility = visibility_on(klass)
    end

    attr_reader :original_visibility

    def call(instance, *args, &block)
      invocation = MethodInvocation.new(method: original_method, receiver: instance, arguments: args)
      if block
        instance.instance_exec(invocation, self, &block)
      else
        invocation.invoke
      end
    end

    def method_identifier
      "#{receiver}#{original_method.name}"
    end

    private

    attr_reader :original_method, :klass

    def visibility_on(klass)
      if klass.private_method_defined?(original_method.name)
        :private
      elsif klass.protected_method_defined?(original_method.name)
        :protected
      else
        :public
      end
    end

    def receiver
      instance.is_a?(Module) ? "#{instance}." : "#{instance.class}#"
    end

    def instance
      klass.new
    rescue TypeError # klass is a singleton metaclass
      ObjectSpace.each_object(klass).first
    end
  end
end
