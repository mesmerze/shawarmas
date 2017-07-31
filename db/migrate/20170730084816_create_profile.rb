class CreateProfile < ActiveRecord::Migration[5.1]
  def up
    create_table :profiles do |col|
      col.belongs_to :user, index: { unique: true }, foreign_key: true
      col.string :photo
      col.string :city
      col.string :screen_name
      col.string :country
      col.string :first_name
      col.string :last_name
    end
  end

  def down
    drop_table :profiles
  end
end
