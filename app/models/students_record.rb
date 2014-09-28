class StudentsRecord < ActiveRecord::Base
  include TransactionHelper

  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg
end
