class Task < ApplicationRecord
  DEADLINE_SOON_DAYS = 3

  validates :title, presence: true

  def deadline_label
    return if deadline_date.blank?

    deadline_date.strftime("%d/%m/%Y")
  end

  def deadline_state(reference_date: Date.current)
    return :completed if completed?
    return :pending if deadline_date.blank?
    return :overdue if deadline_date < reference_date
    return :due_soon if deadline_date <= reference_date + DEADLINE_SOON_DAYS

    :upcoming
  end

  def status_label(reference_date: Date.current)
    state = deadline_state(reference_date: reference_date)

    return "ครบกำหนดวันนี้" if state == :due_soon && deadline_date == reference_date

    {
      completed: "เสร็จแล้ว",
      overdue: "เลยกำหนด",
      due_soon: "ใกล้ถึงกำหนด",
      upcoming: "รอดำเนินการ",
      pending: "รอดำเนินการ"
    }.fetch(state)
  end
end
