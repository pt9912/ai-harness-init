**Vorgang:** slice-mutations-anker-greift-in-den-gates

**Fund:** `greift_case` in `harness/tools/mutate.sh` prüfte je Datei per `grep -F -- " $f"`; für `a.txt` traf das auch `a.txt.bak`, und ein Patch nur auf `.bak` zählte als gegriffen (Review M-2, Grenz-Sonde). Behoben auf Hash je exaktem Pfad.
