require 'modifiers/define_modifier'

module Modifiers
  module Querying
    def ivars_hash
      instance_variables.each_with_object({}) do |ivar, hash|
        hash[ivar] = instance_variable_get(ivar)
      end
    end

    def duplicate_ivars!
      ivars_hash.each { |k, v| instance_variable_set(k, Marshal.load(Marshal.dump(v))) }
    end

    def reset_ivars(hash)
      hash.each { |k, v| instance_variable_set(k, v) }

      in_state_but_not_hash = instance_variables.select { |i| hash[i].nil? }
      in_state_but_not_hash.each { |i| remove_instance_variable(i) }
    end
  end

  define_modifier(:query, Querying) do |*args, &block|
    orig_ivars = ivars_hash
    duplicate_ivars!
    return_value = super(*args, &block)
    reset_ivars(orig_ivars)
    return_value
  end
end
