class Project < ApplicationRecord
  belongs_to :user
  has_one :spec, dependent: :destroy
  has_one :conversation, dependent: :destroy
end
