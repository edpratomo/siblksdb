class UsersInstructor < ActiveRecord::Base
  # :users <= :users_instructors => :instructors
  belongs_to :user
  belongs_to :instructor
end
