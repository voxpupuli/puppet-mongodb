# frozen_string_literal: true

Facter.add(:mongodb_version) do
  setcode do
    if Facter::Core::Execution.which('mongod')
      mongodb_version = Facter::Core::Execution.execute('mongod --version 2>&1')
      %r{^db version:?\s+v?([\w.]+)}.match(mongodb_version)[1]
    end
  end
end
