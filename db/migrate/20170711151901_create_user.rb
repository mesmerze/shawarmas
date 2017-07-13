class CreateUser < ActiveRecord::Migration[5.1]
  def up
  	create_table :users do |t|
  		t.string :user_id
      t.string :access_token
      t.string :expires_in
  	end
  end

  def down
  	drop_table :users
  end
end
