class AddGoogleRankGoogleScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags, :google_rank, :integer, :default => 0
    add_column :tags, :google_score, :integer, :default => 0
  end
end
