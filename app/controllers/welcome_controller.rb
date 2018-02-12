class WelcomeController < ApplicationController
  def index
    @stats = Program.all.sort_by {|e| e.id}.map {|prg| 
      [prg.program, Student.get_active_stats_for_program(prg, 6)]
    }.reject {|e| e[1].values.all? {|cnt| cnt == 0}} # exclude zero students
    @stats.unshift ["Semua Kursus", Student.get_active_stats(6)]
  end
end
