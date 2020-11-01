require 'telegram/bot'
require './utils/values'
require './utils/temp'
require './filler/filler'
require './forwarder/telegram'

def parse_gen_args(message)
    args = message.split
    args.shift
    raise "Error: can't generate certificate without reason (see /help)" if args.empty?
    reason = args.shift
    raise "Error: can't generate certificate with unvalid reason `#{reason}`" unless REASONS.include?(reason)
    sanitized = Array.new
    args.each do |v|
        try = v.to_i
        raise "Error: remaining arguments of gen command needs to be integers > 0" if try == 0
        sanitized << try
    end

    return reason, sanitized[0], sanitized[1]
end

def generate_and_send(bot, message, reason, delay=nil, shift=nil)
    # get values
    values = values_from_profile(message.from.id, reason)
    # init filler
    f = Filler.new values, delay, shift
    # certificate
    cert = temp(f.fill, "cert")
    bot.api.send_document(chat_id: message.chat.id, document: Faraday::UploadIO.new(cert.path, 'text/plain'), caption: "Certificate: #{f.id}")
    cert.unlink
    # qr-code
    qrcode = temp(f.gen_qr.as_png(size: 500), "qrcode")
    bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(qrcode.path, 'image/png'), caption: "QR Code: #{f.id}")
    qrcode.unlink
end

# get token from env
token = ENV["LMO_TELEGRAM_TOKEN"] || raise("Error: missing LMO_TELEGRAM_TOKEN env var")

HELP = <<-END
Available commands for LMO

    - /start or /help: get this help message

    - /me: get your Telegram user ID

    - /gen <reason> <delay> (optional) <shift> (optional): generate a certificate for command author using specified reason
        Arguments:
            reasons: #{REASONS.join(", ")}
            delay: integer, delay departure time to now + n minutes
            shift: integer, shift creation time to now - n minutes
END

# bot entry point
Telegram::Bot::Client.run(token) do |bot|
    puts "Going into listen mode with token #{token}"
    bot.listen do |message|
        case
        when message.text.nil?
            next
        when message.text == "/start" || message.text == "/help"
            bot.api.send_message(chat_id: message.chat.id, text: HELP)

        when message.text == "/me"
            bot.api.send_message(chat_id: message.chat.id, text: "Sure, here is your ID `#{message.from.id}`")

        when message.text.start_with?("/gen")
            begin
                reason, delay, shift = parse_gen_args(message.text)
                generate_and_send(bot, message, reason, delay, shift)
            rescue Errno::ENOENT => e
                STDERR.puts e
                bot.api.send_message(chat_id: message.chat.id, text: "Error: profile for user id `#{message.from.id}` not found")
            rescue RuntimeError => e
                bot.api.send_message(chat_id: message.chat.id, text: e.message)
            end
        end
    end
end
