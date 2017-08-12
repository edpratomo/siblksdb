class CertsController < ApplicationController
  before_action :set_cert, only: [:show, :edit, :update, :destroy]
  before_action :set_student, only: [:index_by_student]
  before_action :set_grade, only: [:show]

  # GET /certs
  # GET /certs.json
  def index
    @certs = Cert.all
  end

  def index_by_student
    @certs = @student.certs
  end

  # GET /certs/1
  # GET /certs/1.json
  def show
    respond_to do |format|
      format.html {
        if params[:brief]
          render template: 'certs/brief.html.erb', layout: false
        else
          if @instructor
            render :show
          else
            render :show_staff
          end
        end
      }
      format.pdf {
        render pdf: %[Sertifikat],
               orientation: 'Portrait',
               template: 'certs/show.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end

  # GET /certs/new
  def new
    @cert = Cert.new
  end

  # GET /certs/1/edit
  def edit
  end

  # POST /certs
  # POST /certs.json
  def create
    @cert = Cert.new(cert_params)

    respond_to do |format|
      if @cert.save
        format.html { redirect_to @cert, notice: 'Cert was successfully created.' }
        format.json { render :show, status: :created, location: @cert }
      else
        format.html { render :new }
        format.json { render json: @cert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certs/1
  # PATCH/PUT /certs/1.json
  def update
    respond_to do |format|
      if @cert.update(cert_params)
        format.html { redirect_to @cert, notice: 'Cert was successfully updated.' }
        format.json { render :show, status: :ok, location: @cert }
      else
        format.html { render :edit }
        format.json { render json: @cert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certs/1
  # DELETE /certs/1.json
  def destroy
    @cert.destroy
    respond_to do |format|
      format.html { redirect_to certs_url, notice: 'Cert was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cert
      @cert = Cert.find(params[:id])
    end

    def set_student
      @student = Student.find(params[:student_id])
    end

    def set_grade
      @grade = OpenStruct.new
      component_id = @cert.grades.first.component.id
      last_idx = @cert.grades.first.score.size - 1
      sum_of_scores = (0..last_idx).to_a.map {|e| e.to_s}.inject({}) {|m,o| m[o] = 0; m}
      if @cert.grades.all? {|grade| grade.component.id == component_id }
        @cert.grades.each do |grade|
          (0..last_idx).to_a.map {|e| e.to_s}.each do |idx|
            # logger.debug("idx #{idx} #{grade.score} - #{grade.score[idx]}")
            if grade.score[idx].scan('/').empty?
              sum_of_scores[idx] += grade.score[idx].to_i
            else
              aa, bb = grade.score[idx].split('/').map {|e| e.to_i}
              sum_of_scores[idx] = [0, 0] unless sum_of_scores[idx].is_a? Array
              sum_of_scores[idx][0] += aa
              sum_of_scores[idx][1] += bb
            end
          end
        end

        num_of_grade = @cert.grades.size
        @grade.score = (0..last_idx).to_a.map {|e| e.to_s}.inject({}) do |m,idx|
          if sum_of_scores[idx].is_a? Array
            m[idx] = "#{sum_of_scores[idx][0] / num_of_grade}/#{sum_of_scores[idx][1] / num_of_grade}"
          else
            m[idx] = (sum_of_scores[idx] / num_of_grade).round.to_s
          end
          m
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cert_params
      params[:cert]
    end

#    def signature_date
#      DateTime.now.in_time_zone
#    end
end
