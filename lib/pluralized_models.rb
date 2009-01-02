module PluralizedModels
  # Pluralized models generation for ActiveRecord::Base descendants.
  #
  # Example:
  #
  #   class Post < ActiveRecord::Base
  #   end
  #  
  # will create a Posts class that will proxy all classmethods to Post, so that
  #
  #   Posts.all, Posts.first, Posts.find(...), Posts.scoped_by_date(...) 
  #
  # methods will work.
  # Namespaced models are supported as well. 
  #
  # Pluralized models are not destructive to classes or models that already exist, so,
  # for example, if you do already have a Posts class in your application, it will not be 
  # touched at all.
  module ActiveRecord
    module ClassMethods
      def self.extended(base)
        base.class_eval do 
          class << self
            alias_method_chain :inherited, :pluralized_models
          end
        end
      end

      def inherited_with_pluralized_models(child)
        create_pluralized_model_for(child) if can_create_pluralized_model_for?(child)
        inherited_without_pluralized_models(child)
      end

      # Can we create a pluralized model for class +klass+?
      #
      # This method is here to avoid "creating" anything for anonymous classes. We identify
      # anonymous classes by comparing first character of their <tt>to_s</tt> representation with "#"
      def can_create_pluralized_model_for?(klass)
        !klass.to_s.match(/^\#/)
      end
      
      # Create pluralized model for class +klass+.
      #
      # Does not do anything for classes or modules that already exist.
      #
      # Pluralized model initializer points to singular model initializer, 
      # <tt>respond_to?</tt> and <tt>methods</tt> methods take singular model's methods 
      # into account. Every other class method is proxied to singular model 
      # using <tt>method_missing</tt>.
      def create_pluralized_model_for(klass)
        pluralized_class_name = klass.to_s.pluralize
        
        if pluralized_class = Object.module_eval(%(
          defined?(#{pluralized_class_name}) ? false : #{pluralized_class_name} = Class.new
        ), __FILE__, __LINE__)
          pluralized_class.class_eval %(
            class << self                                       # class << self
              def new(*args)                                    #   def new(*args)
                #{klass}.new(*args)                             #     Post.new(*args)
              end                                               #   end
                                                                #
              def respond_to?(method_id)                        #   def respond_to?(method_id)
                #{klass}.respond_to?(method_id)                 #     Post.respond_to?(method_id)
              end                                               #   end
                                                                #
              def methods                                       #   def methods
                #{klass}.methods                                #     Post.methods
              end                                               #   end
                                                                #
              def method_missing(method_id, *arguments, &block) #   def method_missing(method_id, *arguments, &block)
                if #{klass}.respond_to?(method_id)              #     if Post.respond_to?(method_id)
                  #{klass}.send(method_id, *arguments, &block)  #       Post.send(method_id, *arguments, &block)
                else                                            #     else
                  super                                         #       super
                end                                             #     end
              end                                               #   end
            end                                                 # end
          )
        end
      end
    end
  end
  
  module ActiveSupport
    module Dependencies
      def self.included(base)
        base.alias_method_chain :search_for_file, :singular
      end
      
      # Search for a file in load_paths matching the provided suffix.
      # Includes singular path suffixes.
      def search_for_file_with_singular(path_suffix)
        search_for_file_without_singular(path_suffix) || begin
          path_suffix_singular = path_suffix.singularize + '.rb' unless path_suffix.ends_with? '.rb'
          load_paths.each do |root|
            path = File.join(root, path_suffix_singular)
            return path if File.file? path
          end
          nil
        end
      end
    end
  end
end

