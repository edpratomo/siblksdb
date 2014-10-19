module StudentsHelper
  def current_bio hstore_key
    @student.biodata && @student.biodata[hstore_key]
  end

  def show_bio hstore_key
    if @student.biodata and @student.biodata[hstore_key]
      unless @student.biodata[hstore_key].empty? 
        return @student.biodata[hstore_key]
      end
    end
    "(tidak diisi)"
  end
end
