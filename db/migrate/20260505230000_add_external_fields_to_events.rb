class AddExternalFieldsToEvents < ActiveRecord::Migration[8.0]
  CATEGORY_REWRITES = {
    "general" => "community",
    "concert" => "music",
    "art" => "art_exhibition",
    "exhibition" => "art_exhibition",
    "party" => "nightlife",
    "sports" => "sports_wellness"
  }.freeze

  def up
    add_column :events, :external_source, :string
    add_column :events, :external_id, :string
    add_column :events, :external_url, :string
    add_column :events, :remote_poster_url, :string
    add_column :events, :external_is_free, :boolean
    add_column :events, :ticket_url_kind, :string
    add_column :events, :imported_at, :datetime
    add_column :events, :end_date, :datetime

    add_index :events, [ :external_source, :external_id ],
              unique: true,
              where: "external_source IS NOT NULL AND external_id IS NOT NULL",
              name: "index_events_on_external_source_and_external_id"
    add_index :events, :end_date
    add_index :events, :imported_at

    CATEGORY_REWRITES.each do |old_value, new_value|
      execute <<~SQL.squish
        UPDATE events
        SET category = #{quote(new_value)}
        WHERE category = #{quote(old_value)}
      SQL
    end
  end

  def down
    remove_index :events, name: "index_events_on_external_source_and_external_id"
    remove_index :events, :end_date
    remove_index :events, :imported_at

    remove_column :events, :external_source
    remove_column :events, :external_id
    remove_column :events, :external_url
    remove_column :events, :remote_poster_url
    remove_column :events, :external_is_free
    remove_column :events, :ticket_url_kind
    remove_column :events, :imported_at
    remove_column :events, :end_date
  end
end
