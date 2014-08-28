class User < ActiveRecord::Base
  belongs_to :group

  # for modified_by:
  has_many :students
  has_many :students_pkgs
  has_many :students_pkgs_schedule
  
  validate :username, presence: true, uniqueness: true
  has_secure_password
end
