require 'yaml'
require 'i18n'

# list keys
KEYS = ["LMO_NAME", "LMO_FIRSTNAME", "LMO_BIRTH_DATE", "LMO_BIRTH_LOCATION", "LMO_STREET", "LMO_POSTAL_CODE", "LMO_CITY", "LMO_REASON"]

# list valid reasons
CURFEW_REASONS = ["work", "health", "family", "handicap", "pets", "missions", "justice", "transit"]
QUARANTINE_REASONS = ["sport", "kids", "religion", "culture", "process", "work", "health", "family", "handicap", "justice", "transit", "move", "needs"]

CONTEXTS = ["quarantine", "curfew"]

# get values for each key
def get_values(reason=nil, ctx="curfew")
    # birth date regex
    bdmatch = '\d\d\/\d\d\/\d\d\d\d'

    # select between two sets of reasons
    reasons = ctx == "curfew" ? CURFEW_REASONS : QUARANTINE_REASONS

    # create a hash containing values
    values = Hash.new

    # set reason if passed as argument
    unless reason.nil?
        raise "Invalid reason" if !reasons.include?(reason)
        values["LMO_REASON"] = reason
    end

    # iter on each key, try fetching from env first
    KEYS.each do |key|
        # if key found, take value
        if ENV[key] then
            # get value
            value = ENV[key]
            # reason is an edge case
            if key == "LMO_REASON" then
                try = ENV[key]
                unless reasons.include? try
                    puts "Error, reason from environment is not valid (available choices : #{REASONS.join(", ")})"
                    exit 1
                end
                values[key] = try
            # birth date is an edge case too
            elsif key == "LMO_BIRTH_DATE" then
                unless value.match(bdmatch)
                    puts "Error, birth date from environment is not valid (format DD/MM/YYYY)"
                    exit 1
                end
                values[key] = value
            else
                values[key] = value
            end
        # if not found, ask user
        else
            # make things pretty
            printable = key.slice(4, key.length).downcase.gsub("_", " ")
            # reason is an edge case
            if key == "LMO_REASON" then
                if reason.nil?
                    try = ""
                    until reasons.include? try
                        puts "Enter a value for key #{printable} (available choices for context `#{ctx}` (one only) : #{reasons.join(", ")}):"
                        try = gets.chomp.downcase
                    end
                    values[key] = try
                end
            # birth date is an edge case too
            elsif key == "LMO_BIRTH_DATE" then
                try = ""
                until try.match(bdmatch)
                    puts "Enter a value for key #{printable} (format : DD/MM/YYYY)"
                    try = gets.chomp
                end
                values[key] = try
            else
                puts "Enter a value for key `#{printable}` :"
                values[key] = gets.chomp
            end
        end
    end

    sanitize_values(values)
end

def values_from_profile(profile, reason)
    directory = ENV["LMO_PROFILES_DIR"] || "#{ENV["HOME"]}/.config/lmo/profiles"
    directory = directory.chomp("/")
    content = YAML.load(File.read("#{directory}/#{profile}.yml"))

    validation = {"LMO_REASON" => reason}
    content.each do |key, value|
        validation["LMO_#{key.upcase}"] = value
    end

    KEYS.each do |key|
        if key != "LMO_REASON" then
            raise "Error: key #{key.slice(4, key.length).downcase.gsub("_", " ")} is missing from profile file" unless validation[key]
        end
    end

    sanitize_values(validation)
end

def sanitize_values(values)
    I18n.available_locales = [:en]
    KEYS.each do |key|
        if values[key].is_a? String
            values[key] = I18n.transliterate(values[key]).sub(/[^\x00-\x7F]/, '')
        end
    end
    values
end
