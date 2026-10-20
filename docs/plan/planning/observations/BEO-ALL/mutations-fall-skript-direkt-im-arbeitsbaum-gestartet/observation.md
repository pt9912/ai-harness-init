# Mutations-Fall-Skript direkt im Arbeitsbaum gestartet

**Sub-Area:** `*` (gesamtes Repo)

Ein Fall-Skript aus `test/mutations/` verfälscht beim Lauf eine Quelldatei per `sed`; es ist für den Treiber `make mutate` oder
eine Kopie gebaut. Wird es von Hand direkt im Arbeitsbaum gestartet und scheitert sein `sed`-Anker, läuft es gegen die echte
Quelle. Zweimal in zwei Rollen beobachtet (Verifier, Implementer), beide Male ohne bleibenden Schaden: Der Rest wurde sofort
wiederhergestellt und am Diff gegen den Basisstand geprüft. Eine Anweisung im Rollen-Satz, die den Direktstart ausschließt,
besteht nicht; ein Sensor ebenso wenig.
