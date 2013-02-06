class AddWeiboScoreToTags < ActiveRecord::Migration
  def change
    add_column :tags, :weibo_rank,  :integer, default: 0
    add_column :tags, :weibo_score, :float,   default: 0.0
  end
end
