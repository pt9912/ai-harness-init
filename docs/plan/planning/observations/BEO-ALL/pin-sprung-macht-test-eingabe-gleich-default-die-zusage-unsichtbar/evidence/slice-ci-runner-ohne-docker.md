**Fundstelle:** Closure slice-ci-runner-ohne-docker (2026-11-27), drei Beobachtungen (Messung: Verifikations-Bericht `docs/reviews/2026-11-27-slice-ci-runner-ohne-docker-verify.md`, Bruchproben B-1 … B-2):

1. Der neue Wächter (`test/ci-runner-ohne-docker.bats`) hält die
   **Eigenschaft**, nicht den heutigen Pin-Wert: die Bindung liest die
   Werkzeug-Menge aus dem Inventar (`soll_anker`), es steht kein
   Soll-Literal im Wächter — ein Pin-Wechsel fällt unter dieselbe Bindung.
2. Rot-Zug an der realen Quelle: der kuratierte Fall 818 (go-Download-Zeile
   mit `1.30.0` am ci-runner-setup-Stück der `ci.yml`) färbt Fall 6 rot —
   ein *künftiger* Pin-Wert wird nicht unsichtbar (B-1).
3. Gegenprobe: eine Kommentar-Zeile, die denselben Wert nennt (`# probe go
   1.31.0` an `ci.yml`), färbt nicht (8 ok, B-2) — der Wächter misst den
   gelaufenen Soll, keine Nennung von ihm.
