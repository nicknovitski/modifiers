require 'modifiers/modification'

module Modifiers
  def define_modifier(modifier, helper = nil, &method_body)
    define_method(modifier) do |modified|
      mod = Modification.new(modifier, self, modified, method_body)
      mod.send(:include, helper) if helper
      prepend mod
      modified
    end
  end
  module_function :define_modifier
end
