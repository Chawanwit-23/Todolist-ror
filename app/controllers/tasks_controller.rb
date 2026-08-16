class TasksController < ApplicationController
  def index
    @tasks = Task.all
    @task = Task.new
    prepare_calendar
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      respond_with_task_changes("เพิ่มงานสำเร็จ")
    else
      @tasks = Task.all
      prepare_calendar
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
      respond_with_task_changes(message)
    else
      @tasks = Task.all
      prepare_calendar
      respond_to do |format|
        format.turbo_stream { render :refresh, status: :unprocessable_content }
        format.html { render :index, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_with_task_changes("ลบงานสำเร็จ", html_status: :see_other)
  end

  private

  def task_params
    params.require(:task).permit(:title, :completed, :deadline_date)
  end

  def respond_with_task_changes(message, html_status: :found)
    @tasks = Task.all
    @task = Task.new
    prepare_calendar

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = message
        render :refresh
      end
      format.html do
        redirect_to tasks_path(view: @view_mode, month: @calendar_month.strftime("%Y-%m")),
                    notice: message,
                    status: html_status
      end
    end
  end

  def prepare_calendar
    @view_mode = params[:view] == "calendar" ? "calendar" : "list"
    @calendar_month = parsed_calendar_month
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
