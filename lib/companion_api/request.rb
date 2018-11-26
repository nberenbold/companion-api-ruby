module CompanionApi
  class Request
    SQEX_AUTH_URI     = "https://secure.square-enix.com/oauth/oa/oauthauth".freeze
    SQEX_LOGIN_URI    = "https://secure.square-enix.com/oauth/oa/oauthlogin".freeze
    OAUTH_CALLBACK    = 'https://companion.finalfantasyxiv.com/api/0/auth/callback'.freeze

    URI     = 'https://companion.finalfantasyxiv.com'.freeze
    URI_SE  = 'https://secure.square-enix.com'.freeze
    VERSION = '/sight-v060/sight'.freeze

    attr_accessor :args

    attr_accessor :headers

    def initialize(args={})
      @args = args

      raise "TODO redirects" if args[:redirects].to_i > 3

      defaults = {
        version: VERSION,
        endpoint: nil,
        json: nil,
        form: nil,
        query: nil,
        cookies: nil,
        redirect: true,
        return202: false
      }

      defaults.each_pair do |key, value|
        next if @args[key] != nil || value == nil
        @args[key] = value
      end

      @args[:version] = "" if @args[:uri].include?(URI_SE)

      @headers = {
        "Accept" => "*/*",
        'Accept-Language' => 'en-gb',
        'Accept-Encoding' => 'br, gzip, deflate',
        'User-Agent'      => 'ffxivcomapp-e/1.0.3.0 CFNetwork/974.2.1 Darwin/18.0.0',
        'request-id'      => @args[:requestId] || CompanionApi.uuid,
        'token'           => @args[:token]
        # = array_merge($this->headers, $config->headers ?? [])
      }

      # $this->uri         = $config->uri;
      # $this->version     = $config->version ?? self::VERSION;
      # $this->endpoint    = $config->endpoint ?? null;
      # $this->json        = $config->json ?? [];
      # $this->form        = $config->form ?? [];
      # $this->query       = $config->query ?? [];
      # $this->cookies     = $config->cookies ?? [];
      # $this->redirect    = $config->redirect ?? $this->redirect;
      # $this->return202   = $config->return202 ?? $this->return202;
      #
      # // if we're on SE secure domain, remove version
      #   if (stripos($this->uri, self::URI_SE)) {
      #       $this->version = null;
      #   }
      #
      #   $this->headers['Accept']          = '*/*';
      #   $this->headers['Accept-Language'] = 'en-gb';
      #   $this->headers['Accept-Encoding'] = 'br, gzip, deflate';
      #   $this->headers['User-Agent']      = 'ffxivcomapp-e/1.0.3.0 CFNetwork/974.2.1 Darwin/18.0.0';
      #   $this->headers['request-id']      = $config->requestId ?? ID::uuid();
      #   $this->headers['token']           = Profile::get('token');
      #   $this->headers                    = array_merge($this->headers, $config->headers ?? []);
    end

    def post!
      execute!(:post)
    end

    def get!
      execute!(:get)
    end

    protected

    def execute!(method)
      puts "Executing #{method.to_s} to url #{current_url}"
      puts "Got #{@args.inspect}"

      conn = Faraday.new(url: @args[:uri]) do |builder|
        builder.response :logger
        builder.request :url_encoded
        # builder.use :cookie_jar
        builder.use FaradayMiddleware::FollowRedirects
        builder.adapter :httpclient do |http|
          http.set_cookie_store("/tmp/test.dat")
        end
      end

      30.times do
        body = (@args[:json] || @args[:form])
        puts "sending body #{body.inspect}"
        puts "sending query #{@args[:query]}"

        res = conn.send(method) do |req|
          req.url((@args[:absolute] == nil || @args[:absolute] == false ? endpoint : ""), @args[:query])
          req.headers = @headers
          req.body = body
        end

        if !@args[:return202] && res.status == 202
          sleep(0.5)
          next
        end

        return res.body
      end

      raise "FOOBAR" # TODO custom exception
    end

    def endpoint
      @args[:version] + @args[:endpoint]
    end

    def current_url
      return @args[:uri] if @args[:absolute]

      @args[:uri] + endpoint
    end
  end
end