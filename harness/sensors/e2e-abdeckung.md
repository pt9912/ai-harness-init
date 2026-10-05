# `make e2e-abdeckung` — erzeugt die E2E-Abdeckungs-Sicht

## Vertrag

erzeugt [`docs/user/e2e-abdeckung.md`](../../docs/user/e2e-abdeckung.md) aus den Stufen-Deklarationen in `harness/tools/full-smoke.sh` — liest Text, fährt keinen E2E. **Dieselbe Mechanik bekommt ein gebootstrapptes Ziel:** es fährt sein eigenes `make e2e-abdeckung` über den Stufen seines eigenen E2E, mit denselben zwei Lücken-Richtungen und derselben Spaltenfolge, ohne neue Abhängigkeit (Text lesen, kein Container, kein Netz); **seine** Kennungsspalte trägt Code-Spans statt Verweise — ein Anker ließe sich dort nur nachbilden, nicht halten; was dort ziel-spezifisch ist, steht als Marker ([`make full-smoke`](full-smoke.md) misst es am Ziel)

## Bindung

den Inhalt der erzeugten Datei hält ein Fall in [`test/e2e-abdeckung.bats`](../../test/e2e-abdeckung.bats) (läuft in `make test`)
