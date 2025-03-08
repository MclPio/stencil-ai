class Project < ApplicationRecord
  belongs_to :user
  has_many :specs, dependent: :destroy
end
