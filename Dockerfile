# From latest ruby version
FROM bearstech/ruby:3.0

RUN apt-get update -y \
	&& apt-get upgrade -y

# Declare args
ARG REVISION
ARG RELEASE_TAG

# Add user
RUN useradd -ms /bin/bash lmo

# Create src dir
RUN mkdir /opt/lmo

# Workdir
WORKDIR /opt/lmo

# Copy code
COPY . .

# Ownership
RUN chown -R lmo:lmo /opt/lmo

# User
USER lmo

# Profiles dir
ENV LMO_PROFILES_DIR="/srv/lmo/profiles"
VOLUME "/srv/lmo/profiles"

# Download all the world
RUN bundle install

# image-spec annotations using labels
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.source="https://github.com/papey/lmo"
LABEL org.opencontainers.image.revision=${GIT_COMMIT_SHA}
LABEL org.opencontainers.image.version=${RELEASE_TAG}
LABEL org.opencontainers.image.authors="Wilfried OLLIVIER"
LABEL org.opencontainers.image.title="lmo"
LABEL org.opencontainers.image.description="lmo runtime"
LABEL org.opencontainers.image.licences="ANTI-FASCIST LICENSE"

# setup default args
CMD ["exec", "ruby", "bin/bot.rb"]

# setup entrypoint command
ENTRYPOINT ["bundle"]
