module CompanionApi
  module Resources
    class Login
      attr_accessor :profile
      attr_accessor :account
      attr_accessor :characters
      attr_accessor :character

      def initialize(profile)
        @profile = profile
      end

      def post_auth
        req = CompanionApi::Request.new(
          uri:       CompanionApi::Request::URI,
          endpoint:  '/login/auth',
          requestId: CompanionApi.uuid,
          token:     @profile.get('token'),
          query:     {
            token:      @profile.get('token'),
            uid:        @profile.get('uid'),
            request_id: CompanionApi.uuid,
          },
        )

        res = req.post!
        JSON.parse(res.body)
      end

      def characters
        return @characters if @characters.present?

        json = {}
        3.times do
          req = CompanionApi::Request.new(
            uri:      CompanionApi::Request::URI,
            endpoint: '/login/characters',
            token:    @profile.get("token"),
          )

          res = req.get!
          json = JSON.parse(res.body)
          break if json["accounts"].present?

          sleep(0.5)
        end

        raise CompanionApi::LoginError, 'no valid accounts found' if json["accounts"].blank?

        @account = json["accounts"][0]
        @characters = @account["characters"]

        @characters
      end

      def select_character(cid)
        req = CompanionApi::Request.new(
          uri:      CompanionApi::Request::URI,
          endpoint: "/login/characters/#{cid}",
          token:    @profile.get("token"),
          json:     {
            'appLocaleType' => 'EU',
          },
        )

        res = req.post!
        json = JSON.parse(res.body)

        region = json["region"].chomp("/")
        @profile.set("region", region)

        load_character
      end

      def load_character
        req = CompanionApi::Request.new(
          uri:      @profile.get('region'),
          endpoint: '/login/character',
          token:    @profile.get("token"),
        )

        res = req.get!
        json = JSON.parse(res.body)

        @character = json

        character_status
      end

      def character_status
        req = CompanionApi::Request.new(
          uri:      @profile.get('region'),
          endpoint: '/character/login-status',
          token:    @profile.get("token"),
        )

        res = req.get!
        JSON.parse(res.body)
      end
    end
  end
end
