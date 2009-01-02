require 'rubygems'
require 'active_support'
require 'active_support/test_case'

require 'test/unit'
 
gem 'activerecord'
require 'active_record'

RAILS_ROOT = File.dirname(__FILE__)
RAILS_ENV = "pluralized_models_test"

require File.join(File.dirname(__FILE__), '../init')
 
ActiveRecord::Base.configurations[RAILS_ENV] = {:adapter => "sqlite3", :dbfile => "pluralized_models.sqlite3"}
ActiveRecord::Base.establish_connection RAILS_ENV
 
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :posts, :force => true do |t|
    t.string :title
    t.text :body
  end

  create_table :developers, :force => true do |t|
    t.text :name
  end
  
  create_table :namespaced_posts, :force => true do |t|
    t.string :title
    t.text :body
  end

  create_table :double_namespaced_posts, :force => true do |t|
    t.string :title
    t.text :body
  end
end
ActiveRecord::Migration.verbose = true
