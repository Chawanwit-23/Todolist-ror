require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_HEADERS = { "Accept" => "text/vnd.turbo-stream.html" }.freeze

  test "turbo title update replaces only the changed task" do
    task = tasks(:one)

    patch task_path(task),
          params: { task: { title: "ชื่อใหม่" }, view: "list" },
          headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_select "turbo-stream[action='replace'][target='task_#{task.id}']", count: 1
    assert_select "turbo-stream[target='flash-messages']", count: 1
    assert_select "turbo-stream[target='task-form']", count: 0
    assert_select "turbo-stream[target='task-summary']", count: 0
    assert_select "turbo-stream[target='task-list-container']", count: 0
    assert_select "turbo-stream[target='todo-count']", count: 0
  end

  test "turbo completion update replaces the task and summary only" do
    task = tasks(:one)

    patch task_path(task),
          params: { task: { completed: true }, view: "list" },
          headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_select "turbo-stream[action='replace'][target='task_#{task.id}']", count: 1
    assert_select "turbo-stream[action='replace'][target='task-summary']", count: 1
    assert_select "turbo-stream[target='task-form']", count: 0
    assert_select "turbo-stream[target='task-list-container']", count: 0
    assert_select "turbo-stream[target='todo-count']", count: 0
  end

  test "turbo create appends one task and resets only related sections" do
    post tasks_path,
         params: { task: { title: "งานใหม่" }, view: "list" },
         headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_select "turbo-stream[action='append'][target='task-list']", count: 1
    assert_select "turbo-stream[action='replace'][target='task-form']", count: 1
    assert_select "turbo-stream[action='replace'][target='task-summary']", count: 1
    assert_select "turbo-stream[action='update'][target='todo-count']", count: 1
    assert_select "turbo-stream[target='task-list-container']", count: 0
    assert_select "turbo-stream[target='task-calendar-container']", count: 0
  end

  test "turbo create in calendar view updates the calendar instead of the list" do
    post tasks_path,
         params: {
           task: { title: "งานในปฏิทิน", deadline_date: "2026-09-15" },
           view: "calendar",
           month: "2026-09"
         },
         headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_select "turbo-stream[action='update'][target='task-calendar-container']", count: 1
    assert_select "turbo-stream[target='task-list']", count: 0
    assert_select "turbo-stream[target='task-list-container']", count: 0
  end

  test "turbo destroy removes one task without reloading the form or list" do
    task = tasks(:one)

    delete task_path(task),
           params: { view: "list" },
           headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_select "turbo-stream[action='remove'][target='task_#{task.id}']", count: 1
    assert_select "turbo-stream[action='replace'][target='task-summary']", count: 1
    assert_select "turbo-stream[action='update'][target='todo-count']", count: 1
    assert_select "turbo-stream[target='task-form']", count: 0
    assert_select "turbo-stream[target='task-list-container']", count: 0
    assert_select "turbo-stream[target='task-calendar-container']", count: 0
  end

  test "updates a task title and deadline" do
    task = tasks(:one)

    patch task_path(task), params: {
      task: {
        title: "ประชุมกับทีม",
        deadline_date: "2026-10-20"
      }
    }

    assert_redirected_to tasks_path(view: "list", month: Date.current.strftime("%Y-%m"))
    assert_equal "ประชุมกับทีม", task.reload.title
    assert_equal Date.new(2026, 10, 20), task.deadline_date
  end

  test "shows tasks on the selected calendar month" do
    Task.create!(title: "ส่งรายงาน", deadline_date: Date.new(2026, 9, 15))

    get tasks_path, params: { view: "calendar", month: "2026-09" }

    assert_response :success
    assert_select ".task-calendar__title", text: "กันยายน 2569"
    assert_select "[data-date='2026-09-15'] .task-calendar__event", text: /ส่งรายงาน/
  end

  test "falls back to the current month when calendar month is invalid" do
    get tasks_path, params: { view: "calendar", month: "not-a-month" }

    assert_response :success
    expected_month = "#{TasksHelper::THAI_MONTH_NAMES.fetch(Date.current.month - 1)} #{Date.current.year + 543}"
    assert_select ".task-calendar__title", text: expected_month
  end

  test "creates a task with a deadline date" do
    assert_difference("Task.count", 1) do
      post tasks_path, params: {
        task: {
          title: "ส่งรายงาน",
          deadline_date: "2026-09-15"
        }
      }
    end

    task = Task.last
    assert_equal Date.new(2026, 9, 15), task.deadline_date
  end
end
