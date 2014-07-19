require 'modifiers/modifier'

module Modifiers
  def self.define_modifier(name, &block)
    define_method(name) do |sym|
      modifier = Modifier.new(self, sym)
      define_method(sym) do |*args|
        modifier.call(self, *args, &block)
      end
      send(modifier.original_visibility, sym)
    end
  end
end
