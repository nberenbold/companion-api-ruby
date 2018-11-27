require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'nokogiri'

require 'json'
require 'base64'
require 'openssl'
require 'securerandom'
require 'pbkdf2'
require 'logger'

require 'active_support/core_ext/hash'

require 'companion_api/version'
require 'companion_api/base'
require 'companion_api/configuration'
require 'companion_api/profile'
require 'companion_api/request'
require 'companion_api/error'

require 'companion_api/resources/account'
require 'companion_api/resources/login'
require 'companion_api/resources/market'

module CompanionApi
  class << self
    def uuid
      @uuid ||= generate_uuid
    end

    def refresh_uuid
      @uuid = generate_uuid
    end

    def generate_uuid
      SecureRandom.uuid.upcase
    end

    def pbkdf2(value, salt)
      PBKDF2.new(password: value, salt: salt, iterations: 1000, hash_function: OpenSSL::Digest::SHA1, key_length: 128).hex_string
    end

    def rsa
      pem = File.read(File.join(CompanionApi.config.directory, 'public-key.pem')).strip
      OpenSSL::PKey::RSA.new(Base64.decode64(pem))
    end

    def debug(message, args = {})
      return if config.debug == false || config.logger.nil?

      config.logger.debug(format(message, args))
    end
  end
end
