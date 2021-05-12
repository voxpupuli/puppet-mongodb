require 'json'

module Puppet
  module Util
    module MongodbOutput
      def self.sanitize(data)
        # If it already happily contains a valid json, do not do any sanitization
        return data if is_parseable_json(data)

        # Dirty hack to remove JavaScript objects
        data.gsub!(%r{\w+\((\d+).+?\)}, '\1') # Remove extra parameters from 'Timestamp(1462971623, 1)' Objects
        data.gsub!(%r{\w+\((.+?)\)}, '\1')

        # Probably theres a json object that we could extract from the output
        maybe_json = try_extract_json(data)
        return maybe_json unless maybe_json.nil?

        data.gsub!(%r{^Error\:.+}, '')
        data.gsub!(%r{^.*warning\:.+}, '') # remove warnings if sslAllowInvalidHostnames is true
        data.gsub!(%r{^.*The server certificate does not match the host name.+}, '') # remove warnings if sslAllowInvalidHostnames is true mongo 3.x
        data
      end

      def self.is_parseable_json(data)
        !!JSON.parse(data)
      rescue JSON::ParserError
        false
      end

      def self.try_extract_json(data)
        json_data = data.dup
        unescaped_quotes = json_data.scan(%r{:\s*"(.*"+.*)"}).flatten
        for str in unescaped_quotes do
          json_data.sub!(str, str.gsub('"', '\"'))
        end
        maybe_json = json_data.gsub(%r{^[^{]*(?<json>{[\P{Cn}\P{Cs}]*})[^}]*$}, '\k<json>')
        maybe_json if is_parseable_json(maybe_json)
      end
    end
  end
end
