class Course < ActiveRecord::Base
  has_many :pkgs
  has_many :components
end
