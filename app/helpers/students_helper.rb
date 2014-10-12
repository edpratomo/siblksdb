module StudentsHelper
  def current_bio hstore_key
    @student.biodata && @student.biodata[hstore_key]
  end
end
