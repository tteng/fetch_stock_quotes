class CreateUpdateStockQuotesProcedure < ActiveRecord::Migration

   def up
    sql = <<-EOF
       DELIMITER //
       DROP PROCEDURE IF EXISTS prcd_update_stock_quotes;
       CREATE PROCEDURE prcd_update_stock_quotes (
         IN symbol varchar(10),
         IN name   varchar(255), 
         IN market_capitalization varchar(255), 
         IN last_trade_price_only float, 
         IN change_with_percent_change varchar(255), 
         IN previous_close float, 
         IN day_range varchar(255), 
         IN fifty_two_week_range varchar(255), 
         IN average_daily_volume int(11), 
         IN short_ratio float, 
         IN p_e_ratio float,
         IN price_eps_estimate_current_year float, 
         IN price_eps_estimate_next_year float, 
         IN peg_ratio float, 
         IN one_yr_target_price float, 
         IN dividend_per_share float, 
         IN book_value float 
       )
       BEGIN 
         IF NOT EXISTS(select * from stock_quotes sq where sq.symbol=symbol) THEN
           INSERT INTO stock_quotes(
             symbol, 
             name, 
             market_capitalization, 
             last_trade_price_only, 
             change_with_percent_change, 
             previous_close, 
             day_range, 
             fifty_two_week_range, 
             average_daily_volume, 
             short_ratio, 
             p_e_ratio, 
             price_eps_estimate_current_year, 
             price_eps_estimate_next_year, 
             peg_ratio, 
             one_yr_target_price, 
             dividend_per_share, 
             book_value,
             created_at,
             updated_at                       
           ) values (   
              symbol, 
              name, 
              market_capitalization, 
              last_trade_price_only, 
              change_with_percent_change, 
              previous_close, 
              day_range, 
              fifty_two_week_range, 
              average_daily_volume, 
              short_ratio, 
              p_e_ratio, 
              price_eps_estimate_current_year, 
              price_eps_estimate_next_year, 
              peg_ratio, 
              one_yr_target_price, 
              dividend_per_share, 
              book_value,
              now(),
              now()                             
           );
         ELSE
           UPDATE stock_quotes sq set
              sq.name                                 =       name                             ,
              sq.market_capitalization                =       market_capitalization            ,
              sq.last_trade_price_only                =       last_trade_price_only            ,
              sq.change_with_percent_change           =       change_with_percent_change       ,
              sq.previous_close                       =       previous_close                   ,
              sq.day_range                            =       day_range                        ,
              sq.fifty_two_week_range                 =       fifty_two_week_range             ,
              sq.average_daily_volume                 =       average_daily_volume             ,
              sq.short_ratio                          =       short_ratio                      ,
              sq.p_e_ratio                            =       p_e_ratio                        ,
              sq.price_eps_estimate_current_year      =       price_eps_estimate_current_year  ,
              sq.price_eps_estimate_next_year         =       price_eps_estimate_next_year     ,
              sq.peg_ratio                            =       peg_ratio                        ,
              sq.one_yr_target_price                  =       one_yr_target_price              ,
              sq.dividend_per_share                   =       dividend_per_share               ,
              sq.book_value                           =       book_value                       ,
              sq.updated_at                           =       now()
            WHERE sq.symbol = symbol;
         END IF;
       END  
       //
       DELIMITER ;
    EOF
    config   = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]
    p sql
    cmd = %Q{ mysql -u #{username} --password="#{password}" #{database} -e "#{sql}" }
    system cmd
  end

  def down
    sql= "DROP PROCEDURE prcd_update_stock_quotes"
    ActiveRecord::Base.connection.execute sql
  end

end
