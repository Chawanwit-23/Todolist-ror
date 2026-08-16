module TasksHelper
  THAI_MONTH_NAMES = %w[
    มกราคม กุมภาพันธ์ มีนาคม เมษายน พฤษภาคม มิถุนายน
    กรกฎาคม สิงหาคม กันยายน ตุลาคม พฤศจิกายน ธันวาคม
  ].freeze

  def thai_month_and_year(date)
    "#{THAI_MONTH_NAMES.fetch(date.month - 1)} #{date.year + 543}"
  end

  def calendar_event_class(task, date)
    return "task-calendar__event--completed" if task.completed?
    return "task-calendar__event--overdue" if date < Date.current

    "task-calendar__event--upcoming"
  end
end
