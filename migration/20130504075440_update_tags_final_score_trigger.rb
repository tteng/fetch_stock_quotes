class UpdateTagsFinalScoreTrigger < ActiveRecord::Migration
   def up
    sql = <<-EOF
      DELIMITER |
      DROP TRIGGER IF EXISTS auto_update_tags_final_score;
      CREATE TRIGGER auto_update_tags_final_score BEFORE UPDATE ON tags FOR EACH ROW
      IF NOT (NEW.weibo_score <=> OLD.weibo_score AND NEW.google_score <=> OLD.google_score AND NEW.cn21_score <=> OLD.cn21_score AND NEW.soso_score <=> OLD.soso_score) THEN
        SET NEW.final_score = (NEW.weibo_score + NEW.google_score + NEW.cn21_score + NEW.soso_score)/3;
      END IF
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
    execute "drop trigger auto_update_tags_final_score"
  end
end
