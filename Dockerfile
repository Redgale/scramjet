# Use Node 22 Bookworm as the base
FROM node:22-bookworm

# 1. Install system dependencies
# Added 'binaryen' to provide wasm-opt
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    binaryen \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Manually add Cargo to the PATH so subsequent layers can find 'cargo' and 'wasm-bindgen'
ENV PATH="/root/.cargo/bin:${PATH}"

# 3. Install global Node tools and Rust WASM tools
# Added wasm-snip as requested by your build script
RUN npm install -g pnpm@9.15.4 \
    && cargo install wasm-bindgen-cli \
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
# This should now find cargo, wasm-bindgen, wasm-opt, and wasm-snip
RUN pnpm rewriter:build

# 9. Final application build
RUN pnpm build

# 10. Start the application
# Change 'start' to whatever your package.json uses (e.g., 'pnpm run dev' or 'node server.js')
EXPOSE 8080
CMD ["pnpm", "start"]
