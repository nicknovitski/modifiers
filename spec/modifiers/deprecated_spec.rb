require 'spec_helper'
require 'modifiers/deprecated'

class Test
  extend Modifiers
  def method(arg = :foo)
    arg
  end
  deprecated :method

  protected

  def protected_method
    #
  end
  deprecated :protected_method

  private

  def private_method
    #
  end
  deprecated :private_method
end

RSpec.describe Modifiers do
  describe '#deprecated' do
    subject(:test_instance) { Test.new }
    around(:example) do |example|
      old_verbose, $VERBOSE = $VERBOSE, nil
      example.call
      $VERBOSE = old_verbose
    end

    it 'changes the method to warn it has been deprecated' do
      expect(subject).to receive(:warn).with(/deprecated/)

      subject.method
    end

    it 'includes the name of the method in the warning' do
      expect(subject).to receive(:warn).with(/Test\#method/)
      subject.method
    end

    it 'includes the location of the call in the warning' do
      expect(subject).to receive(:warn).with(/deprecated_spec.rb/)

      subject.method
    end

    it 'does not change the return value of the method' do
      expect(subject.method).to be :foo
    end

    it 'does not change arguments' do
      expect(subject.method(:bar)).to be :bar
    end

    it 'does not change the visibility of a private method' do
      expect(subject.private_methods).to include(:private_method)
    end

    it 'does not change the visibility of a protected method' do
      expect(subject.protected_methods).to include(:protected_method)
    end
  end
end
