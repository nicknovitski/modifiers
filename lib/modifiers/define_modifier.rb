require 'modifiers/modification'

module Modifiers
  def self.define_modifier(name, &block)
    define_method(name) do |sym|
      mod = Modification.new(klass: self, method: sym)
      define_method(sym) do |*args|
        mod.call(self, *args, &block)
      end
      send(mod.original_visibility, sym)
    end
  end
end
