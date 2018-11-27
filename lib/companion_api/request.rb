module CompanionApi
  class Request
    SQEX_AUTH_URI     = 'https://secure.square-enix.com/oauth/oa/oauthauth'.freeze
    SQEX_LOGIN_URI    = 'https://secure.square-enix.com/oauth/oa/oauthlogin'.freeze
    OAUTH_CALLBACK    = 'https://companion.finalfantasyxiv.com/api/0/auth/callback'.freeze

    URI     = 'https://companion.finalfantasyxiv.com'.freeze
    URI_SE  = 'https://secure.square-enix.com'.freeze
    VERSION = '/sight-v060/sight'.freeze

    attr_accessor :args

    attr_accessor :headers

    def initialize(args = {})
      defaults = {
        version:   VERSION,
        endpoint:  nil,
        json:      nil,
        form:      nil,
        query:     nil,
        cookies:   nil,
        redirect:  true,
        return202: false,
      }

      @args = args.reverse_merge(defaults)

      raise ComapnionApi::Error, 'maximum redirects reached' if args[:redirects].to_i > 3

      @args[:version] = '' if @args[:uri].include?(URI_SE)

      @headers = {
        'Accept'          => '*/*',
        'Accept-Language' => 'en-gb',
        'Accept-Encoding' => 'br, gzip, deflate',
        'User-Agent'      => 'ffxivcomapp-e/1.0.3.0 CFNetwork/974.2.1 Darwin/18.0.0',
        'request-id'      => @args[:requestId] || CompanionApi.generate_uuid,
        'token'           => @args[:token],
      }

      @headers = @headers.reverse_merge(args[:headers]) if args[:headers].present?
    end

    def post!
      execute!(:post)
    end

    def get!
      execute!(:get)
    end

    protected

    def execute!(method)
      CompanionApi.debug("executing %{method} to endpoint %{endpoint} with url %{uri}", method: method, endpoint: endpoint, uri: @args[:uri])

      # FileUtils.touch("/tmp/cookies.dat")

      # jar = HTTP::CookieJar.new
      # jar.load("/tmp/cookies.dat")

      conn = Faraday.new(url: @args[:uri]) do |builder|
        # builder.response :logger
        builder.request :url_encoded
        builder.use FaradayMiddleware::FollowRedirects
        # builder.use :cookie_jar, jar: jar
        builder.use :cookie_jar
        builder.adapter :net_http
      end

      30.times do
        body = (@args[:json] || @args[:form])

        res = conn.send(method) do |req|
          req.url(endpoint, @args[:query])
          req.headers = @headers
          req.body = body
        end

        CompanionApi.debug("received status %{status}", status: res.status)

        raise CompanionApi::ApiError, res.body if res.status == 500
        raise CompanionApi::TokenExpiredError, 'token has expired' if res.status == 403

        return res if @args[:return202] || res.status != 202

        sleep(0.5)
      end

      raise CompanionApi::Error, 'could not get a valid response after 30 tries'
    end

    def endpoint
      return '' if @args[:absolute]

      @args[:version] + @args[:endpoint]
    end
  end
end
