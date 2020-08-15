# ---------------------
# ---- Build Stage ----
# ---------------------

FROM elixir:1.9.2-alpine AS app_builder

# https://stackoverflow.com/a/34545644/12315725


# Set environment variables for building the application
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8 \
    TOKEN=${TOKEN} \
    DB_HOST=${DB_HOST} \
    DB_USER=${DB_USER} \
    DB_PASSWORD=${DB_PASSWORD} \
    DATABASE_URL=${DATABASE_URL} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    REPLACE_OS_VARS=true

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /usr/local/src/app
WORKDIR /usr/local/src/app

# Copy over all the necessary application files and directories
COPY config ./config
COPY apps ./apps
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies and build the application
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# No static files in this project
# Also, cache_static_manifest is commented in prod.exs:
# config :soukosync_web, SoukosyncWeb.Endpoint,
#   cache_static_manifest: "priv/static/cache_manifest.json"
#
# Build assets
# COPY assets ./assets
# RUN cd assets && npm install && npm run deploy
# RUN mix phx.digest

# Build Release
COPY rel ./rel
RUN mix release

# ---------------------------
# ---- Application Stage ----
# ---------------------------
FROM alpine:3.12.0 AS app

# https://www.reddit.com/r/elixir/comments/694u35/issues_with_deploying_to_ec2/dh6yh9f/
ENV LANG=C.UTF-8 \
    REPLACE_OS_VARS=true


# Install openssl and htop
RUN apk add --update --no-cache \
            bash \
            openssl \
            ncurses-libs \
            postgresql-client \
            htop

# Copy over the build artifact from the previous step and create a non root user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
WORKDIR /home/app
COPY --from=app_builder /usr/local/src/app/_build .
RUN chown -R app: ./prod
USER app

# https://serverfault.com/a/824503
# https://stackoverflow.com/a/46540591/12315725
COPY --chown=app entrypoint.sh /home/app
RUN chmod +x /home/app/entrypoint.sh

# Run the Phoenix app
#ENTRYPOINT ./entrypoint.sh ${DB_HOST} ${DB_USER}
#ENTRYPOINT ./entrypoint.sh $DB_HOST $DB_USER
CMD ["./entrypoint.sh"]



