Facter.add(:mongodb_version) do
  setcode do
    if Facter::Core::Execution.which('mongo')
      mongodb_version = Facter::Core::Execution.execute('mongo --version 2>&1')
      %r{^MongoDB shell version(: | v)([\w\.]+)}.match(mongodb_version)[2]
    end
  end
end
