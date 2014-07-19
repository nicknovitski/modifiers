require 'spec_helper'
require 'shared_examples_for_modifiers'
require 'modifiers/deprecated'

RSpec.describe Modifiers do
  describe '#deprecated' do
    it_behaves_like 'a modifier', :deprecated

    let(:test_class) do 
      class Test
        extend Modifiers

        def method
          #
        end
        deprecated :method
      end
    end
    subject(:test_instance) { test_class.new }

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
      expect(subject).to receive(:warn).with(/\#method/)

      subject.method
    end

    it 'includes the location of the call in the warning' do
      expect(subject).to receive(:warn).with(/deprecated_spec.rb/)

      subject.method
    end
  end
end
