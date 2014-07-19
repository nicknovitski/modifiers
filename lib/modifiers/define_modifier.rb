module Modifiers
  def self.define_modifier(name, &block)
    define_method(name) do |sym|
      original_method = instance_method(sym)
      original_visibility = visibility_of(sym)
      define_method(sym) do |*args|
        instance_exec(original_method.bind(self), *args, &block)
      end
      send original_visibility, sym
    end

  end

  private

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
