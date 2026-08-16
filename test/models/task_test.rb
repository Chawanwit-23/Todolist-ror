require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "classifies deadline urgency around the reference date" do
    today = Date.new(2026, 8, 16)

    assert_equal :pending, Task.new.deadline_state(reference_date: today)
    assert_equal :overdue, Task.new(deadline_date: today - 1).deadline_state(reference_date: today)
    assert_equal :due_soon, Task.new(deadline_date: today + 3).deadline_state(reference_date: today)
    assert_equal :upcoming, Task.new(deadline_date: today + 4).deadline_state(reference_date: today)
    assert_equal :completed, Task.new(completed: true, deadline_date: today - 1).deadline_state(reference_date: today)
  end

  test "uses clear status labels for urgent deadlines" do
    today = Date.new(2026, 8, 16)

    assert_equal "ครบกำหนดวันนี้", Task.new(deadline_date: today).status_label(reference_date: today)
    assert_equal "ใกล้ถึงกำหนด", Task.new(deadline_date: today + 2).status_label(reference_date: today)
    assert_equal "เลยกำหนด", Task.new(deadline_date: today - 1).status_label(reference_date: today)
    assert_equal "เสร็จแล้ว", Task.new(completed: true).status_label(reference_date: today)
  end
end
