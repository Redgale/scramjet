FROM node:22-bookworm

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    binaryen \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Rust - Pinning to 1.82.0 to avoid "invalid flags byte" errors
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.82.0
ENV PATH="/root/.cargo/bin:${PATH}"

# 3. Install global Node tools and Rust WASM tools
# We keep wasm-bindgen at 0.2.100 as Scramjet requires
RUN npm install -g pnpm@9.15.4 \
    && cargo install wasm-bindgen-cli --version 0.2.100 \
    && cargo install wasm-snip

# 4. Set working directory
WORKDIR /app

# 5. Copy project files
COPY . .

# 6. Initialize submodules
RUN git submodule update --init --recursive

# 7. Install dependencies
RUN pnpm install

# 8. Run the WASM rewriter build
RUN pnpm rewriter:build

# 9. Final application build
RUN pnpm build

# 10. Start the application
EXPOSE 8080
CMD ["pnpm", "start"]
