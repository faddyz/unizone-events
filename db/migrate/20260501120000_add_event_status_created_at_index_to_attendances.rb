class AddEventStatusCreatedAtIndexToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_index :attendances,
      [ :event_id, :status, :created_at ],
      name: "index_attendances_on_event_status_created_at",
      if_not_exists: true
  end
end
