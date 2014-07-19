require 'modifiers/define_modifier'

module Modifiers
  define_modifier(:memoized) do |invocation|
    ivar = "@#{invocation.method_name}".to_sym

    instance_variable_set(ivar, {}) unless instance_variable_defined?(ivar)

    memoizer = instance_variable_get(ivar)
    memoizer.fetch(invocation.arguments) { memoizer[invocation.arguments] = invocation.invoke }
  end
end
