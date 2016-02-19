class ImprovingDatabasePerformane < ActiveRecord::Migration
  def change
    add_index "users",    "username",  unique: true
    add_index "protips",  "public_id", unique: true
    add_index "protips",  "score",     unique: false
    add_index "comments", "protip_id", unique: false
    add_index "badges",   "user_id",   unique: false
  end
end
