class User < ActiveRecord::Base
  belongs_to :group
  has_many :students, :foreign_key => 'modified_by'

  validate :username, presence: true, uniqueness: true
  has_secure_password
end
