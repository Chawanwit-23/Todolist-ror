class TasksController < ApplicationController
  def index
    @tasks = Task.all
    @task = Task.new
    prepare_task_view
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      @created_task = @task
      respond_with_task_changes("เพิ่มงานสำเร็จ", turbo_template: :create, reset_form: true)
    else
      @tasks = Task.all
      prepare_task_view
      respond_to do |format|
        format.turbo_stream { render :form_errors, status: :unprocessable_content }
        format.html { render :index, status: :unprocessable_content }
      end
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      message = if params.dig(:task, :completed).present?
                  @task.completed? ? "ทำงานเสร็จแล้ว" : "นำงานกลับมาทำอีกครั้ง"
                else
                  "แก้ไขงานสำเร็จ"
                end
      respond_with_task_changes(
        message,
        turbo_template: :update,
        load_tasks: @task.saved_change_to_completed?
      )
    else
      error_message = @task.errors.full_messages.to_sentence
      @task.reload
      prepare_view_context
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = error_message
          render :update_error, status: :unprocessable_content
        end
        format.html do
          redirect_to tasks_path(view: @view_mode, month: @calendar_month.strftime("%Y-%m")),
                      alert: error_message,
                      status: :see_other
        end
      end
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_with_task_changes("ลบงานสำเร็จ", turbo_template: :destroy, html_status: :see_other)
  end

  private

  def task_params
    params.require(:task).permit(:title, :completed, :deadline_date)
  end

  def respond_with_task_changes(message, turbo_template:, html_status: :found, reset_form: false, load_tasks: true)
    @tasks = Task.all if load_tasks
    @task = Task.new if reset_form
    load_tasks ? prepare_task_view : prepare_view_context

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = message
        render turbo_template
      end
      format.html do
        redirect_to tasks_path(view: @view_mode, month: @calendar_month.strftime("%Y-%m")),
                    notice: message,
                    status: html_status
      end
    end
  end

  def prepare_task_view
    prepare_view_context
    return unless @view_mode == "calendar"

    prepare_calendar
  end

  def prepare_view_context
    @view_mode = params[:view] == "calendar" ? "calendar" : "list"
    @calendar_month = parsed_calendar_month
  end

  def prepare_calendar
    calendar_start = @calendar_month.beginning_of_week(:monday)
    calendar_end = @calendar_month.end_of_month.end_of_week(:monday)

    @calendar_days = (calendar_start..calendar_end).to_a
    @tasks_by_deadline = @tasks.select { |task| task.deadline_date.present? }.group_by(&:deadline_date)
    @unscheduled_count = @tasks.count { |task| task.deadline_date.blank? }
  end

  def parsed_calendar_month
    Date.strptime(params[:month].to_s, "%Y-%m").beginning_of_month
  rescue Date::Error, ArgumentError
    Date.current.beginning_of_month
  end
end
