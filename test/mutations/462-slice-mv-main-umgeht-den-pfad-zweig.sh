#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: TestSliceMvEchtSchreibtInReportsNurDieLinkForm
# verify: test-go
#
# main() ruft die Ersetzung fuer jede Form wieder direkt, statt rewrite_incoming_nach_baum
# zu rufen. Die Funktion mit dem Pfad-Zweig bleibt unveraendert richtig, main()
# BENUTZT sie nur nicht mehr: ein Review-Report bekaeme jede Adress-Form
# umgeschrieben.
#
# test/slice-mv.bats sieht das nicht: seine Faelle rufen rewrite_incoming_nach_baum
# selbst, nie main() — und das gepinnte bats-Image fuehrt kein git. Der Go-Test
# faehrt main() als echten Prozess ueber ein Repo.
#
# Der Anker ist die Zeile, die rewrite_incoming_nach_baum "$rf" mit `|| continue`
# ruft — eindeutig
# (grep -c 'rewrite_incoming_nach_baum "\x24rf"' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~rewrite_incoming_nach_baum "[$]rf" "[$]base" "[$]from" "[$]TO" || continue~rewrite_incoming_in_file "\x24rf" "\x24base" "\x24from" "\x24TO"~' harness/tools/slice-mv.sh
