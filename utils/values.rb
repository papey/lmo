# frozen_string_literal: true

require 'yaml'
require 'i18n'

# list keys
KEYS = %w[LMO_NAME LMO_FIRSTNAME LMO_BIRTH_DATE LMO_BIRTH_LOCATION LMO_STREET LMO_POSTAL_CODE
          LMO_CITY LMO_REASON].freeze

# list valid reasons
CURFEW_REASONS = %w[work health family handicap pets missions justice transit].freeze
QUARANTINE_REASONS = %w[sport kids religion culture process work health family handicap
                        justice transit move needs].freeze

CONTEXTS = %w[quarantine curfew].freeze

# get values for each key
def get_values(reason = nil, ctx = 'curfew')
  # birth date regex
  bdmatch = '\d\d\/\d\d\/\d\d\d\d'

  # select between two sets of reasons
  reasons = ctx == 'curfew' ? CURFEW_REASONS : QUARANTINE_REASONS

  # create a hash containing values
  values = {}

  # set reason if passed as argument
  unless reason.nil?
    raise 'Invalid reason' unless reasons.include?(reason)

    values['LMO_REASON'] = reason
  end

  # iter on each key, try fetching from env first
  KEYS.each do |key|
    # if key found, take value
    if ENV[key]
      # get value
      value = ENV[key]
      # reason is an edge case
      case key
      when 'LMO_REASON'
        try = ENV[key]
        unless reasons.include? try
          puts "Error, reason from environment is not valid (available choices : #{REASONS.join(', ')})"
          exit 1
        end
        values[key] = try
      # birth date is an edge case too
      when 'LMO_BIRTH_DATE'
        unless value.match(bdmatch)
          puts 'Error, birth date from environment is not valid (format DD/MM/YYYY)'
          exit 1
        end
        values[key] = value
      else
        values[key] = value
      end
    # if not found, ask user
    else
      # make things pretty
      printable = key.slice(4, key.length).downcase.gsub('_', ' ')
      # reason is an edge case
      case key
      when 'LMO_REASON'
        until reason.nil? && reasons.include?(try)
          puts "Enter a value for key #{printable} (choices for context `#{ctx}` (one only) : #{reasons.join(', ')}):"
          try = gets.chomp.downcase
        end
        values[key] = try
      # birth date is an edge case too
      when 'LMO_BIRTH_DATE'
        try = ''
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
  directory = ENV['LMO_PROFILES_DIR'] || "#{ENV['HOME']}/.config/lmo/profiles"
  directory = directory.chomp('/')
  content = YAML.safe_load(File.read("#{directory}/#{profile}.yml"))

  validation = { 'LMO_REASON' => reason }
  content.each do |key, value|
    validation["LMO_#{key.upcase}"] = value
  end

  KEYS.each do |key|
    if key != ('LMO_REASON') && !(validation[key]) && !(validation[key])
      raise "Error: key #{key.slice(4, key.length).downcase.gsub('_', ' ')} is missing from profile file"
    end
  end

  sanitize_values(validation)
end

def sanitize_values(values)
  I18n.available_locales = [:en]
  KEYS.each do |key|
    values[key] = I18n.transliterate(values[key]).sub(/[^\x00-\x7F]/, '') if values[key].is_a? String
  end
  values
end
