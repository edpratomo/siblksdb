class Cert < ActiveRecord::Base
  has_many :grades_certs
  has_many :grades, through: :grades_certs

  belongs_to :student
  belongs_to :course
end
