Facter.add(:mongodb_version) do
  confine { Facter::Core::Execution.which('mongo') }

  setcode do
    mongodb_version = Facter::Core::Execution.execute('mongo --version 2>&1')
    %r{MongoDB shell version:?\s+v?([\w\.]+)}.match(mongodb_version)[1]
  end
end
