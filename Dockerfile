FROM ruby:2.5
RUN apt-get update && apt-get install -y sudo && \
    sudo apt-get install zlib1g-dev liblzma-dev patch && \
    gem install nokogiri --platform=ruby && \
    gem install anemone
