require "test_helper"

class WeeklyConsumptionTest < ActiveSupport::TestCase
  setup do
    @weekly_consumption = weekly_consumptions(:one)
  end
  test "can add to credits" do
    @weekly_consumption.credits = 0
    @weekly_consumption.credits += 5
    assert 5, @weekly_consumption.credits
  end

  test "no negative credits" do
    @weekly_consumption.credits = -5
    assert_not @weekly_consumption.valid?, "WeeklyConsumption should be invalid with negative credits"
    assert_includes @weekly_consumption.errors[:credits], "must be greater than or equal to 0"
    assert_no_difference 'WeeklyConsumption.count' do
      @weekly_consumption.save
    end
  end
end
