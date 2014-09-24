require 'rails_helper'

describe LHS::Data do

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json)
  end

  let(:item) do
    data[0]
  end

  context 'item setter' do

    it 'sets the value for an existing attribute' do
      expect(item.name = 'Steve').to eq 'Steve'
      expect(item.name).to eq 'Steve'
      expect(item._raw_['name']).to eq 'Steve'
    end

    it 'sets things to nil' do
      item.name = 'Steve'
      expect(item.name = nil).to eq nil
      expect(item.name).to eq nil
    end
  end
end
