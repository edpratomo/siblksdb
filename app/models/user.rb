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

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
   end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end
end
