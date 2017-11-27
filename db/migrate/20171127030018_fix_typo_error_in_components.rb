class FixTypoErrorInComponents < ActiveRecord::Migration
  def change
    las = Course.find_by(name: "Las Dasar")
    comps = Component.where(course: las)
    comps.each do |comp|
      content = comp.content.gsub!("sehantan", "sehatan")
      comp.save!
    end
  end
end
