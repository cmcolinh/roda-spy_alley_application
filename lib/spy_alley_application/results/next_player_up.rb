# frozen_string_literal: true

require 'dry/initializer'

module SpyAlleyApplication
  module Results
    class NextPlayerUp
      extends Dry::Initializer
      option :next_player_options, default: -> do
        SpyAlleyApplication::Results::NextPlayerUp::NextPlayerOptions::new
      end
      def call(options = {})
        player_model, opponent_models, change_orders, turn_complete = get_vars_from(options)
        next_seat_up = turn_complete ? get_next_seat_from(player_model, opponent_models) : player_model.seat
        if turn_complete
          change_orders = next_player_options.(
            next_player_model: opponent_models.select{|p| p.seat.eql? next_seat_up}
            opponent_models: opponent_models.reject{|p| p.seat.eql? next_seat_up} + [player_model],
            change_orders: change_orders
          )
        end
        change_orders = change_orders.add_next_player_up(seat: next_seat_up)
      end

      private
      def get_next_seat_from(player_model, opponent_models, change_orders)
        opponent_seats = opponent_models.map(&:seat)
        opponent_seats.select{|seat| seat > player_model.seat}.min || opponent_seats.min
      end

      def get_vars_from(options)
        keys = [:player_model, :opponent_models, :change_orders, :turn_complete?]
        errors = keys.select{|key| !options.has_key(key)}
        errors = "#{'s' if errors.length > 1}#{': ' unless errors.empty?}#{errors.join(', ')}"

        raise ArgumentError "missing keyword#{errors}"  unless errors.empty?

        [
          options[:player_model],
          options[:opponent_models],
          options[:change_orders],
          options[:turn_complete?]
        ]
      end
    end
  end
end