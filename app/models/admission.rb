class Admission < ActiveRecord::Base
  # foreign table
  self.table_name = 'siblksdb_v2.admissions'
  self.primary_key = 'id'
  
  has_one :student
end
