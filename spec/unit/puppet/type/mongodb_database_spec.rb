require 'puppet'
require 'puppet/type/mongodb_database'
describe Puppet::Type.type(:mongodb_database) do

  before :each do
    @user = Puppet::Type.type(:mongodb_database).new(:name => 'test')
  end

  it 'should accept a database name' do
    @user[:name].should == 'test'
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:mongodb_database).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

end
