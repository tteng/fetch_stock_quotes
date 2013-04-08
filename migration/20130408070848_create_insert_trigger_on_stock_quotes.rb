class CreateInsertTriggerOnStockQuotes < ActiveRecord::Migration
  def up
    sql = <<-EOF
      DELIMITER |
      CREATE TRIGGER stock_quotes_trigger AFTER INSERT ON stocks FOR EACH ROW
      INSERT INTO stock_quotes(symbol, created_at, updated_at) values(New.ticker, now(), now())
      |
      DELIMITER ;
    EOF
    config   = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]
    cmd = %Q{ mysql -u #{username} --password="#{password}" #{database} -e "#{sql}" }
    p cmd
    system cmd
  end

  def down
    execute "drop trigger stock_quotes_trigger"
  end
end
