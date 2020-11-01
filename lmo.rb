#!/usr/bin/env ruby

# requirements
# erb, for templating
require 'erb'
# optparse for cli args handling
require 'optparse'
# qrcode
require 'rqrcode'
# filler
require './filler/filler'
# values
require './utils/values'
# forwarders
require './forwarder/mails'
require './forwarder/telegram'

# log, used in verbose mode
def log opts, message
    if opts[:verbose] then
        puts "[INFO] #{message}"
    end
end

# parse command line arguments
# store everyting in a Hmap
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: lmo.rb [options]"

    # help
    opts.on("-h", "--help", "print this help message") do
        puts opts
        exit
    end

    # verbose
    opts.on("-v", "--verbose", "run verbosely") do |v|
        options[:verbose] = v
    end

    # output to file
    opts.on("-o", "--output=FILE", "write output to file file") do |v|
        options[:out] = v
    end

    # use qrcode
    opts.on("-qr", "--qrcode", "output to qrcode (plain text data if no output specified, as svg image if output specified") do |v|
        options[:qr] = v
    end

    # use custom reason
    opts.on("-r", "--reason=REASON", "pass reason as parameter (available choices : #{REASONS.join(", ")})") do |v|
        if REASONS.include?(v.downcase)
            options[:reason] = v
        else
            puts "[Error] specified delay value `#{v.downcase}` is not a valid reason"
            exit 1
        end
    end

    # use custom profile
    opts.on("-p", "--profile=PROFILE", "path to a profile.yml file") do |v|
        options[:profile] = v
    end

    # add time to current date if specified
    opts.on("-d", "--delay=MINUTES", "delay departure using specified value") do |v|
        delay = v.to_i
        if delay == 0 then
            puts "[Error] specified delay value `#{v}` is either 0 or not an int value"
            exit 1
        end
        options[:delay] = delay
    end

    # forwarder
    opts.on("-f", "--forward=FORWARDER", "forward the certificate to selected endpoint (available choices: mails)") do |v|
        options[:forward] = v
    end
end.parse!

# supported forwarders
FORWARDERS = ["mail", "telegram"]

if options[:forward] && !FORWARDERS.include?(options[:forward]) then
    puts "Error: #{options[:forward]} forwarder is not supported (available choices : #{FORWARDERS.join(", ")})"
    exit 1
end

if options[:profile] && !options[:reason] then
    puts "Error: profile option needs reason option to be set"
    exit 1
end

values = nil

if options[:profile] then
    log options, "Reading from profile #{options[:profile]}"
    begin
        values = values_from_profile(options[:profile], options[:reason])
    rescue => exception
        puts exception
        exit 1
    end
else
    values = get_values(options[:reason])
end

# Create class and bind values to it
f = Filler.new values, options[:delay], options[:qr]

# 👀
log options, "https://www.youtube.com/watch?v=SdsJDLSI_Mo"

# If no args, go for stdout
if options.key?(:out) then
    # if args, use the first one as output file
    out = File.new options[:out], "w"
    if options[:qr]
        log options, "Using QRCode output"
        out.puts f.gen_qr.as_svg()
    else
        out.puts "#{f.fill}\n"
    end
    out.close
    log options, "Writing output to file #{options[:out]}"
else
    puts "#{f.fill}\n"
end

if options[:forward] then
    fwd = nil
    case options[:forward]
    when "mail"
        fwd = Mails.new
    when "telegram"
        fwd = Tlgrm.new
    else
        puts "Error: #{options[:forward]} forwarder is not supported"
    end

    fwd.send(f.fill, f.gen_qr, f.id) unless fwd.nil?
end
