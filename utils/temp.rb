# frozen_string_literal: true

require 'tempfile'

def temp(content, title)
  file = Tempfile.new(title)
  file.write content
  file.close
  file
end
