require 'bundler/setup'
require 'dry/initializer'
require 'spy_alley_application/change_orders'
require 'spy_alley_application/validator'
require 'spy_alley_application/execute_action'

class PlayerMock
  extend Dry::Initializer
  option :game, default: ->{1}
  option :seat, default: ->{1}
  option :money, default: ->{50}
  option :location, default: ->{'1'}
  option :spy_identity, default: ->{'french'}
  option :equipment, default: ->{['spanish password', 'spanish codebook', 'french key']}
  option :wild_cards, default: ->{0}
  option :move_cards, default: ->{{1 => 0, 2 => 0, 3 => 0, 4 => 1, 5 => 0, 6 => 1}}
end

class TargetPlayerMock
  def game
    1
  end

  def seat
    2
  end

  def money
    5
  end

  def location
    '1'
  end

  def spy_identity
    'german'
  end

  def equipment
    ['russian password', 'russian codebook', 'french key']
  end

  def wild_cards
    2
  end

  def move_cards
    {1 => 2, 2 => 0, 3 => 0, 4 => 1, 5 => 0, 6 => 0}
  end
end

class ChangeOrdersMock
  def initialize
    @money_added      = 0
    @money_subtracted = 0
    @top_move_card    = 0
    @target           = {}
  end
  def add_die_roll(player:, rolled:)
    self
  end
  def add_admin_die_roll(player:, result_chosen:)
    self
  end
  def add_move_card_action(player:, card_to_add:)
    self
  end
  def add_use_move_card(player:, card_to_use:)
    self
  end
  def add_move_action(player:, space:)
    self
  end
  def add_money_action(player:, amount:, reason:)
    @money_added += amount
    @target[:add_money_action] = player[:seat]
    self
  end
  def subtract_money_action(player:, amount:, paid_to:)
    @money_subtracted += amount
    @target[:subtract_money_action] = player[:seat]
    self
  end
  def add_pass_action
    self
  end
  def add_equipment_action(player:, equipment:)
    @target[:add_equipment_action] = player[:seat]
    self
  end
  def subtract_equipment_action(player:, equipment:)
    @target[:subtract_equipment_action] = player[:seat]
    self
  end
  def add_action(**action)
    self
  end
  def eliminate_player_action(player:)
    @target[:eliminate_player_action] = player[:seat]
    self
  end
  def choose_new_spy_identity_action(player:, identity_chosen:)
    self
  end
  def add_wild_card_action(player:)
    self
  end
  def subtract_wild_card_action(player:)
    self
  end
  def add_move_options(options:)
    self
  end
  def add_buy_equipment_option(equipment:, limit:)
    self
  end
  def add_draw_top_move_card(player:, top_move_card:)
    @top_move_card = top_move_card
    self
  end
  def add_draw_top_free_gift_card(player:, top_free_gift_card:)
    self
  end
  def money_added
    @money_added.dup
  end
  def money_subtracted
    @money_subtracted.dup
  end
  def target
    @target.dup
  end
  def top_move_card
    @top_move_card.dup
  end
  def add_game_victory(player:, reason:)
    self
  end
  def add_spy_eliminator_option(options:)
    @target[:add_spy_eliminator_option] = options
    self
  end
  def add_confiscate_materials_option(options:)
    @target[:add_confiscate_materials_option] = options
    self
  end
  def add_move_back_two_spaces_result
    self
  end
  def add_choose_new_spy_identity_option(options:, return_player:)
    self
  end
  def add_next_player_up(seat:)
    @target[:seat] = seat
    self
  end
  def add_top_level_options(options = {})
    @target = options
    self
  end
end

class DecksModelMock
  extend Dry::Initializer
  option :top_move_card, default: ->{1}
  option :top_free_gift_card, default: ->{'russian password'}
end

class Count
  @@initialized ||= []

  def self.enable(klass)
    return if @@initialized.include?(klass)
    @@initialized.push(klass)
    klass.prepend Module.new{
      (klass.instance_methods - klass.superclass.instance_methods - [:enable]).each do |method|
        define_method(method) do |*args|
          @called[method] = (@called[method] || 0) + 1
          super(*args)
        end
      end

      def initialize(*args)
        @called = Hash.new{|h, k| h[k] = 0}
        super(*args)
      end

      def times_called
        @called.dup
      end
    }
  end
end
Count.enable(ChangeOrdersMock)

class CallableStub
  def initialize
    @called_with = {}
  end
  def call(options={})
    @called_with = options
    options[:change_orders]
  end
  def called_with
    @called_with.dup
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
