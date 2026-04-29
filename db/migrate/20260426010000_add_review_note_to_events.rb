class AddReviewNoteToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :review_note, :text
  end
end
