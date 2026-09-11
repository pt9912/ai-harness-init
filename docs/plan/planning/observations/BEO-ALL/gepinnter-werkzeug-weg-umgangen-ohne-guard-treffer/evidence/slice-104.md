**Vorgang:** slice-104
**Fund:** Ein Implementer-Lauf startete die Go-Tests einmal als `docker run golang:1.27.0 go test`
statt über das `make`-Ziel — dasselbe Versions-Literal wie `GO_VERSION` im `Dockerfile`, aber per
Tag statt per Digest (`grep -nE '^ARG GO_VERSION|^FROM golang:' Dockerfile`) und ohne die
Vorwärm-Stufe und `-count=1` der `test`-Stage. Der Guard blieb stumm, der Lauf hat den Fehlgriff
selbst gemeldet und danach ausschließlich `make`-Ziele gefahren; am Code ist nichts entstanden.
