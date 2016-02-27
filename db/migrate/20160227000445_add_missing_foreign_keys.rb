class AddMissingForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "badges", "users", name: "badges_user_id_fk"
    add_foreign_key "comments", "protips", name: "comments_protip_id_fk"
    add_foreign_key "comments", "users", name: "comments_user_id_fk"
    add_foreign_key "likes", "users", name: "likes_user_id_fk"
    add_foreign_key "pictures", "users", name: "pictures_user_id_fk"
    add_foreign_key "protips", "users", name: "protips_user_id_fk"
  end
end
