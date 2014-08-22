class Student < ActiveRecord::Base
  belongs_to :user, foreign_key: 'modified_by'
end
