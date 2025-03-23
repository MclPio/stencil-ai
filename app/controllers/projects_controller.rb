class ProjectsController < ApplicationController
  include SpecHelper
  def new
    @project = Current.user.projects.new
  end

  def index
    @projects = Current.user.projects
  end

  def create
    @project = Current.user.projects.new(project_params)
    if @project.save
      redirect_to project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to projects_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_idea
  end

  private

  def project_params
    params.expect(project: [ :title ])
  end

  # def assistant_message(questions)
  #   message = "[assistant]"
  #   questions.each do |question|
  #     message << " " + question + "\n"
  #   end
  #   message
  # end
end
