class SettingsController < ApplicationController
  before_action :authorize_sysadmin
  
  def edit
    @current_interval = Setting.change_log_archive_interval
    @change_log_archive_intervals = %w(4 3 2 1).inject([]) do |m,o|
      m << ["#{o} minggu", "#{o}_week"]
      m
    end
  end

  def update
    Setting[:change_log_archive_interval] = params[:change_log_archive_interval]
    if params[:holidays]
      begin
        holidays = JSON.parse(File.read(params[:holidays].original_filename))[2].inject({}) do |m,o|
          m[o[0]] = o[1]
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

    redirect_to settings_edit_path, notice: 'Setting was successfully updated.'
  end
end
