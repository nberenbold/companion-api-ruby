module CompanionApi
  module Resources
    class Market
      attr_accessor :profile

      def initialize(profile)
        @profile = profile
      end

      def item_market_listings(item_id)
        req = CompanionApi::Request.new(
          uri:      @profile.get('region'),
          endpoint: "/market/items/catalog/#{item_id}",
          token:    @profile.get("token")
        )

        res = req.get!
        json = JSON.parse(res.body)

        format_result(json)
      end

      protected

      def format_result(json)
        result = { "Prices" => [] }

        json["entries"].each do |entry|
          result["Prices"] << {
            "UniqueID": entry["itemId"],
            "Quantity": entry["stack"].to_i,
            "ID": entry["catalogId"].to_i,
            "CraftSignature": entry["signatureName"],
            "IsCrafted": entry["isCrafted"],
            "IsHQ": entry["hq"] == 1,
            "PricePerUnit": entry["sellPrice"].to_i,
            "PriceTotal": entry["sellPrice"].to_i * entry["stack"].to_i,
            "RetainerName": entry["sellRetainerName"],
            "Town": entry["registerTown"]
          }
        end

        result
      end
    end
  end
end