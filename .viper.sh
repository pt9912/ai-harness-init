brew install -y bats-core shellcheck actionlint bats go
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0
ln -sf "$HOME/go/bin/golangci-lint" "$HOME/.local/bin/golangci-lint"
