echo "Building claude image..."
docker build --target claude -t claude .

echo "Building codex image..."
docker build --target codex  -t codex .

echo "Building ollama image..."
docker build --target ollama -t ollama .

echo "Building pandoc image..."
docker build --target pandoc -t pandoc .