module Modifiers
  def self.define_modifier(name, &block)
    define_method(name) do |sym|
      original_method = instance_method(sym)
      original_visibility = visibility_of(sym)
      define_method(sym) do |*args|
        bound_method = original_method.bind(self)
        bound_method.define_singleton_method(:invoke) { bound_method.call(*args) }
        if block
          instance_exec(bound_method, *args, &block)
        else
          bound_method.invoke
        end
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
