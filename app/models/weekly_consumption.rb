class WeeklyConsumption < ApplicationRecord
  belongs_to :user

  validates :credits, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
