class Artifact < ApplicationRecord
  belongs_to :user

  def has_artifacts
    true # need to put logic later
  end
end
