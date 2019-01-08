RSpec.describe CompanionApi::Base do
  it 'creates a valid login' do
    json = JSON.parse(File.read('.test.credentials'))

    api = described_class.new('test_profile')
    expect(api.login!(json['username'], json['password'])).to be(true)
  end

  it 'returns a list of characters on the account' do
    api = described_class.new('test_profile')
    expect(api.login.characters).not_to be_empty
  end

  it 'logs the first character on the account in' do
    api = described_class.new('test_profile')
    character = api.login.characters.first

    expect(api.login.select_character(character['cid'])).not_to be_empty
  end

  it 'expects loggedin? to return true' do
    api = described_class.new('test_profile')
    character = api.login.characters.first
    api.login.select_character(character['cid'])

    expect(api.loggedin?).to eq(true)
  end

  it 'expects the world-status of the character to return Shiva' do
    api = described_class.new('test_profile')
    character = api.login.characters.first
    api.login.select_character(character['cid'])

    expect(api.login.character_status["world"]).to eq("Shiva")
  end
end
