require 'test_helper'
 
class Post < ActiveRecord::Base
  def self.what_are_you
    "a post"
  end
end

class Developers
  def self.do_the_monkey
    (%w(DEVELOPERS) * 4).join(" ")
  end
end

class Developer < ActiveRecord::Base
end

module Namespaced
  class Post < ActiveRecord::Base
  end
end

module Double
  module Namespaced
    class Post < ActiveRecord::Base
    end
  end
end

 
class PluralizedModelsTest < Test::Unit::TestCase
  def test_creating_pluralized_models
    assert defined?(Posts)
    assert defined?(Namespaced::Posts)
    assert defined?(Double::Namespaced::Posts)
  end
  
  def test_not_creating_pluralized_models_if_already_exist
    assert defined?(Developers)
    assert Developers.respond_to?(:do_the_monkey)
    assert !Developers.respond_to?(:find)
  end
  
  def test_pluralized_model_initializes_singular_class
    assert_equal Posts.new.class, Post
  end
  
  def test_pluralized_model_responds_to_singular_class_methods
    assert Posts.respond_to?(:what_are_you)
    assert Posts.respond_to?(:find)
  end
  
  def test_pluralized_model_returns_methods_list_of_a_singular_class
    assert_equal Posts.methods, Post.methods
  end
  
  def test_pluralized_model_calls_singular_class_methods
    assert_equal Posts.find(:all), Post.find(:all)
    assert_equal Posts.first, Post.first
  end
end