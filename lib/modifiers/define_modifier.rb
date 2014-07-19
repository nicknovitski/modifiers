require 'modifiers/modification'

module Modifiers
  def define_modifier(name, &block)
    define_method(name) do |sym|
      mod = Modification.new(klass: self, method: sym)
      define_method(sym) { |*args| mod.call(self, *args, &block) }
      send(mod.original_visibility, sym)
    end
  end
  module_function :define_modifier
end
