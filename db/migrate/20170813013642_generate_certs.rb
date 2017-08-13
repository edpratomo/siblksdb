class GenerateCerts < ActiveRecord::Migration
  def change
    students_and_courses = StudentsRecord.joins(:grade).
                             where(status: "finished").
                             where.not('grades.score': "").
                             inject({}) {|m,sr| 
                               m[sr.student.id] ||= []
                               m[sr.student.id].push(sr.pkg.course.id)
                               m
                             }
    students_and_courses.each do |student_id, course_ids|
      student = Student.find(student_id)
      course_ids.uniq.map {|cid| Course.find(cid)}.each do |this_course|
        student.eligible_for_certs(this_course) {|course, grades|
          cert = Cert.new(student: student, course: course)
          cert.grades << grades
          cert.save!
        }
      end
    end
  end
end
