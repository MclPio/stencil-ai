class WeeklyConsumption < ApplicationRecord
  belongs_to :user

  validates :credits, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  FREE_TOKEN_LIMIT = 25_000
  SUBSCRIBER_TOKEN_LIMIT = 100_000_000
  ADMIN_TOKEN_LIMIT = 100_000_000
end
