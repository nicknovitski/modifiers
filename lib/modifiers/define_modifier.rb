require 'modifiers/modification'

module Modifiers
  def self.define_modifier(name, modification_class = Modification, &block)
    define_method(name) do |sym|
      mod = modification_class.new(klass: self, method: sym)
      define_method(sym) { |*args| mod.call(self, *args, &block) }
      send(mod.original_visibility, sym)
    end
  end
end
