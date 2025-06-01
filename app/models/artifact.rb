class Artifact < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  belongs_to :project

  def has_artifacts
    true # need to put logic later
  end
end
