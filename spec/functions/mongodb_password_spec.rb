# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb_password' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(:undef, :undef).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('', '').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('user', 'pass').and_return('e0c4a7b97d4db31f5014e9694e567d6b') }
  it { is_expected.to run.with_params('user', sensitive('pass')).and_return(sensitive('e0c4a7b97d4db31f5014e9694e567d6b')) }
  it { expect(subject.execute('user', sensitive('pass'))).to eq(sensitive('e0c4a7b97d4db31f5014e9694e567d6b')) }
end
