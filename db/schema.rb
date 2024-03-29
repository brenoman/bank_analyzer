# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_240_222_142_114) do
  create_table 'card_numbers', force: :cascade do |t|
    t.string 'card_number'
    t.integer 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_card_numbers_on_user_id'
  end

  create_table 'devices', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'merchants', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'transactions', force: :cascade do |t|
    t.integer 'merchant_id', null: false
    t.integer 'user_id', null: false
    t.string 'card_number'
    t.datetime 'transaction_date'
    t.decimal 'transaction_amount', precision: 10, scale: 2
    t.integer 'device_id'
    t.boolean 'has_cbk'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'card_number_id'
    t.index ['card_number_id'], name: 'index_transactions_on_card_number_id'
    t.index ['merchant_id'], name: 'index_transactions_on_merchant_id'
    t.index ['user_id'], name: 'index_transactions_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'transactions', 'merchants'
  add_foreign_key 'transactions', 'users'
end
