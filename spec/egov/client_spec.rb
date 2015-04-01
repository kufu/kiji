require 'spec_helper'

describe Egov::Client do
  describe '#hoge' do
    client = Egov::Client.new

    it 'should return hoge' do
      expect(client.hoge).to eq 'hoge'
    end
  end
end
