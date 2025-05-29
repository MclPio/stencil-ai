class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  has_many :projects, dependent: :destroy

  enum :account_type, { free: 0, paid: 1, admin: 2 }, prefix: true
end
