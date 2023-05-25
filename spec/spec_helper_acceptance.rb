# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'epel-release') if fact_on(host, 'os.name') == 'CentOS'
end
