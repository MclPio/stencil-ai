class ProjectsController < ApplicationController
  def new
    @project = Current.user.projects.new
  end

  def create
    @project = Current.user.projects.new(project_params)
    if @project.save
      redirect_to project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @project = Current.user.projects.find(params[:id])
    # @spec = @project.specs.last || @project.specs.build
  end

  def update_idea
    @project = Current.user.projects.find(params[:id])
    message = params[:message].to_s
    tagged_message = "[user] #{message}"

    @project.update(idea: @project.idea + "\n" + tagged_message)
    # GenerateSpecJob.perform_later(@project.id)
    render turbo_stream: turbo_stream.update("chat_area", partial: "projects/chat", locals: { project: @project })
  end

  private

  def project_params
    params.expect(project: [ :title, :idea ])
  end
end
