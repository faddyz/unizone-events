class AddEditorScoreToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :editor_score, :integer
  end
end
