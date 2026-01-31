FROM node:22-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y curl build-essential git

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install pnpm via npm, but install wasm-bindgen-cli via Cargo
RUN npm install -g pnpm@9.15.4
RUN cargo install wasm-bindgen-cli

WORKDIR /app
COPY . .

# Initialize submodules and build
RUN git submodule update --init --recursive
RUN pnpm install
RUN pnpm rewriter:build
RUN pnpm build

EXPOSE 1337
CMD ["node", "server.js"]
