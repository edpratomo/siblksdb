class Course < ActiveRecord::Base
  has_many :pkgs
  has_many :components
  has_many :certs

  belongs_to :uniform
  belongs_to :program
  belongs_to :head_instructor, class_name: "Instructor", foreign_key: :head_instructor_id

  before_destroy :is_destroyable?
  before_destroy :delete_pkgs

  def delete_pkgs
    delete_these = pkgs.select {|e| StudentsRecord.where(pkg: e).size == 0}
    delete_these.each do |pkg|
      pkgs.destroy(pkg)
    end
  end

  def is_destroyable?
    pkgs.all? {|e| StudentsRecord.where(pkg: e).size == 0}
  end

  def add_pkg new_max
    current_max = pkgs.where(enabled: true).maximum(:level) || 0
    num = new_max - current_max
    num.times do |e|
      pkg = pkgs.find_by(level: current_max + e + 1)
      if pkg
        pkg.update!(enabled: true)
      else
        pkg = Pkg.new(course: self, level: current_max + e + 1)
        pkg.save!
      end
    end
  end

  def disable_pkg_higher_level_than new_max
    pkgs.where(enabled: true).where('level > ?', new_max).update_all(enabled: false)
  end

  def del_pkg new_max
    Pkg.where(course: self).where('level > ?', new_max).destroy_all
  end
end
