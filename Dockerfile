# syntax=docker/dockerfile:1

#
# This source file is part of the Apodini Template open source project
#
# SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
#

# ================================
# Build image
# ================================
FROM swiftarm/swift:5.5.1-ubuntu-focal as build

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

RUN cp "$(swift build -c debug --package-path /build --show-bin-path)/swift-lifx-discovery" ./

# ================================
# Run image
# ================================
FROM swiftarm/swift:5.5.1-ubuntu-focal as run

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*

# Create a lifx user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app lifx

WORKDIR /app

COPY --from=build --chown=lifx:lifx /staging /app

USER lifx:lifx

ENTRYPOINT ["./swift-lifx-discovery"]
