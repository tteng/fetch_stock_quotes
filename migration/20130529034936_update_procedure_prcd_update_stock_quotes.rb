class UpdateProcedurePrcdUpdateStockQuotes < ActiveRecord::Migration

  def up
    add_column :stock_quotes, :schange, :float 
    add_column :stock_quotes, :change_in_percent, :string, :limit => 10
    #[:symbol,:last_trade_price_only,:change,:change_in_percent]
    sql = <<-EOF
       DELIMITER //
       DROP PROCEDURE IF EXISTS prcd_update_stock_quotes;
       CREATE PROCEDURE prcd_update_stock_quotes (
         IN symbol varchar(10),
         IN last_trade_price_only float, 
         IN schange float,
         IN change_in_percent varchar(10) 
       )
       BEGIN 
         IF NOT EXISTS(select * from stock_quotes sq where sq.symbol=symbol) THEN
           INSERT INTO stock_quotes(
             symbol, 
             last_trade_price_only, 
             schange, 
             change_in_percent, 
             created_at,
             updated_at                       
           ) values (   
              symbol, 
              last_trade_price_only, 
              schange, 
              change_in_percent, 
              now(),
              now()                             
           );
         ELSE
           UPDATE stock_quotes sq set
              sq.last_trade_price_only                =       last_trade_price_only            ,
              sq.schange                              =       schange                          ,
              sq.change_in_percent                    =       change_in_percent                ,
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
    remove_column :stock_quotes, :schange
    remove_column :stock_quotes, :change_in_percent
    sql= "DROP PROCEDURE prcd_update_stock_quotes"
    ActiveRecord::Base.connection.execute sql
  end

end
