class Add21cnRankAnd21cnScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags,  "cn21_rank",  :integer, :default => 0
    add_column :tags,  "cn21_score", :integer, :default => 0
  end
end
