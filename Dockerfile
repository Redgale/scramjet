FROM node:22-bookworm

# Install Rust and Wasm tools
RUN apt-get update && apt-get install -y curl build-essential && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN npm install -g pnpm wasm-bindgen-cli

WORKDIR /app
COPY . .

# Build process
RUN git submodule update --init --recursive
RUN pnpm install
RUN pnpm rewriter:build
RUN pnpm build

EXPOSE 1337
CMD ["node", "server.js"]
