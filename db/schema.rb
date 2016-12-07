# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161207222630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "badges", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "why"
    t.string   "image_name"
    t.string   "provider"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "badges", ["user_id"], name: "index_badges_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "article_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "likes_count", default: 0
  end

  add_index "comments", ["article_id"], name: "index_comments_on_article_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "job_subscriptions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "jobs_url",           null: false
    t.string   "company_name",       null: false
    t.string   "contact_email",      null: false
    t.string   "stripe_customer_id"
    t.string   "subscribed_at"
  end

  create_table "jobs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "role_type"
    t.string   "title"
    t.string   "location"
    t.string   "source"
    t.string   "company"
    t.string   "company_url"
    t.string   "company_logo"
    t.string   "author_name"
    t.string   "author_email"
    t.datetime "expires_at"
    t.text     "stripe_charge"
  end

  add_index "jobs", ["expires_at"], name: "index_jobs_on_expires_at", using: :btree

  create_table "letsencrypt_plugin_challenges", force: :cascade do |t|
    t.text     "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "letsencrypt_plugin_settings", force: :cascade do |t|
    t.text     "private_key"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "likable_id"
    t.integer  "user_id"
    t.string   "likable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "likes", ["user_id", "likable_type", "likable_id"], name: "index_likes_on_user_id_and_likable_type_and_likable_id", unique: true, using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "pictures", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pictures", ["user_id"], name: "index_pictures_on_user_id", using: :btree

  create_table "protips", force: :cascade do |t|
    t.string   "public_id"
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.integer  "user_id"
    t.float    "score"
    t.datetime "featured_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "tags",                 default: [],                 array: true
    t.integer  "likes_count",          default: 0
    t.integer  "views_count",          default: 0
    t.boolean  "flagged",              default: false
    t.text     "type",                                 null: false
    t.datetime "published_at"
    t.datetime "archived_at"
    t.boolean  "save_recording"
    t.text     "recording_id"
    t.datetime "recording_started_at"
    t.integer  "subscribers",          default: [],    null: false, array: true
  end

  add_index "protips", ["created_at"], name: "index_protips_on_created_at", using: :btree
  add_index "protips", ["public_id"], name: "index_protips_on_public_id", unique: true, using: :btree
  add_index "protips", ["score"], name: "index_protips_on_score", using: :btree
  add_index "protips", ["tags"], name: "index_protips_on_tags", using: :gin
  add_index "protips", ["type"], name: "index_protips_on_type", using: :btree
  add_index "protips", ["user_id"], name: "index_protips_on_user_id", using: :btree
  add_index "protips", ["views_count"], name: "index_protips_on_views_count", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "avatar"
    t.citext   "slug"
    t.string   "website"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "github"
    t.string   "youtube_url"
    t.string   "blog_feed"
    t.string   "location"
    t.text     "about"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "views_count", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "avatar"
    t.string   "title"
    t.string   "location"
    t.string   "country"
    t.string   "city"
    t.string   "state_name"
    t.string   "company"
    t.text     "about"
    t.integer  "team_id"
    t.string   "api_key"
    t.boolean  "admin"
    t.boolean  "receive_newsletter",                       default: true
    t.boolean  "receive_weekly_digest",                    default: true
    t.string   "last_ip"
    t.datetime "last_email_sent"
    t.datetime "last_request_at"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.citext   "username"
    t.citext   "email"
    t.string   "encrypted_password",           limit: 128
    t.string   "confirmation_token",           limit: 128
    t.string   "remember_token",               limit: 128
    t.string   "skills",                                   default: [],                  array: true
    t.string   "github_id"
    t.string   "twitter_id"
    t.string   "github"
    t.string   "twitter"
    t.string   "color",                                    default: "#111"
    t.integer  "karma",                                    default: 1
    t.datetime "banned_at"
    t.text     "marketing_list"
    t.datetime "email_invalid_at"
    t.text     "stream_key"
    t.datetime "partner_last_contribution_at"
    t.string   "partner_asm_username"
    t.string   "partner_slack_username"
    t.string   "partner_email"
    t.integer  "partner_coins"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["email_invalid_at"], name: "index_users_on_email_invalid_at", using: :btree
  add_index "users", ["marketing_list"], name: "index_users_on_marketing_list", using: :btree
  add_index "users", ["receive_newsletter"], name: "index_users_on_receive_newsletter", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["skills"], name: "index_users_on_skills", using: :gin
  add_index "users", ["stream_key"], name: "index_users_on_stream_key", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "badges", "users", name: "badges_user_id_fk"
  add_foreign_key "comments", "protips", column: "article_id", name: "comments_protip_id_fk"
  add_foreign_key "comments", "users", name: "comments_user_id_fk"
  add_foreign_key "likes", "users", name: "likes_user_id_fk"
  add_foreign_key "pictures", "users", name: "pictures_user_id_fk"
  add_foreign_key "protips", "users", name: "protips_user_id_fk"
end
