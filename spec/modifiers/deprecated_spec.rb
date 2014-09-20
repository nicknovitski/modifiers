require 'spec_helper'
require 'modifiers/deprecated'

RSpec.describe Modifiers do
  describe '#deprecated' do
    context 'with silenced warnings' do
      around(:example) do |example|
        old_verbose, $VERBOSE = $VERBOSE, nil
        example.call
        $VERBOSE = old_verbose
      end

      it_behaves_like 'a modifier', :deprecated
    end

    class Test
      extend Modifiers

      def method
        # something you shouldn't be using
      end
      deprecated :method
    end

    subject(:test_instance) do
      s = Test.new
      allow(s).to receive(:warn)
      s
    end

    it 'changes the method to warn it has been deprecated' do
      subject.method

      expect(subject).to have_received(:warn).with(/deprecated/)
    end

    it 'includes the name of the method in the warning' do
      subject.method

      expect(subject).to have_received(:warn).with(/Test\#method/)
    end

    it 'includes the location of the call in the warning' do
      subject.method

      expect(subject).to have_received(:warn).with(/deprecated_spec.rb/)
    end

    context 'class methods' do
      before do
        class Test
          class << self
            extend Modifiers
            def class_method
              #
            end
            deprecated :class_method
          end
        end
      end

      it 'names the method correctly in the warning' do
        expect(Test).to receive(:warn).with(/Test\.class_method/)

        Test.class_method
      end
    end
  end
end
