class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :null =>false
    end

    # This is hack for MySQL databases beacause they are case insensitive
    # by default.
    if ActiveRecord::Base.configurations[RAILS_ENV]['adapter'] == 'mysql'
      execute %{ALTER TABLE tags MODIFY name varchar(255) COLLATE utf8_bin NOT NULL}
    end

    add_index :tags, :name, :unique => true
  end

  def self.down
    drop_table :tags
  end
end
