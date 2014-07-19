require 'spec_helper'
require 'modifiers/deprecated'

RSpec.describe Modifiers do
  describe '#deprecated' do
    it_behaves_like 'a modifier', :deprecated

    let(:test_class) do 
      class Test
        extend Modifiers

        deprecated def method
          # something you shouldn't be using
        end
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
      expect(subject).to receive(:warn).with(/Test\#method/)

      subject.method
    end

    it 'includes the location of the call in the warning' do
      expect(subject).to receive(:warn).with(/deprecated_spec.rb/)

      subject.method
    end

    context 'class methods' do
      before do
        class Test
          class << self
            extend Modifiers
            deprecated def class_method
              #
            end
          end
        end
      end

      it 'names the method correctly in the warning' do
        expect(test_class).to receive(:warn).with(/Test\.class_method/)

        test_class.class_method
      end
    end
  end
end
