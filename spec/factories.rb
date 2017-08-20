FactoryGirl.define do
  factory :group do
    factory :sysadmin do
      name "sysadmin"
    end

    factory :admin do
      name "admin"
    end

    factory :staff do
      name "staff"
    end

    factory :grp_instructor do
      name "instructor"
    end
  end

  factory :user do
    factory :skinner do
      username "skinner"
      fullname "Principal Skinner"
      association :group, factory: :sysadmin
    end

    factory :edna do
      username "edna"
      fullname "Edna Krabappel"
      password "edna"
      association :group, factory: :instructor
    end
    
    factory :willie do
      username "willie"
      fullname "Groundskeeper Willie"
      association :group, factory: :staff
    end
  end

  factory :instructor do
    name "Edna Krabappel"
    nick "edna"
    capacity 10
  end

  factory :program do
    program "Microsoft Office"
  end

  factory :course do
    factory :msword do
      name "MS Word"
      idn_prefix "KOM"
      program
      association :head_instructor, factory: :instructor
    end
  end

  factory :pkg do
    level 1
    association :course, factory: :msword
  end

  factory :student do
    created_at { DateTime.now }
    registered_at { 2.days.ago }

    trait  :misc_data do
       religion "Islam"
       birthplace "Springfield"
       phone "+62"
       email "email@insep.si"
       district "Cikupa"
       regency_city "Tangerang"
    end
    
    factory :bart, traits: [:misc_data] do
      name "Bart Simpson"
      sex "male"
      religion "Kristen"
      birthdate { 12.years.ago }
    end
    
    factory :lisa, traits: [:misc_data] do
      name  "Lisa Simpson"
      sex "female"
      religion "Budha"
      birthdate { 11.years.ago }
    end
  end

  factory :students_record do
    created_at { DateTime.now }
    pkg
    association :student, factory: :bart
    status "active"
  end
end
