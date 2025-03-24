class ProjectsController < ApplicationController
  include SpecHelper

  before_action :set_project, only: %i[ update destroy ]

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
    if @project.update(project_params)
      redirect_to projects_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_idea
  end

  def destroy
    @project.destroy
    redirect_to projects_path
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

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
