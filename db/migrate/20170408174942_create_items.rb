class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :tariff
      t.string :itype
      t.string :auth_token
      t.string :email
      t.timestamps
    end
  end
end
