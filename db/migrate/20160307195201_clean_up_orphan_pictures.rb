class CleanUpOrphanPictures < ActiveRecord::Migration
  def change

    count = Picture.where("user_id NOT IN (select id from users)").count
    puts "Picture: deleting #{count} orphans"
    puts Picture.where("user_id NOT IN (select id from users)").delete_all
    
    add_foreign_key "pictures", "users", name: "pictures_user_id_fk"
  end
end
