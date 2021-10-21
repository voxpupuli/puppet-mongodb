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
      '2.6.x' => { '26' => true,  '4' => false, '5' => false },
      '4.x.x' => { '26' => false, '4' => true, '5' => false },
      '5.x.x' => { '26' => false, '4' => false, '5' => true },
      'x.x.x' => { '26' => false, '4' => false, '5' => false }
    }

    v.each do |key, results|
      it "version detection for [#{key}]" do
        allow(provider_class).to receive(:mongo_eval).with('db.version()').and_return(key)
        expect(provider_class.mongo_26?).to be results['26']
        expect(provider_class.mongo_4?).to be results['4']
        expect(provider_class.mongo_5?).to be results['5']
      end
    end
  end
end
