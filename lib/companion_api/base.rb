module CompanionApi
  class Base
    attr_accessor :profile
    attr_accessor :account
    attr_accessor :login

    def initialize(profile_name)
      @profile = Profile.new(profile_name)
      @account = CompanionApi::Models::Account.new(@profile)
      @login = CompanionApi::Models::Login.new(@profile)
    end

    def login!(username, password)
      @account.auto_login!(username, password)
    end

    def token_auth!
      @account.login!
      gets
      res = @login.post_auth
      res["status"] == 200
    end
  end
end