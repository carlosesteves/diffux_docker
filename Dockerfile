FROM phusion/baseimage:latest

RUN add-apt-repository ppa:brightbox/ruby-ng

# Install Java
RUN apt-get update -qq && apt-get install -qqy openjdk-7-jdk unzip git redis-server imagemagick phantomjs build-essential

# Install ruby 2.0
RUN apt-get install -qqy ruby2.1 ruby2.1-dev libpq-dev libsqlite3-dev

# Install diffux
RUN git clone https://github.com/diffux/diffux.git 
RUN gem install bundler
RUN cd diffux && bundle install

# Add config
RUN cd diffux && cp config/database.yml.example config/database.yml

# Setup DB
RUN cd diffux && bundle exec rake db:setup

# Enable ssh
RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

WORKDIR diffux

# Run diffux
CMD bundle exec rails s & redis-server & bundle exec sidekiq


