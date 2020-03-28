#!/usr/bin/env ruby

# requirements
# erb, for templating
require 'erb'
# optparse for cli args handling
require 'optparse'

# Tiny class handling all the variables
class LMO

    # init values
    def initialize values
        @values = values
        @template = File.read("./templates/attestation.erb")
    end

    # generate string
    def fill
        ERB.new(@template).result(binding)
    end

end

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
end.parse!

# list keys
KEYS = ["LMO_NAME", "LMO_BIRTH_DATE", "LMO_BIRTH_LOCATION", "LMO_ADDRESS", "LMO_CITY", "LMO_REASON"]

# list valid reasons
REASONS = ["work", "food", "family", "health", "sport", "justice", "mission"]

# create a hash containing values
values = Hash.new

# iter on each key, try fetching from env first
KEYS.each do |key|
    # if key found, take value
    if ENV[key] then
        values[key] = ENV[key]
        log options, "Found value #{values[key]} for key `#{key}``"
    # if not found, ask user
    else
        # make things pretty
        printable = key.slice(4, key.length).downcase.gsub("_", " ")
        # reason is a edge case
        if key == "LMO_REASON" then
            try = ""
            until REASONS.include? try
                puts "Enter a value for key #{printable} (available choices : #{REASONS.join(", ")}):"
                try = gets.chomp.downcase
            end
            values[key] = try
        else
        puts "Enter a value for key `#{printable}` :"
        values[key] = gets.chomp
        end
    end
end

# Create class and bind values to it
current = LMO.new values

# 👀
log options, "https://www.youtube.com/watch?v=SdsJDLSI_Mo"

# If no args, go for stdout
if options.key?(:out) then
    # if args, use the first one as output file
    out = File.new options[:out], "w"
    out.puts current.fill
    out.close
    log options, "Writing output to file #{options[:out]}"
else
    puts current.fill
end
