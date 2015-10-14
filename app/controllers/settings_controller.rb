class SettingsController < ApplicationController
  # before_action :authorize_sysadmin
  filter_access_to :all
  
  def edit
    @current_interval = Setting.change_log_archive_interval
    @director = Setting.director
    @kasie_ppk_name = Setting.kasie_ppk_name
    @kasie_ppk_nip = Setting.kasie_ppk_nip
    
    @change_log_archive_intervals = %w(4 3 2 1).inject([]) do |m,o|
      m << ["#{o} minggu", "#{o}_week"]
      m
    end
  end

  def update
    Setting[:change_log_archive_interval] = params[:change_log_archive_interval]
    Setting[:director] = params[:director]
    Setting[:kasie_ppk_name] = params[:kasie_ppk_name]
    Setting[:kasie_ppk_nip] = params[:kasie_ppk_nip]

    if params[:holidays]
      begin
        uploaded_io = params[:holidays]
        # changes in input file format:
        # holidays = JSON.parse(uploaded_io.read)[2].inject({}) do |m,o|
        # m[o[0]] = o[1]
        holidays = JSON.parse(uploaded_io.read).inject({}) do |m,o|
          m[o["date"]] = o["ind_name"]
          m
        end
        Setting[:holidays] = holidays
      rescue JSON::ParserError
        alert_msg = "Tidak mengenali isi file yang diupload. Gunakan CPAN module Calendar::Indonesia::Holiday " + 
                    "untuk menghasilkan file dalam format yang dikenali."
        redirect_to settings_edit_path, alert: alert_msg
        return 
      end
    end

    if params[:anypkg_grade_component]
      begin
        content = params[:anypkg_grade_component].read
        JSON.parse(content)
        Setting[:anypkg_grade_component] = content
      rescue JSON::ParserError
        alert_msg = "File bukan JSON yang valid."
        redirect_to settings_edit_path, alert: alert_msg
        return
      end
    end

    redirect_to settings_edit_path, notice: 'Setting was successfully updated.'
  end
end
