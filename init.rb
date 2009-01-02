require 'pluralized_models'

ActiveRecord::Base.send(:extend, PluralizedModels::ActiveRecord::ClassMethods)
ActiveSupport::Dependencies.send(:include, PluralizedModels::ActiveSupport::Dependencies)