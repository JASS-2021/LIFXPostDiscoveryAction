# syntax=docker/dockerfile:1
# ================================
# Build image
# ================================
# FROM hendesi/master-thesis:offical-swift-arm as build
# FROM swiftlang/swift:nightly-focal as build
FROM ghcr.io/apodini/swift@sha256:53b4295f95dc1eafcbc2e03c5dee41839e9652ca31397b9feb4d8903fe1b54ea as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libsqlite3-dev lsof zsh libavahi-compat-libdnssd-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# Copy all source files
COPY . .

# Build everything, with optimizations and test discovery and
RUN swift build -c debug

WORKDIR /staging

RUN cp "$(swift build -c debug --package-path /build --show-bin-path)/TestWebService" ./

# FROM hendesi/master-thesis:offical-swift-arm
FROM ghcr.io/apodini/swift@sha256:53b4295f95dc1eafcbc2e03c5dee41839e9652ca31397b9feb4d8903fe1b54ea as run
# FROM swiftlang/swift:nightly-focal

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*

# Create a apodini user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app apodini

WORKDIR /app

COPY --from=build --chown=apodini:apodini /staging /app

USER apodini:apodini

ENTRYPOINT ["./TestWebService"]
