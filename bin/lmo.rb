#!/usr/bin/env ruby

# frozen_string_literal: true

# requirements
# optparse for cli args handling
require 'optparse'
# qrcode
require 'rqrcode'
# filler
require_relative '../lib/filler/filler'
# values
require_relative '../lib/utils/values'
# forwarders
require_relative '../lib/forwarder/mails'
require_relative '../lib/forwarder/telegram'

# log, used in verbose mode
def log(opts, message)
  puts "[INFO] #{message}" if opts[:verbose]
end

# parse command line arguments
# store everyting in a Hmap
options = { delay: 0, shift: 0, ctx: 'quarantine' }
OptionParser.new do |opts|
  opts.banner = 'Usage: lmo.rb [options]'

  # help
  opts.on('-h', '--help', 'print this help message') do
    puts opts
    exit
  end

  # verbose
  opts.on('-v', '--verbose', 'run verbosely') do |v|
    options[:verbose] = v
  end

  # output to file
  opts.on('-o', '--output=FILE', 'write output to file file') do |v|
    options[:out] = v
  end

  opts.on('-c', '--ctx=CONTEXT', 'choose between curfew or quarantine context') do |v|
    if CONTEXTS.include?(v.downcase)
      options[:ctx] = v
    else
      puts "[Error] specified context value `#{v.downcase}` is not a valid context (available choices : #{CONTEXTS.join(', ')}"
      exit 1
    end
  end

  # use qrcode
  opts.on('-qr', '--qrcode',
          'output to qrcode (plain text data if no output specified, as svg image if output specified)') do |v|
    options[:qr] = v
  end

  # use custom reason
  opts.on('-r', '--reason=REASON',
          "pass reason as parameter (available choices : with curfew context : #{CURFEW_REASONS.join(', ')}) | with quarantine context : #{QUARANTINE_REASONS.join(', ')}") do |v|
    reasons = options[:ctx] == 'curfew' ? CURFEW_REASONS : QUARANTINE_REASONS
    if reasons.include?(v.downcase)
      options[:reason] = v
    else
      puts "[Error] specified delay value `#{v.downcase}` is not a valid reason"
      exit 1
    end
  end

  # use custom profile
  opts.on('-p', '--profile=PROFILE', 'path to a profile.yml file') do |v|
    options[:profile] = v
  end

  # delay creation date
  opts.on('-s', '--shift=MINUTES',
          'shift creation time in the past using specified value where MINUTES is an integer < 0') do |v|
    shift = v.to_i
    if shift >= 0
      puts "[Error] specified shift value `#{v}` is either 0 or not a negative int value"
      exit 1
    end
    options[:shift] = shift
  end

  # add time to current date if specified
  opts.on('-d', '--delay=MINUTES', 'delay departure using specified value where MINUTES is an integer != 0') do |v|
    delay = v.to_i
    if delay.zero?
      puts "[Error] specified delay value `#{v}` is either 0 or not an int value"
      exit 1
    end
    options[:delay] = delay
  end

  # forwarder
  opts.on('-f', '--forward=FORWARDER',
          'forward the certificate to selected endpoint (available choices: mails)') do |v|
    options[:forward] = v
  end
end.parse!

# supported forwarders
FORWARDERS = %w[mail telegram].freeze

# check if timeshift is valid
if Time.now + options[:shift] * 60 > Time.now + options[:delay] * 60
  puts 'Error: creation time is after departure time check shift and delay options'
  exit 1
end

if options[:forward] && !FORWARDERS.include?(options[:forward])
  puts "Error: #{options[:forward]} forwarder is not supported (available choices : #{FORWARDERS.join(', ')})"
  exit 1
end

if options[:profile] && !options[:reason]
  puts 'Error: profile option needs reason option to be set'
  exit 1
end

values = nil

if options[:profile]
  log options, "Reading from profile #{options[:profile]}"
  begin
    values = values_from_profile(options[:profile], options[:reason])
  rescue StandardError => e
    puts e
    exit 1
  end
else
  values = get_values(options[:reason], options[:ctx])
end

# Create class and bind values to it
f = Filler.new values, delay: options[:delay], from: options[:shift], ctx: options[:ctx]

# 👀
log options, 'https://www.youtube.com/watch?v=SdsJDLSI_Mo'

# If no args, go for stdout
if options.key?(:out)
  # if args, use the first one as output file
  out = File.new options[:out], 'w'
  if options[:qr]
    log options, 'Using QRCode output'
    out.puts f.gen_qr.as_svg
  else
    out.puts "#{f.fill}\n"
  end
  out.close
  log options, "Writing output to file #{options[:out]}"
else
  puts "#{f.fill}\n"
end

if options[:forward]
  fwd = nil
  case options[:forward]
  when 'mail'
    fwd = Mails.new
  when 'telegram'
    fwd = Tlgrm.new
  else
    puts "Error: #{options[:forward]} forwarder is not supported"
  end

  fwd&.send(f.fill, f.gen_qr, f.id)
end
