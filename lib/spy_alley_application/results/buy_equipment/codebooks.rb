# frozen_string_literal: true

require 'dry/initializer'

module SpyAlleyApplication
  module Results
    class BuyEquipment
      class Codebooks
        extend Dry::Initializer
        @@all_codebooks = %w(french german spanish italian american russian).map{|n| "#{n} codebook"}
        option :do_nothing, default: ->{SpyAlleyApplication::Results::NoActionResult::new}
        option :buy_equipment, default: ->{SpyAlleyApplication::Results::BuyEquipment::new}
        def call(player_model:, change_orders:, action_hash:, opponent_models: nil, decks_model: nil)
          if (@@all_codebooks - player_model.equipment).empty? || player_model.money < 15
            do_nothing.(
              player_model: player_model,
              opponent_models: opponent_models,
              change_orders: change_orders,
            )
          else
            buy_equipment.(
              player_model: player_model,
              opponent_models: opponent_models,
              change_orders: change_orders,
              purchase_options: @@all_codebooks - player_model.equipment,
              purchase_limit: [player_model.money / 15, (@@all_codebooks - player_model.equipment).length].min
            )
          end
        end
      end
    end
  end
end
