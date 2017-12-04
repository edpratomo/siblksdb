require 'mail'
require 'mail/check_delivery_params'

module CustomDeliveryMethod
  class Mailx
    DEFAULTS = {
      :location   => '/usr/bin/mailx',
      :arguments  => '-v'
    }

    attr_accessor :settings

    def initialize(values)
      delivery_settings = ActionMailer::Base.send("sendmail_settings")
      self.settings = self.class::DEFAULTS.merge(delivery_settings)
    end

    def deliver!(mail)
      # message = Mail::CheckDeliveryParams.check_message(mail)
      subject = mail.subject
      arguments = settings[:arguments]
      path = settings[:location]
      to = mail.to.map { |_to| self.class.shellquote(_to) }.join(' ')

      IO.popen(%Q[#{path} #{arguments} -s "#{subject}" #{to}], 'w+', :err => :out) do |io|
        io.puts mail.body
        io.flush
      end
    end

    # stolen from Mail::Sendmail
    def self.shellquote(address)
      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      #
      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored. Strip it.
      escaped = address.gsub(/([^A-Za-z0-9_\s\+\-.,:\/@~])/n, "\\\\\\1").gsub("\n", '')
      %("#{escaped}")
    end
  end
end
