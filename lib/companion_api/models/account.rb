module CompanionApi
  module Models
    class Account
      PLATFORM_IOS = 1
      PLATFORM_ANDROID = 2

      attr_accessor :profile

      def initialize(profile)
        @profile = profile
      end

      def login!
        url = login_url

        puts url

        # if ($api->Login()->postAuth()->status === 200) {
        #   echo "You're all loged in just fine!";
        # } else {
        #   echo "Could not confirm login authentication...";
        # }

        # $this->getLoginUrl();
        #
        # // attempt to auto-login
        # $this->autoLoginToProfileAccount($username, $password);
        #
        # // authenticate
        # if ((new Login())->postAuth()->status !== 200) {
        #   throw new \Exception('Token status could not be validated');
        # }
      end

      def auto_login!(username, password)
        req = CompanionApi::Request.new(
          uri: login_url,
          requestId: CompanionApi.uuid,
          absolute: true
        )

        body = req.get!

        if !body.include?('cis_sessid') && body.include?("loginForm")
          html = Nokogiri::HTML(body)
          form = html.at_css("form[id='loginForm']")
          stored = form.at_css("input[name='_STORED_']")[:value]

          action = CGI.unescape(form[:action])

          data = {
            "_STORED_": stored,
            "sqexid": username,
            "password": password
          }

          req = CompanionApi::Request.new(
            uri: CompanionApi::Request::URI_SE,
            endpoint: "/oauth/oa/#{action}",
            requestId: CompanionApi.uuid,
            # token: profile.get("token"),
            form: data
          )

          body = req.post!
        end

        puts body.inspect

        html = Nokogiri::HTML(body)
        form = html.at_css("form[name='mainForm']")
        cis_sessid = form.at_css("input[name='cis_sessid']")[:value]

        data = {
          "cis_sessid": cis_sessid,
          "provision": "",
          "_c": 1
        }

        req = CompanionApi::Request.new(
          uri: form[:action],
          absolute: true,
          # requestId: CompanionApi.uuid,
          query: {
            token: @profile.get("token"),
            uid: @profile.get("uid")
          },
          return202: true,
          form: data
        )

        body = req.post!

        raise body.inspect

        # preg_match('/(.*)action="(?P<action>[^"]+)">/', $html, $matches);
        # $action = html_entity_decode($matches['action']);
        # preg_match('/(.*)name="cis_sessid" type="hidden" value="(?P<cis_sessid>[^"]+)">/', $html, $matches);
        # $cis_sessid = trim($matches['cis_sessid']);
        #
        # $formData = [
        #   'cis_sessid' => $cis_sessid,
        #   'provision'  => '', // ??? - Don't know what this is but doesn't seem to matter
        # '_c'         => 1   // ??? - Don't know what this is but doesn't seem to matter
        #   ];
        #
        #   // submit to companion to confirm cis_sessid
        # $req = new CompanionRequest([
        #   'uri'       => $action,
        #   'form'      => $formData,
        #   'version'   => '',
        #   'requestId' => ID::get(),
        #   'return202' => true,
        # ]);
        #
        # // this will be another form with some other bits that the app just forcefully submits via js
        # if ($this->post($req)->getStatusCode() !== 202) {
        #   throw new \Exception('Login status could not be validated.');
        # }
        # }

        raise "qwe"
      end

      def login_url
        @profile.set("userId", CompanionApi.uuid)

        json = get_token
        @profile.set("token", json["token"])
        @profile.set("salt", json["salt"])

        CompanionApi::Request::SQEX_AUTH_URI + "?" + {
          'client_id'     => 'ffxiv_comapp',
          'lang'          => 'en-us',
          'response_type' => 'code',
          'redirect_uri'  => redirect_uri
        }.to_query
      end

      def redirect_uri
        uid = CompanionApi.pbkdf2(@profile.get("userId"), @profile.get("salt"))
        @profile.set('uid', uid)

        CompanionApi::Request::OAUTH_CALLBACK + "?" + {
          'token'      => @profile.get('token'),
          'uid'        => uid,
          'request_id' => CompanionApi.uuid
        }.to_query
      end

      def get_token
        crypted_uuid = CompanionApi.rsa.public_encrypt(@profile.get("userId"))
        uid = Base64.encode64(crypted_uuid)

        req = CompanionApi::Request.new(
          uri: CompanionApi::Request::URI,
          endpoint: '/login/token',
          json: { 'platform' => PLATFORM_ANDROID, 'uid' => uid }
        )

        body = req.post!
        JSON.parse(body)
      end

      # private function autoLoginToProfileAccount(string $username, string $password)
      # {
      #   $html = $this->get(new CompanionRequest([
      #     'uri'       => $this->loginUri,
      #     'version'   => '',
      #     'requestId' => ID::get()
      #   ]))->getBody();
      #
      # // if this response contains "cis_sessid" then we was auto-logged in using cookies
      # // otherwise it's the login form and we need to login to get the cis_sessid
      #   if (stripos($html, 'cis_sessid') === false) {
      #       // todo - convert to: https://github.com/xivapi/companion-php
      #       preg_match('/(.*)action="(?P<action>[^"]+)">/', $html, $matches);
      #       $action = trim($matches['action']);
      #       preg_match('/(.*)name="_STORED_" value="(?P<stored>[^"]+)">/', $html, $matches);
      #       $stored = trim($matches['stored']);
      #
      #       // build payload to submit form
      # $formData = [
      #   '_STORED_' => $stored,
      #   'sqexid'   => $username,
      #   'password' => $password,
      # ];
      #
      # $res = $this->post(new CompanionRequest([
      #   'uri'       => CompanionRequest::URI_SE . "/oauth/oa/{$action}",
      #   'version'   => '',
      #   'requestId' => ID::get(),
      #   'form'      => $formData,
      # ]));
      #
      # $html = $res->getBody();
      # }
      #
      # // todo - convert to: https://github.com/xivapi/companion-php
      # preg_match('/(.*)action="(?P<action>[^"]+)">/', $html, $matches);
      # $action = html_entity_decode($matches['action']);
      # preg_match('/(.*)name="cis_sessid" type="hidden" value="(?P<cis_sessid>[^"]+)">/', $html, $matches);
      # $cis_sessid = trim($matches['cis_sessid']);
      #
      # $formData = [
      #   'cis_sessid' => $cis_sessid,
      #   'provision'  => '', // ??? - Don't know what this is but doesn't seem to matter
      # '_c'         => 1   // ??? - Don't know what this is but doesn't seem to matter
      #   ];
      #
      #   // submit to companion to confirm cis_sessid
      # $req = new CompanionRequest([
      #   'uri'       => $action,
      #   'form'      => $formData,
      #   'version'   => '',
      #   'requestId' => ID::get(),
      #   'return202' => true,
      # ]);
      #
      # // this will be another form with some other bits that the app just forcefully submits via js
      # if ($this->post($req)->getStatusCode() !== 202) {
      #   throw new \Exception('Login status could not be validated.');
      # }
      # }
    end
  end
end