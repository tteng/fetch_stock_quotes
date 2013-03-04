class AddFinalScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags, :final_score, :float, :default => 0.0
  end
end
