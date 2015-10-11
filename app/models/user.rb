class User < ActiveRecord::Base
  # include TransactionHelper
  include Gravtastic
  gravtastic default: "identicon"

  belongs_to :role, foreign_key: "group_id"
  belongs_to :group

  # for modified_by:
  has_many :students
  has_many :students_pkgs
  has_many :students_pkgs_schedule
  
  # link user to instructor
  has_one :users_instructor
  has_one :instructor, through: :users_instructor

  validates :username, presence: true, uniqueness: true
  has_secure_password

  def role_symbols
    [role.title.to_sym]
  end

end
