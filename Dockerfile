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
    SECRET_KEY_BASE=${SECRET_KEY_BASE}

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
RUN mix deps.get
RUN mix deps.compile
RUN mix phx.digest
RUN mix release

# ---------------------------
# ---- Application Stage ----
# ---------------------------
FROM alpine:3.12.0 AS app

ENV LANG=C.UTF-8


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



