#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

require 'puppet'
require 'puppet/type/mongodb_replset'
describe Puppet::Type.type(:mongodb_replset) do

  before :each do
    @replset = Puppet::Type.type(:mongodb_replset).new(:name => 'test')
  end

  it 'should accept a replica set name' do
    @replset[:name].should == 'test'
  end

  it 'should accept a members array' do
    @replset[:members] = ['mongo1:27017', 'mongo2:27017']
    @replset[:members].should == ['mongo1:27017', 'mongo2:27017']
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:mongodb_replset).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

end
