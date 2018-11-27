RSpec.describe CompanionApi::Base do
  it 'retrieves a list of market categories' do
    api = described_class.new('test_profile')

    api.market.item_market_listings(5)
  end
end