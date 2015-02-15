class Student < ActiveRecord::Base
  include TransactionHelper
  
  validates_presence_of :religion, :name, :birthplace, :birthdate, :sex, :phone, :email
  validates_presence_of :district, :regency_city
  validate :registered_at_before_created_at_and_started_on  

  # :students <= :students_records => :pkgs
  has_many :students_records
  has_many :records, through: :students_records, source: :pkg

  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :pkgs,           through: :students_pkgs
  has_many :programs,       through: :pkgs

  # :students_pkgs <= :students_pkgs_instructors_schedules => :instructors_schedules
  has_many :students_pkgs_instructors_schedules, through: :students_pkgs
  has_many :instructors_schedules,               through: :students_pkgs_instructors_schedules

  # avatar file attachment
  has_attached_file :avatar, 
                    :styles => { :large => "500x500>", :medium => "300x300>", :thumb => "100x100>" }, 
                    :default_url => :default_url_by_gender, 
                    :processors => [:cropper] # for cropping
  validates_attachment :avatar,
                       :content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"] },
                       :size => { :less_than => 1.megabytes }
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/, /gif\Z/]

  # for cropping
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h 

  after_update :reprocess_avatar, :if => :cropping?  

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)  
    @geometry ||= {}  
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))  
  end  

  def self.get_active_stats last_x_months=6
    now = DateTime.now.in_time_zone
    (0..(last_x_months - 1)).to_a.reverse.inject({}) do |m,o|
      dt = now - o.month
      month, year = dt.month, dt.year

      active_students = StudentsRecord.joins(:student).
        where("started_on < ? AND (status = 'active' OR finished_on > ?)", 
        dt.end_of_month, dt.end_of_month).
        group(:sex).count
      
      %w(male female).each {|e| m[[e, dt.strftime('%b %Y')]] = active_students[e] || 0 }
      m
    end
  end

  # custom validation for :registered_at
  def registered_at_before_created_at_and_started_on
    if self.registered_at > self.created_at 
      errors.add(:registered_at, "tidak dapat diisi tanggal setelah tanggal entri data")
      return false
    end
    first_started_on = StudentsRecord.where(student_id: self.id).minimum(:started_on)
    if first_started_on and self.registered_at > first_started_on
      errors.add(:registered_at, "tidak dapat diisi tanggal setelah tanggal kursus")
      return false
    end
  end
    
  private
  def default_url_by_gender
    gender = self.sex
    unless gender
      "/images/:style/missing.png"
    else
      "/images/:style/default_#{gender}.png"
    end
  end

  def reprocess_avatar  
     avatar.assign(avatar)
     avatar.save
     # avatar.reprocess! # this causes loop until stack level too deep
  end    
end
