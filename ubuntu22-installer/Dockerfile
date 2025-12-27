FROM debian-power8:bookworm

# Set noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    vim \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN apt-get update && apt-get install -y locales && \
    sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8

# Verify POWER8 compatibility
RUN echo "Testing POWER8 compilation..." && \
    echo "int main() { return 0; }" > /tmp/test.c && \
    gcc -mcpu=power8 -o /tmp/test /tmp/test.c && \
    /tmp/test && echo "POWER8 compilation: SUCCESS"

CMD ["/bin/bash"]
