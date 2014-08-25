class User < ActiveRecord::Base
  belongs_to :group

  has_many :students
  has_many :students_pkgs
  
  validate :username, presence: true, uniqueness: true
  has_secure_password
end
