Facter.add(:mongodb_version) do
  setcode do
    if Facter::Util::Resolution.which('mongo')
      mongodb_version = Facter::Util::Resolution.exec('mongo --version 2>&1')
      %r{^MongoDB shell version: ([\w\.]+)}.match(mongodb_version)[1]
    end
  end
end
