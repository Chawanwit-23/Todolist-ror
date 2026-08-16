class Task < ApplicationRecord
  validates :title, presence: true

  def deadline_label
    return if deadline_date.blank?

    deadline_date.strftime("%d/%m/%Y")
  end
end