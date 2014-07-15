source "https://api.berkshelf.com"

# This is a fork of the ffmpeg cookbook in supermarket. It has not
# been uploaded to supermarket.
cookbook 'ffmpeg', git: 'https://github.com/phoolish/chef-ffmpeg.git'

# Required until https://github.com/opscode-cookbooks/gunicorn/pull/11 is merged in
cookbook 'gunicorn', git: 'https://github.com/nickryand/gunicorn.git', branch: 'matchers'

# Required until Runit > 1.5.10 is pushed to supermarket
cookbook 'runit', git: 'https://github.com/hw-cookbooks/runit.git'

metadata

group :integration do
  cookbook "apt"
end
