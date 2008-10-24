
def number_to_percentage(number, options = {})
  # options   = options.stringify_keys
  precision = options[:precision] || 3
  separator = options[:separator] || "."

  begin
    number = number_with_precision(number, precision)
    parts = number.split('.')
    if parts.at(1).nil?
      parts[0] + "%"
    else
      parts[0] + separator + parts[1].to_s + "%"
    end
  rescue
    number
  end
end
