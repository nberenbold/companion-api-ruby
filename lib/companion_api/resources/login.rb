module CompanionApi
  module Resources
    class Login
      attr_accessor :profile

      def initialize(profile)
        @profile = profile
      end

      def post_auth
        req = CompanionApi::Request.new(
          uri: CompanionApi::Request::URI,
          endpoint: '/login/auth',
          requestId: CompanionApi.uuid,
          token: @profile.get('token'),
          query: {
            token: @profile.get('token'),
            uid: @profile.get('uid'),
            request_id: CompanionApi.uuid
          }
        )

        res = req.post!
        JSON.parse(res.body)
      end
    end
  end
end
