module Modifiers
  class MethodInvocation
    def initialize(method:, receiver:, arguments:)
      @method = method
      @receiver = receiver
      @arguments = arguments
    end

    def invoke
      bound_method.call(*arguments)
    end

    def name
      method.name
    end

    private

    def bound_method
      method.bind(receiver)
    end

    attr_reader :method, :receiver, :arguments
  end
end
