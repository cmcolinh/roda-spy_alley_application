# frozen_string_literal: true

RSpec.describe SpyAlleyApplication::Results::Embassy::American do
  let(:player_model, &->{PlayerMock::new})
  let(:opponent_models, &->{[PlayerMock::new(seat: 2)]})
  let(:change_orders, &->{ChangeOrdersMock::new})
  let(:action_hash, &->{{player_action: 'roll'}})
  let(:embassy, &->{CallableStub::new})
  let(:french_embassy) do
    SpyAlleyApplication::Results::Embassy::American::new(embassy: embassy)
  end
  describe '#call' do
    it "embassy with nationality: 'american'" do
      french_embassy.(
        player_model: player_model,
        opponent_models: opponent_models,
        change_orders: change_orders,
        action_hash:  action_hash
      )
      expect(embassy.called_with[:nationality]).to eql('american')
    end
  end
end
