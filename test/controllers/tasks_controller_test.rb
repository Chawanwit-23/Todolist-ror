require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
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
