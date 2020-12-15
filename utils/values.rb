require 'yaml'

# list keys
KEYS = ["LMO_NAME", "LMO_FIRSTNAME", "LMO_BIRTH_DATE", "LMO_BIRTH_LOCATION", "LMO_STREET", "LMO_POSTAL_CODE", "LMO_CITY", "LMO_REASON"]

# list valid reasons
REASONS = ["work", "health", "family", "handicap", "pets", "missions", "justice", "transits"]

# get values for each key
def get_values(reason=nil)
    # birth date regex
    bdmatch = '\d\d\/\d\d\/\d\d\d\d'

    # create a hash containing values
    values = Hash.new

    # set reason if passed as argument
    unless reason.nil?
        raise "Invalid reason" if !REASONS.include?(reason)
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
                unless REASONS.include? try
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
                        puts "Enter a value for key #{printable} (available choices (one only) : #{REASONS.join(", ")}):"
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

    values
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

    validation
end
