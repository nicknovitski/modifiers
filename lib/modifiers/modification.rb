class Modification < Module
  def initialize(name, receiver, method_name, method_body)
    @name, @receiver, @method_name = name, receiver, method_name
    super() do
      define_method(method_name, &method_body)
      set_visibility
    end
  end

  private

  attr_reader :receiver, :method_name

  def set_visibility
    case
    when private? then private(method_name)
    when protected? then protected(method_name)
    end
  end

  def protected?
    receiver.protected_method_defined?(method_name)
  end

  def private?
    receiver.private_method_defined?(method_name)
  end
end
