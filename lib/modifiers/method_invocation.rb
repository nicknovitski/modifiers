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

    def location
      [file, line_no]
    end

    def method_name
      method.name
    end

    def method_identifier
      target + method_name.to_s
    end

    private

    def target
      receiver.is_a?(Module) ? "#{receiver}." : "#{receiver.class}#"
    end

    def file
      match_caller(/(.*?):/i)
    end

    def line_no
      match_caller(/:(\d+).*?$/i)
    end

    def match_caller(regex)
      method_caller.match(regex).to_s
    end

    def method_caller
      caller[7]
    end

    attr_reader :method, :receiver
  end
end
