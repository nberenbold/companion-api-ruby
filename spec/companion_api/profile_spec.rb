RSpec.describe CompanionApi::Profile do
  it 'checks if the configuration file for a profile gets created' do
    profile = described_class.new('profile_check')
    expect(File.exist?(profile.file)).to be true
  end
end
