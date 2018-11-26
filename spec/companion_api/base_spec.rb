RSpec.describe CompanionApi::Base do
  # it "creates a valid token auth" do
  #   api = CompanionApi::Base.new("test_profile")
  #   expect(api.token_auth!).to be true
  # end

  it "creates a valid login" do
    api = CompanionApi::Base.new("test_profile")
    api.login!("", "")
  end
end