class Course < ActiveRecord::Base
  has_many :pkgs
end
