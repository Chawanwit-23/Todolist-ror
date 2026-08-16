class AddDeadlineDateToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :deadline_date, :date
  end
end
