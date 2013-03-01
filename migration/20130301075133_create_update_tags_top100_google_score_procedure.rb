class CreateUpdateTagsTop100GoogleScoreProcedure < ActiveRecord::Migration
  def up
    sql = <<-EOF
       DELIMITER //
       DROP PROCEDURE IF EXISTS prcd_update_tags_google_score;
       CREATE PROCEDURE prcd_update_tags_google_score ()
       BEGIN 
         UPDATE tags SET google_score = 0;
         UPDATE tags as a inner join
           (select l.id, @curRow := @curRow -1  as row_number from tags l join (select @curRow := 101) r order by l.google_rank desc limit 100) as b
           on a.id = b.id 
           set a.google_score = b.row_number;
       END  
       //
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
    sql= "DROP PROCEDURE prcd_update_tags_google_score"
    ActiveRecord::Base.connection.execute sql
  end
end
