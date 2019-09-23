# frozen_string_literal: true

require 'dry/validation'
require 'dry/initializer'

module SpyAlleyApplication
  class Validator
    class ChooseNewIdentityValidator < Dry::Validation::Contract
      option :nationality_options
      params do
        required(:player_action).filled(:string, eql?: 'choose_spy_identity')
        optional(:nationality).filled(:string)
      end
      rule(:nationality) do
        key.failure({text: 'not a valid nationality', status: 422}) if values[:player_action].eql?('choose_spy_identity') && !nationality_options.include?(values[:nationality])
      end
    end
  end
end