class User < ActiveRecord::Base
  belongs_to :group
  has_many :students
end
