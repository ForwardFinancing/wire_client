require 'test_helper'

describe WireClient do
  describe :today do
    it 'should return a Date instance if Time.zone is present' do
      original_zone = Time.zone
      Time.zone = 'Eastern Time (US & Canada)'
      assert_equal WireClient.today, Date.new(2016, 8, 11)
      Time.zone = original_zone
    end

    it 'should return a Date instance even if Time.zone is not present' do
      original_zone = Time.zone
      Time.zone = nil
      assert_equal WireClient.today, Date.new(2016, 8, 11)
      Time.zone = original_zone
    end
  end
end
