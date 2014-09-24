require 'rails_helper'

describe LHS::Data do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService)
  end

  let(:item) do
    data[0]
  end

  context 'save' do

    it 'persists changes on the backend' do
      stub_request(:post, item.href)
      .with(body: item._raw_.merge(name: 'Steve').to_json)
      item.name = 'Steve'
      expect(item.save).to eq true
    end

    it 'returns false if persting goes wrong' do
      stub_request(:post, item.href)
      .with(body: item._raw_.to_json)
      .to_return(status: 500)
      expect(item.save).to eq false
    end
  end

  context 'save!' do

    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
      .with(body: item._raw_.to_json)
      .to_return(status: 500)
      expect(->{ item.save! }).to raise_error ServerError
    end
  end
end
