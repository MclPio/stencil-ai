class ProjectsController < ApplicationController
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
      redirect_to project_conversation_path(@project), notice: "Project was successfully created."
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      respond_to do |format|
        format.html { redirect_to projects_path }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
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
end
