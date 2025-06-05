# frozen_string_literal: true

def supported_version?(platform, version)
  return true if version.nil?

  supported_versions = %w[6.0 7.0]
  return false unless supported_versions.include?(version)

  supported_versions.reject! do |v|
    (v < '7.0' && platform.start_with?('debian-12'))
  end

  supported_versions.include?(version)
end
