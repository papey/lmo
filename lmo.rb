#!/usr/bin/env ruby

# requirements
# erb, for templating
require 'erb'
# optparse for cli args handling
require 'optparse'
# qrcode
require 'rqrcode'
# filler
require './filler/filler.rb'
# values
require './utils/values.rb'

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

    # add time to current date if specified
    opts.on("-d", "--delay=MINUTES", "delay departure using specified value") do |v|
        delay = v.to_i
        if delay == 0 then
            puts "[Error] specified delay value `#{v}` is either 0 or not an int value"
            exit 1
        end
        options[:delay] = delay
    end
end.parse!

# list keys
KEYS = ["LMO_NAME", "LMO_FIRSTNAME", "LMO_BIRTH_DATE", "LMO_BIRTH_LOCATION", "LMO_STREET", "LMO_POSTAL_CODE", "LMO_CITY", "LMO_REASON"]

# list valid reasons
REASONS = ["work", "purchase", "health", "familly", "handicap", "sport", "pets", "missions", "justice", "children"]

# Create class and bind values to it
f = Filler.new get_values(KEYS, REASONS), options[:delay], options[:qr]

# 👀
log options, "https://www.youtube.com/watch?v=SdsJDLSI_Mo"

# If no args, go for stdout
if options.key?(:out) then
    # if args, use the first one as output file
    out = File.new options[:out], "w"
    if options[:qr]
        log options, "Using QRCode output"
        qr = RQRCode::QRCode.new(f.fill_qr)
        out.puts qr.as_svg(
            offset: 0,
            color: '000',
            shape_rendering: 'crispEdges',
            module_size: 6,
            standalone: true
        )
    else
        out.puts f.fill
    end
    out.close
    log options, "Writing output to file #{options[:out]}"
else
    puts f.fill
end
