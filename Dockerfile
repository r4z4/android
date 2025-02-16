# Use the official OpenJDK image from Docker Hub
FROM openjdk:11-jdk

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Download and install Android SDK command-line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && cd ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O commandlinetools.zip \
    && unzip commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm commandlinetools.zip

# Install SDK packages
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-32" "build-tools;32.0.0"

# Clone your Android project into the container
RUN git clone https://github.com/yourusername/your-android-project.git /usr/src/app

# Set working directory
WORKDIR /usr/src/app

# Make the gradlew script executable
RUN chmod +x ./gradlew

# Pre-install project dependencies (Optional, but speeds up first build)
RUN ./gradlew build --no-daemon || true

# Default command to run when starting the container
CMD ["./gradlew", "assembleDebug"]
