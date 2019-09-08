# frozen_string_literal: true

RSpec.describe SpyAlleyApplication::ChangeOrders do
  let (:change_orders){SpyAlleyApplication::ChangeOrders::new}
  describe '#get_action_hash' do
    before(:each) do
      change_orders.add_action(action_hash: {player_action: 'roll'})
    end
    let(:calling_method) do
      -> do
        change_orders.get_action_hash
      end
    end
    it 'returns a hash representation of the ActionHashElement node' do
      expect(calling_method.()).to eql(action_hash: {player_action: 'roll'})
    end

    it 'removes the action_hash node from @changes' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(-1)
    end
  end

  describe '#add_die_roll' do
    let(:calling_method) do
      -> do
        change_orders.add_die_roll(
          player: {game: 1, seat: 1},
          rolled: 1
        )
      end
    end
    it 'adds two total nodes' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(2)
    end

    it 'adds one DieRoll element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select{|e| e.is_a?(SpyAlleyApplication::ChangeOrders::DieRoll)}.length}
        .by(1)
      )
    end

    it 'will not allow a number other than one through six to be rolled' do
      expect{change_orders.add_die_roll(player: {game: 1, seat: 1}, rolled: 7)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#add_use_move_card' do
    let(:calling_method) do
      -> do
        change_orders.add_use_move_card(
          player: {game: 1, seat: 1},
          card_to_use: 1
        )
      end
    end
    it 'adds three total nodes' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(3)
    end

    it 'adds one UseMoveCard element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::UseMoveCard)
        end.length}.by(1)
      )
    end

    it 'adds one PlaceCardAtBottomOfDeck element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::PlaceCardAtBottomOfMoveCardDeck)
        end.length}
        .by(1)
      )
    end

    it 'will not allow a move card other than one through six to be used' do
      expect{change_orders.add_use_move_card(player: {game: 1, seat: 1}, card_to_use: 7)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#add_move_action' do
    let(:calling_method) do
      -> do
        change_orders.add_move_action(
          player: {game: 1, seat: 1},
          space: 3
        )
      end
    end
    it 'adds two total nodes' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(2)
    end

    it 'adds one MoveAction element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::MoveAction)
        end.length}.by(1)
      )
    end

    it 'will not allow a move to a location other than one through 32 to be registered' do
      expect{change_orders.add_move_action(player: {game: 1, seat: 1}, space: 50)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end

    it 'will not allow a move to a location other than an integer to be registered' do
      expect{change_orders.add_move_action(player: {game: 1, seat: 1}, space: '1')}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#add_money_action' do
    let(:calling_method) do
      -> do
        change_orders.add_money_action(
          player: {game: 1, seat: 1},
          amount: 15,
          reason: 'passing start'
        )
      end
    end
    it 'adds two total nodes' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(2)
    end

    it 'adds one AddMoney element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::AddMoney)
        end.length}.by(1)
      )
    end

    it 'will not allow adding a negative amount of money' do
      expect{change_orders.add_money_action(player: {game: 1, seat: 1}, amount: -1, reason: 'ok')}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end

    it 'will not allow adding a zero amount of money' do
      expect{change_orders.add_money_action(player: {game: 1, seat: 1}, amount: 0, reason: 'ok')}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end

    it 'will not allow adding a string amount of money' do
      expect{change_orders.add_money_action(player: {game: 1, seat: 1}, amount: '15', reason: 'ok')}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#subtract_money_action' do
    let(:calling_method) do
      -> do
        change_orders.subtract_money_action(
          player:  {game: 1, seat: 1},
          amount:  15,
          paid_to: 'passing start'
        )
      end
    end
    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one SubtractMoney element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::SubtractMoney)
        end.length}.by(1)
      )
    end

    it 'will not allow subtracting a negative amount of money' do
      expect{change_orders.subtract_money_action(player: {game: 1, seat: 1}, amount: -1, paid_to: :seat_2)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end

    it 'will not allow subtracting a zero amount of money' do
      expect{change_orders.subtract_money_action(player: {game: 1, seat: 1}, amount: 0, paid_to: :seat_2)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end

    it 'will not allow subtracting a string amount of money' do
      expect{change_orders.subtract_money_action(player: {game: 1, seat: 1}, amount: '15', paid_to: :seat_2)}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#add_pass_action' do
    let(:calling_method){->{change_orders.add_pass_action}}
    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end
  end

  describe '#add_equipment_action' do
    let(:calling_method) do
      -> do
        change_orders.add_equipment_action(
          player:    {game: 1, seat: 1},
          equipment: 'russian password',
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one AddEquipment element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::AddEquipment)
        end.length}.by(1)
      )
    end

    it 'will not allow adding invalid equipment' do
      expect{change_orders.add_equipment_action(player: {game: 1, seat: 1}, equipment: 'invalid equipment')}.to(
        raise_error(Dry::Types::ConstraintError)
      )
    end
  end

  describe '#subtract_equipment_action' do
    let(:calling_method) do
      -> do
        change_orders.subtract_equipment_action(
          player:    {game: 1, seat: 1},
          equipment: 'russian password',
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one SubtractEquipment element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::SubtractEquipment)
        end.length}.by(1)
      )
    end

    it 'will not allow subtracting invalid equipment' do
      expect{
        change_orders.subtract_equipment_action(
          player: {game: 1, seat: 1}, equipment: 'invalid equipment'
        )
      }.to(raise_error(Dry::Types::ConstraintError))
    end
  end

  describe '#add_action' do
    let(:calling_method) do
      -> do
        change_orders.add_action(
          action_hash: {
            player_action: 'roll',
            result: {rolled: 1}
          }
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end
  end

  describe '#eliminate_player_action' do
    let(:calling_method) do
      -> do
        change_orders.eliminate_player_action(
          player: {game: 1, seat: 1}
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one EliminatePlayer element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::EliminatePlayer)
        end.length}.by(1)
      )
    end
  end

  describe '#add_wild_card_action' do
    let(:calling_method) do
      -> do
        change_orders.add_wild_card_action(
          player: {game: 1, seat: 1}
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one AddWildCard element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::AddWildCard)
        end.length}.by(1)
      )
    end
  end

  describe '#subtract_wild_card_action' do
    let(:calling_method) do
      -> do
        change_orders.subtract_wild_card_action(
          player: {game: 1, seat: 1}
        )
      end
    end

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one SubtractWildCard element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::SubtractWildCard)
        end.length}.by(1)
      )
    end
  end

  describe '#add_move_options' do
    let(:calling_method){->{change_orders.add_move_options(options: [19, 25])}}

    it 'adds one total node' do
      expect{calling_method.()}.to change{change_orders.changes.length}.by(1)
    end

    it 'adds one NextActionOptions element' do
      expect{calling_method.()}.to(
        change{change_orders.changes.select do |e|
          e.is_a?(SpyAlleyApplication::ChangeOrders::NextActionOptions)
        end.length}.by(1)
      )
    end     
  end
end