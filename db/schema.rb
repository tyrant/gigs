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

ActiveRecord::Schema.define(version: 2020_05_04_095206) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "acts", force: :cascade do |t|
    t.string "name"
    t.string "ticketmaster_id"
    t.datetime "created_at", default: "2020-05-05 02:05:15", null: false
    t.datetime "updated_at", default: "2020-05-05 02:05:15", null: false
    t.index ["ticketmaster_id"], name: "index_acts_on_ticketmaster_id"
  end

  create_table "gigs", force: :cascade do |t|
    t.bigint "act_id"
    t.bigint "venue_id"
    t.string "ticketmaster_id"
    t.datetime "at"
    t.datetime "created_at", default: "2020-05-05 02:05:15", null: false
    t.datetime "updated_at", default: "2020-05-05 02:05:15", null: false
    t.index ["act_id"], name: "index_gigs_on_act_id"
    t.index ["ticketmaster_id"], name: "index_gigs_on_ticketmaster_id"
    t.index ["venue_id"], name: "index_gigs_on_venue_id"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "ticketmaster_id"
    t.datetime "created_at", default: "2020-05-05 02:05:15", null: false
    t.datetime "updated_at", default: "2020-05-05 02:05:15", null: false
    t.index ["ticketmaster_id"], name: "index_venues_on_ticketmaster_id"
  end

end
