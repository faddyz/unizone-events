class AddStatusToEventsAndAttendances < ActiveRecord::Migration[8.0]
  def up
    add_column :events, :status, :string, null: false, default: "draft"
    add_column :events, :published_at, :datetime
    add_index :events, :status

    execute <<~SQL.squish
      UPDATE events
      SET status = CASE
        WHEN approved = TRUE THEN 'published'
        ELSE 'submitted'
      END
    SQL

    execute <<~SQL.squish
      UPDATE events
      SET published_at = updated_at
      WHERE status = 'published' AND published_at IS NULL
    SQL

    add_column :attendances, :status_v2, :string, null: false, default: "going"

    execute <<~SQL.squish
      UPDATE attendances
      SET status_v2 = CASE status
        WHEN 'attending' THEN 'going'
        WHEN 'maybe' THEN 'interested'
        WHEN 'declined' THEN 'not_going'
        ELSE 'going'
      END
    SQL

    remove_column :attendances, :status, :string
    rename_column :attendances, :status_v2, :status
  end

  def down
    add_column :attendances, :legacy_status, :string, null: false, default: "attending"

    execute <<~SQL.squish
      UPDATE attendances
      SET legacy_status = CASE status
        WHEN 'going' THEN 'attending'
        WHEN 'interested' THEN 'maybe'
        WHEN 'not_going' THEN 'declined'
        ELSE 'attending'
      END
    SQL

    remove_column :attendances, :status, :string
    rename_column :attendances, :legacy_status, :status

    remove_index :events, :status if index_exists?(:events, :status)
    remove_column :events, :status, :string
    remove_column :events, :published_at, :datetime
  end
end
