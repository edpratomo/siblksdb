class GradesCert < ActiveRecord::Base
  # :grades <= :grades_certs => :certs
  belongs_to :grade
  belongs_to :cert
end
