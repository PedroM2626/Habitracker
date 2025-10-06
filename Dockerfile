FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    openjdk-11-jdk \
    libglu1-mesa \
    libpulse0 \
    libx11-dev \
    libgl1-mesa-dev \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$PATH:$JAVA_HOME/bin"

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="$PATH:/usr/local/flutter/bin"

# Pre-cache Flutter artifacts
RUN flutter precache

# Accept Android licenses
RUN mkdir -p /usr/local/flutter/bin/cache/dart-sdk/bin
RUN yes | /usr/local/flutter/bin/flutter doctor --android-licenses

# Set up Android SDK environment variables
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"

# Create a working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Expose Flutter's default debug port
EXPOSE 5037

# Define the default command to run when the container starts
CMD ["flutter", "run", "--verbose"]