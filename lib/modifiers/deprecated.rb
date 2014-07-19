module Modifiers
  def deprecated(sym)
    original_method = instance_method(sym)
    original_visibility = visibility_of(sym)
    messager = deprecation_warner
    define_method(sym) do |*args|
      warn messager.call(self, sym, Gem.location_of_caller)
      original_method.bind(self).call(*args)
    end
    send original_visibility, sym
  end

  private

  def deprecation_warner
    lambda do |object, method_name, location|
      method_id = object.class.to_s + '#' + method_name.to_s
      "deprecated method #{method_id} called from #{location.join(":")}"
    end
  end

  def visibility_of(sym)
    if private_method_defined?(sym)
      :private
    elsif protected_method_defined?(sym)
      :protected
    else
      :public
    end
  end
end
