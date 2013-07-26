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

ActiveRecord::Schema.define(version: 20130726075248) do

  create_table "repo_scrape_states", force: true do |t|
    t.string   "language"
    t.integer  "page",       default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "contributors_crawled",  default: false
    t.boolean  "collaborators_crawled", default: false
    t.integer  "page"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories_collaborators", id: false, force: true do |t|
    t.integer "repository_id"
    t.integer "user_id"
  end

  add_index "repositories_collaborators", ["repository_id"], name: "index_repositories_collaborators_on_repository_id"
  add_index "repositories_collaborators", ["user_id"], name: "index_repositories_collaborators_on_user_id"

  create_table "repositories_contributors", id: false, force: true do |t|
    t.integer "repository_id"
    t.integer "user_id"
  end

  add_index "repositories_contributors", ["repository_id"], name: "index_repositories_contributors_on_repository_id"
  add_index "repositories_contributors", ["user_id"], name: "index_repositories_contributors_on_user_id"

  create_table "users", force: true do |t|
    t.string   "login"
    t.integer  "github_id"
    t.text     "avatar_url"
    t.string   "url"
    t.string   "html_url"
    t.string   "followers_url"
    t.string   "following_url"
    t.string   "starred_url"
    t.string   "organizations_url"
    t.string   "repos_url"
    t.string   "type"
    t.string   "name"
    t.string   "company"
    t.string   "blog"
    t.string   "location"
    t.string   "email"
    t.string   "bio"
    t.integer  "public_repos"
    t.integer  "followers"
    t.integer  "following"
    t.boolean  "followers_crawled", default: false
    t.boolean  "following_crawled", default: false
    t.text     "languages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_followers", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "follower_id"
  end

end
