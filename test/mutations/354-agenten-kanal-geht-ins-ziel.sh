#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestCommitMsgTraeger_ZielTraegtNurDenGitKanal
# verify: test-go
#
# DER AGENTEN-KANAL GEHT INS ZIEL: die Durchsetzungs-Menge bekommt einen zweiten
# Commit-Message-Traeger unter .claude/hooks/ — die Form, die dieses Repo fuer seine
# Agentenlauf-Klasse fuehrt und die das Ziel nach harness/README.md §Traceability NICHT
# bekommt. Die Kennungs-Zusage haengt dort am git-eigenen Hook.
#
# WARUM DAS DIE FEHLHANDLUNG UND KEINE ANDERE IST: der Traeger liegt dann zweimal im Ziel,
# und die README nennt einen. Wer die zwei Kanaele als dieselbe Sache liest, greift genau
# danach — der Fehler ist die Aussage ueber die Traeger-Menge, nicht der einzelne Pfad.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird die emittierte
# Pfad-Menge, nicht ein Lauf — der Bootstrap braeuchte Docker und ein Zielrepo. Dass der
# Kanal im Ziel wirklich ueber den Agenten greift, ist eine Eigenschaft des Agentenlaufs
# und steht in keiner Ziel-Stufe dieses Repos.
set -euo pipefail
sed -i 's@commitMsgHookFile(),@{src: "templates/enforce/commit-msg-traceability.sh", dst: ".claude/hooks/pretooluse-commit-msg-guard.sh", mode: 0o755, class: Konvergent},\n\t\tcommitMsgHookFile(),@' internal/emit/enforce.go
