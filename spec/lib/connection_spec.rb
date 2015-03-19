require_relative '../spec_helper'

describe OHConnection do
  describe "default attributes" do
    it "must include Faraday methods" do
      OHConnection.must_include Faraday
    end
  end
end
