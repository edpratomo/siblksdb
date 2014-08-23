class User < ActiveRecord::Base
  belongs_to :group
  has_many :students

  validate :username, presence: true, uniqueness: true
  has_secure_password
end
