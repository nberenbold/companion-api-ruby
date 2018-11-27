RSpec.describe CompanionApi::Base do
  # it "creates a valid token auth" do
  #   api = CompanionApi::Base.new("test_profile")
  #   expect(api.token_auth!).to be true
  # end

  it 'creates a valid login' do
    json = JSON.parse(File.read('.test.credentials'))

    # api = described_class.new('test_profile')
    # api.login!(json['username'], json['password'])
  end

  it 'returns a list of characters on the account' do
    api = described_class.new('test_profile')
    expect(api.login.characters).not_to be_empty
  end

  it 'logs the first character in' do
    api = described_class.new('test_profile')
    character = api.login.characters.first

    api.login.select_character(character['cid'])
  end
end
