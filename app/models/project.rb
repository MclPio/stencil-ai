class Project < ApplicationRecord
  belongs_to :user
  has_one :spec, dependent: :destroy
end
