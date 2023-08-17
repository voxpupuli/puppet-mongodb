# frozen_string_literal: true

require 'spec_helper'

require 'puppet/provider/mongodb'

provider_class = Puppet::Provider::Mongodb
describe provider_class do
  before do
    # Clear the cached version before each test
    provider_class.remove_instance_variable(:@mongo_version) \
      if provider_class.instance_variable_defined?(:@mongo_version)
  end

  describe 'mongo version detection' do
    v = {
      '4.x.x' => { '4' => true, '5' => false, '6' => false },
      '5.x.x' => { '4' => false, '5' => true, '6' => false },
      '6.x.x' => { '4' => false, '5' => false, '6' => true },
      'x.x.x' => { '4' => false, '5' => false, '6' => false }
    }

    v.each do |key, _results|
      it "version detection for [#{key}]" do
        allow(provider_class).to receive(:mongo_eval).with('db.version()').and_return(key)
      end
    end
  end
end
