require 'spec_helper'
require 'modifiers/define_modifier'

module MyModifier
  extend Modifiers
  define_modifier(:bro) { |i| i.invoke + ', bro' }
end

class Foo
  extend MyModifier

  bro def hello(name = 'world')
    "hello, #{name}"
  end
end

RSpec.describe Modifiers do
  describe '.define_modifier' do
    it 'can make new modifiers in new modules' do
      expect(Foo.new.hello).to eq('hello, world, bro')
    end
  end
end
