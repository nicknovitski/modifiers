require 'modifiers/define_modifier'

module Modifiers
  define_modifier(:command) do |*args, &block|
    super(*args, &block)
    self
  end
end
