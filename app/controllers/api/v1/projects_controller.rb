class Api::V1::ProjectsController < ApplicationController
    before_action :authorized
    

    # include: {project: {include: :project_submitter}}
    def create
        project = Project.create(project_params)
        
        if project.valid?
          projects = Project.all
          render json: { projects: projects}, include: [:project_submitter, :project_developer], status: :created
        else
          render json: { error: 'failed to create project' }, status: :not_acceptable
        end
    end

    def update
      @project = Project.find(params[:id])
      @project.update(project_params)
      if @project.valid?
        render json: { projects: @project}, status: :updated
      else
        render json: { error: 'failed to update project' }, status: :not_acceptable
      end
    end
    
    def index
         projects = Project.all
        sorted_projects = projects.sort_by { |a| [a.num_up_votes ? 1 : 0, a.num_up_votes] }.reverse!
        
        render json: {projects: sorted_projects}, include: [:project_submitter, :project_developer], status: :accepted
    end

    def start_project
      project = Project.find(params[:project_id])
      project.project_started = true
      project.project_start_date = Time.now.strftime("%m/%d/%Y")
      project.inprogress = true
      project.save
      all_claimed_projects = UserSavedProject.where(claimed: true)
      render json: {claimedProjects: UserSavedProject.where(claimed_by_id: current_user.id)}, include: {project: {include: :project_submitter}}, status: :created
    end
    private
      
    def project_params
        params.require(:project).permit(
            :project_submitter_id,
            :project_developer_id, 
            :project_name, 
            :project_problem_statement, 
            :project_idea_summary, 
            :is_claimed, 
            :project_start_date, 
            :project_end_date, 
            :project_started, 
            :in_progress,
            :completed,
            :abandoned,
            :abandoned_date,
            :archived,
            :archived_date,
            :num_up_votes,
            :num_down_votes,
            :sponsor_amount, :project_id)
    end
end

