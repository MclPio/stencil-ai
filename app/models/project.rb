class Project < ApplicationRecord
  belongs_to :user
  has_one :artifact, dependent: :destroy
  has_one :conversation, dependent: :destroy

  after_create -> { create_conversation; create_artifact }
end
