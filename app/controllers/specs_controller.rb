class SpecsController < ApplicationController
  def show
    @spec = Project.find(params[:project_id]).spec
  end
end
