require_relative File.join('..', 'util', 'mongodb_md5er')

# Get the mongodb password hash from the clear text password.
Puppet::Functions.create_function(:mongodb_password) do
  dispatch :mongodb_password do
    required_param 'String[1]', :username
    required_param 'Variant[String[1], Sensitive[String[1]]]', :password
    optional_param 'Boolean', :sensitive
    return_type 'Variant[String, Sensitive[String]]'
  end

  def mongodb_password(username, password, sensitive = false)
    password = password.unwrap if password.respond_to?(:unwrap)
    result_string = Puppet::Util::MongodbMd5er.md5(username, password)
    if sensitive
      Puppet::Pops::Types::PSensitiveType::Sensitive.new(result_string)
    else
      result_string
    end
  end
end
