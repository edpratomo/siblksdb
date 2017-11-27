class Component < ActiveRecord::Base
  belongs_to :course
  has_many :grades

  before_destroy :is_destroyable?

  def is_destroyable?
    grades.size == 0 and not is_default
  end
end
