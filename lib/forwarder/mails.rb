# frozen_string_literal: true

require 'pony'

# Mails classe used to send documents using emails
class Mails
  def initialize
    @to = ENV['LMO_MAIL_DEST'] || raise('Error: missing LMO_MAIL_DEST env var')
    @port = ENV['LMO_MAIL_PORT'] || 587
    @user = ENV['LMO_MAIL_USER'] || raise('Error: missing LMO_MAIL_USER env var')
    @pass = ENV['LMO_MAIL_PASSWORD'] || raise('Error: missing LMO_MAIL_PASSWORD env var')
    @adress = ENV['LMO_MAIL_SERVER'] || raise('Error: missing LMO_MAIL_SERVER env var')
    @domain = ENV['LMO_MAIL_DOMAIN'] || 'localhost'
  end

  def send(certificate, qr, subject)
    options = {
      address: @adress,
      port: @port,
      enable_starttls_auto: true,
      user_name: @user,
      password: @pass,
      authentication: :plain,
      domain: @domain
    }

    Pony.mail({
                to: @to,
                via: :smtp,
                via_options: options,
                subject: subject,
                body: subject,
                attachments: { 'qr.svg' => qr.as_svg, 'certificate.txt' => certificate }
              })
  end
end
