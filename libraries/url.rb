require 'uri'

def generate_url(base, port = 80, path = '')
  path << '/' unless path.end_with?('/') || path.empty?

  url = URI.parse(base)
  url.path = path.to_s
  url.port = port.to_i unless port.nil?
  url.to_s
end
