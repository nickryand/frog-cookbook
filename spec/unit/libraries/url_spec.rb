require_relative '../spec_helper'
require_relative '../../../libraries/url'

describe 'generate_url' do
  it 'returns a url path with a trailing slash' do
    url = generate_url('http://localhost', 8000)
    expect(url).to eq('http://localhost:8000')
  end

  it 'returns a url with a / terminated path' do
    url = generate_url('http://localhost', 80, '/media')
    expect(url).to eq('http://localhost/media/')
  end

  it 'returns a url with a / terminated path' do
    url = generate_url('http://localhost', 8080, '/media')
    expect(url).to eq('http://localhost:8080/media/')
  end

  it 'returns a properly formatted url with a port and path' do
    url = generate_url('http://localhost', 8080, '/static/')
    expect(url).to eq('http://localhost:8080/static/')
  end

  it 'returns a properly formatted url when port is passed as nil' do
    url = generate_url('http://localhost', nil, '/static/')
    expect(url).to eq('http://localhost/static/')
  end

  it 'returns a properly formatted url when port is passed as a string' do
    url = generate_url('http://localhost', '80', '/static/')
    expect(url).to eq('http://localhost/static/')
  end
end
