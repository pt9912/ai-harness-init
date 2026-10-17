# `dupl` meldet ähnlichen Testcode zweier Sprach-Skelette

**Sub-Area:** `*` (gesamtes Repo)

Die Fragment-Tests zweier JVM-Sprach-Skelette (Kotlin und Java) sind einander so ähnlich, dass `make lint`
(`dupl`) sie als Duplikat meldet; die Behebung ist ein gemeinsamer Test-Helfer statt einer Suppression
([`AGENTS.md`](../../../../../../AGENTS.md) §3.2).
