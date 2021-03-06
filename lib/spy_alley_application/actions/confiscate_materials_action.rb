# frozen_string_literal: true

require 'dry/initializer'
require 'spy_alley_application/results/next_player_up'

module SpyAlleyApplication
  module Actions
    class ConfiscateMaterialsAction
      extend Dry::Initializer
      option :next_player_up_for, default: ->{SpyAlleyApplication::Results::NextPlayerUp::new}
      option :confiscation_price, default: ->{
        %w(french german spanish italian american russian).map do |nationality|
          [['password', 15],['codebook', 5],['disguise', 15],['key', 50]].map do |equipment, price|
            ["#{nationality} #{equipment}", price]
          end.to_h
        end.reduce({}, :merge).tap{|h| h['wild card'] = 50}
      }
      def call(player_model:, opponent_models:, change_orders:, action_hash:, decks_model: nil)
        target_player_model = get_target_player_model_from(opponent_models, action_hash)
        equipment_to_confiscate = action_hash[:equipment_to_confiscate]
        price = confiscation_price[equipment_to_confiscate]
        if equipment_to_confiscate.eql? 'wild card'
          change_orders = change_orders.add_wild_card_action(
            player: {game: player_model.game, seat: player_model.seat}
          ).subtract_wild_card_action(
            player: {game: target_player_model.game, seat: target_player_model.seat}
          )
        else
          change_orders = change_orders.add_equipment_action(
            player: {game: player_model.game, seat: player_model.seat},
            equipment: equipment_to_confiscate
          ).subtract_equipment_action(
            player: {game: target_player_model.game, seat: target_player_model.seat},
            equipment: equipment_to_confiscate
          )
        end
        change_orders = change_orders.subtract_money_action(
          player: {game: player_model.game, seat: player_model.seat},
          amount:  price,
          paid_to: :"seat_#{target_player_model.seat}"
        ).add_money_action(
          player: {game: target_player_model.game, seat: target_player_model.seat},
          amount: price,
          reason: 'equipment confiscated'
        ).add_action(action_hash.dup)
        next_player_up_for.(
          player_model: player_model,
          opponent_models: opponent_models,
          change_orders: change_orders,
          action_hash: action_hash,
          turn_complete?: true # the current player's turn will *not* continue
        )
      end

      def get_target_player_model_from(opponent_models, action_hash)
        seat = action_hash[:player_to_confiscate_from].gsub('seat_', '').to_i
        opponent_models.select{|m| m.seat.eql? seat}.first
      end
    end
  end
end
