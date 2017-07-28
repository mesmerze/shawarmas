class CreateUser < ActiveRecord::Migration[5.1]
  def up
    create_table :users do |col|
      col.string :user_id
      col.string :access_token
      col.string :expires_in
    end
  end

  def down
    drop_table :users
  end
end
