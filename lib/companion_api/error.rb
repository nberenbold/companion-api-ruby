module CompanionApi
  class Error < StandardError; end
  class LoginError < StandardError; end
  class TokenExpiredError < StandardError; end
end
