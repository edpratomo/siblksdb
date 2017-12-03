require "#{Rails.root}/lib/mailx"

ActionMailer::Base.add_delivery_method :mailx, CustomDeliveryMethod::Mailx
