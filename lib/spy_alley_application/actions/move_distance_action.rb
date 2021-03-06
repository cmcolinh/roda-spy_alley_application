# frozen_string_literal: true

require 'dry/initializer'
require 'spy_alley_application/actions/move_distance_action/roll_action'
require 'spy_alley_application/actions/move_distance_action/admin_roll_action'
require 'spy_alley_application/actions/move_distance_action/move_card_action'
require 'spy_alley_application/results/move_distance_result'

module SpyAlleyApplication
  module Actions
    class MoveDistanceAction
      extend Dry::Initializer
      option :move_action
      option :move_result_for, default: ->{SpyAlleyApplication::Results::MoveDistanceResult::new}
      def call(player_model:, change_orders:, action_hash:, opponent_models: nil, decks_model:)
        change_orders, move_distance = move_action.(
          player_model:  player_model,
          change_orders: change_orders,
          action_hash:   action_hash
        )
        move_result_for.(
          player_model:  player_model,
          change_orders: change_orders,
          opponent_models: opponent_models,
          decks_model: decks_model,
          action_hash:   action_hash,
          move_distance: move_distance,
        )
      end
    end
  end
end
