# frozen_string_literal: true

require 'dry/initializer'

module SpyAlleyApplication
  module Results
    class SoldTopSecretInformation
      class Twenty
        extend Dry::Initializer
        option :sold_top_secret_information, default: -> do
          SpyAlleyApplication::Results::SoldTopSecretInformation::new
        end
        def call(player_model:, change_orders:, action_hash: nil, opponent_models: nil, decks_model: nil)
          sold_top_secret_information.(
            player_model: player_model,
            change_orders: change_orders,
            money_earned: 20
          )
        end
      end
    end
  end
end
