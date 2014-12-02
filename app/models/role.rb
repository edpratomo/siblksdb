class Role < ActiveRecord::Base
  has_many :users

  self.table_name = 'groups'
  
  def title=(val)
    write_attribute(:name, val)
  end
  
  def title
    read_attribute(:name)
  end
end
