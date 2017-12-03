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
      self.settings = self.class::DEFAULTS.merge(values)
    end

    def deliver!(mail)
      smtp_from, smtp_to, message = Mail::CheckDeliveryParams.check(mail)
      subject = mail.subject

      #puts "MAIL FROM: #{mail.from}"
      #puts "RCPT TO: #{mail.to}"
      #puts "DATA: #{mail.to_s}"

      arguments = settings[:arguments]
      path = settings[:location]
      to = smtp_to.map { |_to| self.class.shellquote(_to) }.join(' ')

      popen %Q[#{path} #{arguments} -s "#{subject}" #{to}] do |io|
        io.puts ::Mail::Utilities.binary_unsafe_to_lf(encoded_message)
        io.flush
      end
    end

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
