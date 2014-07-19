require 'modifiers/method_invocation'

module Modifiers
  class Modification
    def initialize(klass:, method:)
      @klass = klass
      @original_method = klass.send(:instance_method, method)
      @original_visibility = visibility_of(method, klass)
    end

    attr_reader :original_visibility

    def call(instance, *args, &block)
      invocation = MethodInvocation.new(method: original_method, receiver: instance, arguments: args)
      if block
        instance.instance_exec(invocation, *args, &block)
      else
        invocation.invoke
      end
    end

    private

    attr_reader :original_method, :klass

    def visibility_of(method, klass)
      if klass.private_method_defined?(method)
        :private
      elsif klass.protected_method_defined?(method)
        :protected
      else
        :public
      end
    end
  end
end
