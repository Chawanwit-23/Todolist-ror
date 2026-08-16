module TasksHelper
  THAI_MONTH_NAMES = %w[
    มกราคม กุมภาพันธ์ มีนาคม เมษายน พฤษภาคม มิถุนายน
    กรกฎาคม สิงหาคม กันยายน ตุลาคม พฤศจิกายน ธันวาคม
  ].freeze

  def thai_month_and_year(date)
    "#{THAI_MONTH_NAMES.fetch(date.month - 1)} #{date.year + 543}"
  end

  def calendar_event_class(task, _date)
    "task-calendar__event--#{task.deadline_state.to_s.tr('_', '-')}"
  end
end
