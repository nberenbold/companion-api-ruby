module CompanionApi
  class Base
    attr_accessor :profile
    attr_accessor :account
    attr_accessor :login
    attr_accessor :market

    def initialize(profile_name)
      @profile = Profile.new(profile_name)
      @account = CompanionApi::Resources::Account.new(@profile)
      @login = CompanionApi::Resources::Login.new(@profile)
      @market = CompanionApi::Resources::Market.new(@profile)
    end

    def login!(username, password)
      raise CompanionApi::Error, 'no username or password specified' if username.blank? || password.blank?

      @account.auto_login!(username, password)
    end

    def token_auth!
      @account.token_login!

      url = @account.login_url
      CompanionApi.config.logger.info("please visit #{url} and hit enter afterwards")
      gets
      res = @login.post_auth
      raise CompanionApi::Error, 'invalid response received' if res['status'] != 200
    end

    def loggedin?
      @login.character.present?
    end

    def valid_token?
      last_login = @profile.get("lastLogin")
      return false if last_login.blank?

      diff = Time.now.to_i - last_login
      # we use 12 hours for now to refresh tokens a bit more often and prevent expiring
      diff < 12 * 60 * 60
    end
  end
end
