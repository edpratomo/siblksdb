class Cert < ActiveRecord::Base
  has_many :grades_cert
  has_many :grades, through: :grades_cert

  has_one :student
  has_one :course
end
