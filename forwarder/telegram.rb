require 'telegram/bot'
require './utils/temp'

class Tlgrm

    def initialize
        @token = ENV["LMO_TELEGRAM_TOKEN"] || raise("Error: missing LMO_TELEGRAM_TOKEN env var")
        @chat = ENV["LMO_TELEGRAM_CHAT"] || raise("Error: missing LMO_TELEGRAM_CHAT env var")
    end

    def send(certificate, qr, subject)
        Telegram::Bot::Client.run(@token) do |bot|
            # certificate
            cert = temp(certificate, "cert")
            bot.api.send_document(chat_id: @chat, document: Faraday::UploadIO.new(cert.path, 'text/plain'), caption: "Certificate: #{subject}")
            cert.unlink
            # svg
            qrcode = temp(qr.as_png(size: 500), "qrcode")
            bot.api.send_photo(chat_id: @chat, photo: Faraday::UploadIO.new(qrcode.path, 'image/png'), caption: "QR Code: #{subject}")
            qrcode.unlink
        end
    end

end
