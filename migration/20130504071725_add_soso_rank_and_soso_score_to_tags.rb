class AddSosoRankAndSosoScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags, :soso_rank, :integer
    add_column :tags, :soso_score, :integer
  end
end
