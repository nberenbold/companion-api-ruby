RSpec.describe CompanionApi::Base do
  it 'loads a resultset for earth shards' do
    api = described_class.new('test_profile')

    # we guess there are always shards existent
    expect(api.market.item_market_listings(5)).not_to be_empty
  end

  it 'loads a set of hq items' do
    api = described_class.new('test_profile')

    result = api.market.item_market_listings(23_769, hq: true)
    expect(result["entries"]).to be_nil
  end

  it 'loads a resultset for the market category crystals' do
    api = described_class.new('test_profile')

    expect(api.market.market_listings_by_category(58)).not_to be_empty
  end

  it 'loads the history of earth shards' do
    api = described_class.new('test_profile')

    expect(api.market.transaction_history(5)).not_to be_empty
  end
end
