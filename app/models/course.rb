class Course < ActiveRecord::Base
  has_many :pkgs
  has_many :components

  belongs_to :program
  belongs_to :head_instructor, class_name: "Instructor", foreign_key: :head_instructor_id

  def add_pkg new_max
    current_max = Pkg.where(course: self).maximum(:level) || 0
    num = new_max - current_max
    num.times do |e|
      pkg = Pkg.new(course: self, level: current_max + e + 1)
      pkg.save!
    end
  end
end
