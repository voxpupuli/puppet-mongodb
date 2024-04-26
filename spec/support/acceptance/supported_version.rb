# frozen_string_literal: true

def supported_version?(platform, version)
  return true if version.nil?

  supported_versions = %w[5.0 6.0 7.0]
  return false unless supported_versions.include?(version)

  supported_versions.reject! do |v|
    (v < '6.0' && platform.start_with?('el-9')) ||
      (v > '6.0' && platform.start_with?('debian-10')) ||
      (v < '5.0' && platform.start_with?('debian-11')) ||
      (v < '7.0' && platform.start_with?('debian-12')) ||
      (v < '6.0' && platform.start_with?('ubuntu-22'))
  end

  supported_versions.include?(version)
end
