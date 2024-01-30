# frozen_string_literal: true

module Puppet
  module Util
    module MongodbOutput
      def self.sanitize(data)
        # Dirty hack to remove JavaScript objects
        data.gsub!(%r{\w+\((\d+).+?\)}, '\1') # Remove extra parameters from 'Timestamp(1462971623, 1)' Objects
        data.gsub!(%r{\w+\((.+?)\)}, '\1')

        data.gsub!(%r{^Error:.+}, '')
        data.gsub!(%r{^.*warning:.+}, '') # remove warnings if sslAllowInvalidHostnames is true
        data.gsub!(%r{^.*The server certificate does not match the host name.+}, '') # remove warnings if sslAllowInvalidHostnames is true mongo 3.x
        data.gsub!(%r{^.*Started a new thread for the timer service.+}, '') # Started a new thread for the timer service mongo 5.x (SERVER-78540)
        data
      end
    end
  end
end
