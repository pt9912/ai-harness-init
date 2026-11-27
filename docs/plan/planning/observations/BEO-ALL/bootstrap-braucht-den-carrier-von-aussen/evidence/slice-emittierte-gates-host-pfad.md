**Fundstelle:** Closure slice-emittierte-gates-host-pfad (2026-11-27), drei Beobachtungen (Messung: Verifikations-Bericht `docs/reviews/2026-11-27-slice-emittierte-gates-host-pfad-verify.md`, V-5 und der neue Befund):

1. Bootstrap eines tmp-Ziels mit dem HEAD-Binary („`make host-bin`") lief nur
   mit **extern geliefertem** `DCHECK_CARRIER` (Exit 0) — ohne ihn kein
   Carrier-Weg, der Default-Weg bleibt Docker-getrieben; die Zusage
   „Bootstrap braucht nur git" ist auf dem Carrier-Weg nicht erreicht.
2. Die d-check-Ablage im Ziel entsteht ebenso von außen — im realen frischen
   Ziel nur `make dcheck-fetch` (Netz an genau diesem Aufruf).
3. `make gates` im gebootstrappten Ziel riss an `environment-check`, dem
   ersten Check („2 von 7 Pflicht-Werkzeugen tragen ihr Soll nicht"), darunter
   der neue Befund: die emittierte golangci-Soll-Form trug das v-Pin-Präfix
   (`v2.15.0`), war von keinem Träger erreichbar und im F-9-Zug (`0be90f31`)
   behoben — v-freie Ableitung in der Dogfood-Form, Mutations-Fall 813 mit
   belegtem Rot-Zug.
