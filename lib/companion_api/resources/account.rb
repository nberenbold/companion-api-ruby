module CompanionApi
  module Resources
    class Account
      PLATFORM_IOS = 1
      PLATFORM_ANDROID = 2

      attr_accessor :profile

      def initialize(profile)
        @profile = profile
      end

      def auto_login!(username, password)
        req = CompanionApi::Request.new(
          uri:       login_url,
          requestId: CompanionApi.uuid,
          absolute:  true,
        )

        res = req.get!
        body = res.body

        if !body.include?('cis_sessid') && body.include?('loginForm')
          html = Nokogiri::HTML(body)
          form = html.at_css("form[id='loginForm']")
          stored = form.at_css("input[name='_STORED_']")[:value]

          action = CGI.unescape(form[:action])

          data = {
            "_STORED_": stored,
            "sqexid":   username,
            "password": password,
          }

          req = CompanionApi::Request.new(
            uri:       CompanionApi::Request::URI_SE,
            endpoint:  "/oauth/oa/#{action}",
            requestId: CompanionApi.uuid,
            # token: profile.get("token"),
            form:      data,
          )

          res = req.post!
          body = res.body
        end

        html = Nokogiri::HTML(body)
        form = html.at_css("form[name='mainForm']")
        raise CompanionApi::LoginError, 'unexpected response received' if form.nil?

        cis_sessid = form.at_css("input[name='cis_sessid']")[:value]

        data = {
          "cis_sessid": cis_sessid,
          "provision":  '',
          "_c":         1,
        }

        req = CompanionApi::Request.new(
          uri:       form[:action],
          absolute:  true,
          # requestId: CompanionApi.uuid,
          query:     {
            token: @profile.get('token'),
            uid:   @profile.get('uid'),
          },
          return202: true,
          form:      data,
        )

        res = req.post!

        raise CompanionApi::LoginError, 'Login status could not be validated.' if res.status != 202

        @profile.set("lastLogin", Time.now.to_i)

        CompanionApi.refresh_uuid
        true
      end

      def login_url
        @profile.set('userId', CompanionApi.uuid)

        json = get_token
        @profile.set('token', json['token'])
        @profile.set('salt', json['salt'])

        CompanionApi::Request::SQEX_AUTH_URI + '?' + {
          'client_id'     => 'ffxiv_comapp',
          'lang'          => 'en-us',
          'response_type' => 'code',
          'redirect_uri'  => redirect_uri,
        }.to_query
      end

      def redirect_uri
        uid = CompanionApi.pbkdf2(@profile.get('userId'), @profile.get('salt'))
        @profile.set('uid', uid)

        CompanionApi::Request::OAUTH_CALLBACK + '?' + {
          'token'      => @profile.get('token'),
          'uid'        => uid,
          'request_id' => CompanionApi.uuid,
        }.to_query
      end

      def get_token
        crypted_uuid = CompanionApi.rsa.public_encrypt(@profile.get('userId'))
        uid = Base64.encode64(crypted_uuid)

        req = CompanionApi::Request.new(
          uri:      CompanionApi::Request::URI,
          endpoint: '/login/token',
          json:     { 'platform' => PLATFORM_ANDROID, 'uid' => uid },
        )

        res = req.post!
        JSON.parse(res.body)
      end
    end
  end
end
