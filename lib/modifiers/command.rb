require 'modifiers/define_modifier'

module Modifiers
  define_modifier(:command) do |invocation|
    invocation.invoke
    nil
  end
end
