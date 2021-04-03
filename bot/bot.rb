# frozen_string_literal: true

require 'telegram/bot'
require './utils/values'
require './utils/temp'
require './filler/filler'
require './forwarder/telegram'

def parse_gen_args(message)
  args = message.split
  args.shift
  raise "Error: can't generate certificate without reason (see /help)" if args.empty?

  ctx = args.shift
  raise "Error: can't generate certificate with unvalid ctx `#{ctx}`" unless CONTEXTS.include?(ctx)

  reasons = ctx == 'curfew' ? CURFEW_REASONS : QUARANTINE_REASONS
  reason = args.shift
  raise "Error: can't generate certificate with unvalid reason `#{reason}`" unless reasons.include?(reason)

  delay = args.shift
  raise 'Error: delay value is not an integer' if !delay.nil? && delay.to_i.zero?

  shift = args.shift
  raise 'Error: shift value is not a negative integer' if !shift.nil? && shift.to_i >= 0

  # safely convert since checks are donne before
  delay = delay.to_i
  shift = shift.to_i

  raise 'Error: creation time is after departure time check shift and delay options' unless time_valid?(shift, delay)

  [reason, delay, shift, ctx]
end

def time_valid?(shift, delay)
  Time.now + shift * 60 > Time.now + delay * 60
end

def generate_and_send(bot, message, reason, delay: 0, shift: 0)
  # get values
  values = values_from_profile(message.from.id, reason)
  # init filler
  f = Filler.new values, delay, shift
  # certificate
  gen_and_send_cert(f, bot)
  # qr-code
  gen_and_send_qr(f, bot)
end

def gen_and_send_cert(filler, bot)
  cert = temp(filler.fill, 'cert')
  bot.api.send_document(chat_id: message.chat.id,
                        document: Faraday::UploadIO.new(cert.path, 'text/plain'), caption: "Certificate: #{f.id}")
  cert.unlink
end

def gen_and_send_qr(filler, bot)
  qrcode = temp(filler.gen_qr.as_png(size: 500), 'qrcode')
  bot.api.send_photo(chat_id: message.chat.id,
                     photo: Faraday::UploadIO.new(qrcode.path, 'image/png'), caption: "QR Code: #{f.id}")
  qrcode.unlink
end

# get token from env
token = ENV['LMO_TELEGRAM_TOKEN'] || raise('Error: missing LMO_TELEGRAM_TOKEN env var')

HELP = <<~HELP
  Available commands for LMO

  - /start or /help: get this help message

  - /me: get your Telegram user ID

  - /gen <context> <reason> <delay> (optional) <shift> (optional): generate a certificate for command author using specified reason
  Arguments:
  context : #{CONTEXTS.join(', ')}
  reasons: curfew : #{CURFEW_REASONS.join(', ')} | quarantine : #{QUARANTINE_REASONS.join(', ')}
  delay: integer, delay departure time from now +/- N minutes (supports positive and negative values)
  shift: integer < 0, shift creation time from nom to N minutes in the past (supports only negative values)
HELP

# bot entry point
Telegram::Bot::Client.run(token) do |bot|
  puts "Going into listen mode with token #{token}"
  bot.listen do |message|
    next if text.nil?

    if message.text == '/start' || message.text == '/help'
      bot.api.send_message(chat_id: message.chat.id, text: HELP)
    elsif message.text == '/me'
      bot.api.send_message(chat_id: message.chat.id, text: "Sure, here is your ID `#{message.from.id}`")
    elsif message.text.start_with?('/gen')
      begin
        reason, delay, shift, ctx = parse_gen_args(message.text)
        generate_and_send(bot, message, reason, delay, shift, ctx)
      rescue Errno::ENOENT => e
        warn e
        bot.api.send_message(chat_id: message.chat.id,
                             text: "Error: profile for user id `#{message.from.id}` not found")
      rescue RuntimeError => e
        bot.api.send_message(chat_id: message.chat.id, text: e.message)
      end
    end
  end
end
