module CompanionApi
  module Resources
    class Market
      attr_accessor :profile

      def initialize(profile)
        @profile = profile
      end

      def item_market_listings(item_id, hq: false)
        endpoint = "/market/items/catalog/#{item_id}"
        endpoint += "/hq" if hq

        request_result(endpoint)
      end

      def market_listings_by_category(category_id)
        request_result("/market/items/category/#{category_id}")
      end

      def transaction_history(catalog_id)
        request_result("/market/items/history/catalog/#{catalog_id}")
      end

      protected

      def request_result(endpoint)
        req = CompanionApi::Request.new(
          uri:      @profile.get('region'),
          endpoint: endpoint,
          token:    @profile.get("token"),
        )

        res = req.get!
        JSON.parse(res.body)
      end
    end
  end
end
