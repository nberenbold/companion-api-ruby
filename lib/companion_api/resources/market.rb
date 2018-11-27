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
        region = @profile.get('region')
        raise CompanionApi::Error, 'No region set in profile, login a character first' if region.blank?

        req = CompanionApi::Request.new(
          uri:      region,
          endpoint: endpoint,
          token:    @profile.get("token"),
        )

        res = req.get!
        json = JSON.parse(res.body)
        raise CompanionApi::ApiError, 'got an error message from companion api' if json["error"].present? && json["error"]["code"].present?

        json
      end
    end
  end
end
