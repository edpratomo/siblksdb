class Book < ActiveRecord::Base
  has_many :courses
end
