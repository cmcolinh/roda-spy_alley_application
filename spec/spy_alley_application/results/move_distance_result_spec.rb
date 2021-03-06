# frozen_string_literal: true

RSpec.describe SpyAlleyApplication::Results::MoveDistanceResult do
  let(:player_model, &->{PlayerMock::new})
  let(:opponent_models, &->{[PlayerMock::new(seat: 6)]})
  let(:decks_model, &->{DecksModelMock::new})
  let(:change_orders, &->{ChangeOrdersMock::new})
  let(:get_move_options_result, &->{CallableStub::new})
  let(:get_move_result, &->{CallableStub::new})
  let(:action_hash) do
    {
      player_action: 'roll',
    }
  end
  let(:get_move_distance_result) do
    ->(opts:) do
      SpyAlleyApplication::Results::MoveDistanceResult::new(
        move_options_from: ->(options){opts},
        get_move_options_result: get_move_options_result,
        get_move_result: get_move_result
      )
    end
  end
  describe '#call' do
    it 'calls get_move_options_result if move_options_from returns multiple locations' do
      get_move_distance_result.(opts: ['16', '2s']).call(
        player_model: player_model,
        change_orders: change_orders,
        action_hash: action_hash,
        opponent_models: opponent_models,
        decks_model: decks_model,
        move_distance: 3
      )
      expect(get_move_options_result.called_with[:move_options]).to match_array(['16', '2s'])
    end

    it 'does not call get_move_result if move_options_from returns multiple locations' do
      get_move_distance_result.(opts: ['16', '2s']).call(
        player_model: player_model,
        change_orders: change_orders,
        action_hash: action_hash,
        opponent_models: opponent_models,
        decks_model: decks_model,
        move_distance: 3
      )
      expect(get_move_result.called_with).to eql({})
    end

    it 'calls get_move_result if move_options_from returns a single location' do
      get_move_distance_result.(opts: ['18']).call(
        player_model: player_model,
        change_orders: change_orders,
        action_hash: action_hash,
        opponent_models: opponent_models,
        decks_model: decks_model,
        move_distance: 3
      )
      expect(get_move_result.called_with[:space_to_move]).to eql('18')
    end

    it 'does not call get_move_options_result if move_options_from returns a single location' do
      get_move_distance_result.(opts: ['0']).call(
        player_model: player_model,
        change_orders: change_orders,
        action_hash: action_hash,
        opponent_models: opponent_models,
        decks_model: decks_model,
        move_distance: 3
      )
      expect(get_move_options_result.called_with).to eql({})
    end
  end
end
