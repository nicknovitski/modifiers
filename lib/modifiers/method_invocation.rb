module Modifiers
  class MethodInvocation
    def initialize(method:, receiver:, arguments:)
      @method = method
      @receiver = receiver
      @arguments = arguments
    end

    attr_reader :arguments

    def invoke(context = receiver)
      method.bind(context).call(*arguments)
    end

    def name
      method.name
    end

    def location
      caller[5] =~ /(.*?):(\d+).*?$/i
      [$1, $2]
    end

    private

    def bound_method
      method.bind(receiver)
    end

    attr_reader :method, :receiver
  end
end
