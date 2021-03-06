# frozen_string_literal: true

require 'dry/validation'

module SpyAlleyApplication
  class Validator
    class InvalidOptionsValidator < Dry::Validation::Contract
        option :user, -> user {user || NonLoggedInUser::new}
      params do
        required(:last_action_id).filled(:string)
        required(:user).filled
      end

      rule(:last_action_id) do
        key.failure({text: "no info found for action_id #{values[:last_action_id]}", status: 404})
      end

      def call(input)
        input.reject!{|k, v| k.eql?(:user)}
        input[:user] = user
        super
      end
    end
  end
end
