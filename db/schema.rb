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

ActiveRecord::Schema.define(version: 20170418090804) do

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "date"
    t.string   "platform"
    t.string   "branch"
    t.string   "suite"
    t.string   "link"
    t.string   "tests"
    t.string   "server"
    t.string   "build"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "user"
    t.integer  "all"
    t.integer  "failed"
    t.string   "appid"
    t.string   "failed_tests"
    t.string   "pending_tests"
    t.string   "user_email"
    t.string   "app_type"
    t.string   "locale"
    t.string   "api_version"
    t.integer  "job_id"
  end

  add_index "reports", ["job_id"], name: "index_reports_on_job_id"

  create_table "suites", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "tag"
  end

  create_table "tests", force: :cascade do |t|
    t.string   "title"
    t.integer  "suiteId"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "suite"
    t.string   "steps"
    t.string   "tags"
  end

end
