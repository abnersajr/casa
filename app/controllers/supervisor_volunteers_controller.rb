class SupervisorVolunteersController < ApplicationController
  after_action :verify_authorized

  def create
    authorize :supervisor_volunteer
    supervisor_volunteer = supervisor_volunteer_parent.supervisor_volunteers.find_or_create_by!(supervisor_volunteer_params)
    supervisor_volunteer.is_active = true unless supervisor_volunteer&.is_active?
    supervisor_volunteer.save

    redirect_to after_action_path(supervisor_volunteer_parent)
  end

  def unassign
    authorize :supervisor_volunteer
    volunteer = Volunteer.find(params[:id])
    supervisor_volunteer = volunteer.supervisor_volunteer
    supervisor = volunteer.supervisor
    supervisor_volunteer.is_active = false
    supervisor_volunteer.save!
    flash_message = "#{volunteer.display_name} was unassigned from #{supervisor.display_name}."

    redirect_to after_action_path(supervisor), notice: flash_message
  end

  private

  def supervisor_volunteer_params
    params.require(:supervisor_volunteer).permit(:supervisor_id, :volunteer_id)
  end

  def after_action_path(resource)
    if resource.supervisor?
      edit_supervisor_path(resource)
    else
      edit_volunteer_path(resource)
    end
  end

  def supervisor_volunteer_parent
    if params[:supervisor_id]
      Supervisor.find(params[:supervisor_id])
    else
      Supervisor.find(supervisor_volunteer_params[:supervisor_id])
    end
  end
end
