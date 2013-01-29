class CreateStockQuotes < ActiveRecord::Migration
  def up
    create_table :stock_quotes do |t|
      t.string :symbol, limit: 10
      t.string :name
      t.string :market_capitalization
      t.float  :last_trade_price_only
      t.string :change_with_percent_change
      t.float  :previous_close
      t.string :day_range
      t.string :fifty_two_week_range
      t.integer :average_daily_volume
      t.float  :short_ratio
      t.float  :p_e_ratio
      t.float  :price_eps_estimate_current_year
      t.float  :price_eps_estimate_next_year
      t.float  :peg_ratio
      t.float  :one_yr_target_price
      t.float  :dividend_per_share
      t.float  :book_value
      t.timestamps
    end
  end

  def down
    drop_table :stock_quotes
  end
end
