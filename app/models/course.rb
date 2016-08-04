class Course < ActiveRecord::Base
  has_many :pkgs
  has_many :components

  belongs_to :program
  belongs_to :head_instructor, class_name: "Instructor", foreign_key: :head_instructor_id
end
