ActiveRecord::Schema.define(version: 0) do
  self.verbose = false

  create_table :correct_accounts do |t|
    t.string :email
    t.timestamps
  end

  add_index "correct_accounts", ["email"], name: "index_correct_accounts_on_email", unique: true, using: :btree

  create_table :correct_addresses do |t|
    t.string :city
    t.integer :correct_user_id
    t.string :state
    t.timestamps
  end

  add_index "correct_addresses", ["correct_user_id"], name: "index_correct_addresses_on_user_id", unique: true, using: :btree
  add_index "correct_addresses", ["city", "correct_user_id"], name: "index_correct_addresses_on_city_and_correct_user", unique: true, using: :btree

  create_table :correct_attachments do |t|
    t.integer :attachable_id
    t.string :attachable_type
    t.string :name
    t.timestamps
  end

  add_index "correct_attachments", ["name", "attachable_id", "attachable_type"], name: "index_correct_attachments_on_name_attachable_id_and_type", unique: true, using: :btree
  add_index "correct_attachments", ["attachable_id", "attachable_type"], name: "index_correct_attachments_on_attachable_id_and_attachable_type", unique: true, using: :btree
  add_index "correct_attachments", ["name"], name: "index_correct_attachments_on_name", unique: true, using: :btree

  create_table :correct_people do |t|
    t.string :city
    t.string :email
    t.string :name
    t.string :state
    t.timestamps
  end

  add_index "correct_people", ["state", "city", "email"], name: "index_correct_people_on_city_and_state_and_email", unique: true, using: :btree

  create_table :correct_posts do |t|
    t.text :content
    t.string :title
    t.timestamps
  end

  create_table :correct_users do |t|
    t.string :email
    t.string :name
    t.timestamps
  end

  create_table :correct_user_credentials do |t|
    t.string :oauth_token
    t.string :refresh_token
    t.integer :correct_user_id
    t.timestamps
  end
  add_index "correct_user_credentials", ["correct_user_id"], name: "index_correct_user_credentials_on_user_id", unique: true, using: :btree

  create_table :correct_user_phones do |t|
    t.string :text
    t.integer :phoneable_id
    t.string :phoneable_type
    t.timestamps
  end
  add_index "correct_user_phones", ["phoneable_id", "phoneable_type"], name: "index_correct_user_phones_on_id_and_type", unique: true, using: :btree

  create_table :wrong_accounts do |t|
    t.string :email
    t.timestamps
  end

  create_table :wrong_addresses do |t|
    t.string :city
    t.string :state
    t.integer :wrong_user_id
    t.timestamps
  end

  add_index "wrong_addresses", ["wrong_user_id"], name: "index_wrong_addresses_on_user_id", using: :btree

  create_table :wrong_attachments do |t|
    t.integer :attachable_id
    t.string :attachable_type
    t.string :name
    t.timestamps
  end

  create_table :wrong_businesses do |t|
    t.string :city
    t.string :name
    t.string :state
    t.timestamps
  end

  create_table :wrong_people do |t|
    t.string :city
    t.string :email
    t.string :name
    t.string :state
    t.timestamps
  end

  create_table :wrong_posts do |t|
    t.text :content
    t.string :title
    t.timestamps
  end

  create_table :wrong_users do |t|
    t.string :email
    t.string :name
    t.timestamps
  end

  execute 'CREATE VIEW new_correct_people AS '\
          'SELECT * FROM correct_people '\
          'WHERE created_at = updated_at'

  create_table :blob do |t|
    t.timestamps
  end
end
