# frozen_string_literal: true

RSpec.describe SpyAlleyApplication::Results::Embassy do
  nationalities = %w(french german spanish italian american russian)
  equipment = %w(password, disguise, codebook, key)
  german_set = equipment.map{|e| "german #{e}"}
  all_equipment = nationalities.map{|n| equipment.map{|e| "#{n} #{e}"}}.flatten
  let(:change_orders, &->{ChangeOrdersMock::new})
  let(:opponent_models, &->{[PlayerMock::new(seat: 3)]})
  let(:action_hash, &->{{player_action: 'roll'}})
  let(:next_player_up, &->{CallableStub::new})
  let(:embassy) do
    SpyAlleyApplication::Results::Embassy::new(next_player_up_for: next_player_up)
  end
  describe '#call' do
    [true, false].each do |same_embassy_as_player|
      (0..4).each do |num_equipment_owned|
        (0..2).each do |wild_cards|
          spy_identity = same_embassy_as_player ? 'french' : 'german'
          equipment_owned = german_set + num_equipment_owned.times.map.with_index do |e, i|
            "french #{e}"
          end
          win = (num_equipment_owned + wild_cards >= 4) && same_embassy_as_player
          describe "when the player is #{'not ' unless same_embassy_as_player}the same nationality " +
            "as the embassy with #{num_equipment_owned} equipment owned " +
            "and #{wild_cards} wild card#{'s' unless wild_cards.eql?(1)}" do

            let(:player_model) do
              PlayerMock.new(
                equipment: equipment_owned,
                wild_cards: wild_cards,
                spy_identity: spy_identity
              )
            end
            if win
              it 'calls change_orders#add_game_victory' do
                expect{
                  embassy.(
                    player_model: player_model,
                    opponent_models: opponent_models,
                    change_orders: change_orders,
                    action_hash: action_hash,
                    nationality: 'french'
                  )
                }.to change{change_orders.times_called[:add_game_victory]}.by(1)
              end
              it 'marks turn_complete? as false' do
                embassy.(
                  player_model: player_model,
                  opponent_models: opponent_models,
                  change_orders: change_orders,
                  action_hash: action_hash,
                  nationality: 'french'
                )
                expect(next_player_up.called_with[:turn_complete?]).to be false
              end
            else
              it 'does not call change_orders#add_game_victory' do
                expect{
                  embassy.(
                    player_model: player_model,
                    opponent_models: opponent_models,
                    change_orders: change_orders,
                    action_hash: action_hash,
                    nationality: 'french'
                  )
                }.not_to change{change_orders.times_called[:add_game_victory]}
              end
              it 'marks turn_complete? as true' do
                embassy.(
                  player_model: player_model,
                  opponent_models: opponent_models,
                  change_orders: change_orders,
                  action_hash: action_hash,
                  nationality: 'french'
                )
                expect(next_player_up.called_with[:turn_complete?]).to be true
              end
            end
          end
        end
      end
     end
  end
end
