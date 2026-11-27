# make gates — Fast-Pfad-Skip

## Vertrag

`make gates` ist der Einsprung der vollen Gates: sein Rezept startet den
Wrapper [`harness/tools/gates-fast.sh`](../../harness/tools/gates-fast.sh)
([ADR-0099](../../docs/plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)).
SKIP greift nur, wenn **beide** Stempel decken —
`.harness/state/gates-passed.diffsha` gegen den Arbeitsbaum-Hash von
[`harness/tools/working-tree-hash.sh`](../../harness/tools/working-tree-hash.sh)
und `.harness/state/gates-passed.head` gegen die aufgelöste HEAD-SHA
(`head_wert`, Kopplung: dieselbe Fassung wie `record-gates.sh` und der
Stop-Hook; `kein-commit` wird wie eine SHA verglichen). Jeder Zweifel —
fehlender, leerer, unlesbarer, gestutzter oder fremd geformter Stempel, HEAD
unaufösbar, Parser-Zweifel — fährt fail-closed den vollen Lauf über
`make record-gates`, dasselbe Rezept mit derselben Kante
(`record-gates: environment-check baseline-verify … span-check`; die Kante trägt seit
slice-environment-check-fuehrt-die-gates den Umgebungs-Check als ersten Eintrag).

## Der benannte Rest

Der SKIP urteilt über einen baum-abgeleiteten Schlüssel, und sein Rest liegt
außerhalb jedes baum-abgeleiteten Schlüssels: **der lokale Docker-Cache-Zustand
und die Host-Werkzeuge (bash, tar, git, docker)**
([ADR-0099](../../docs/plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
Festlegung 2, Wortlaut-Präzedenz
[ADR-0035](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4). Die SKIP-Meldung nennt ihn; `GATES_FORCE=1` erzwingt den vollen
Lauf, jeder andere Wert und das Fehlen sagen nichts (Festlegung 3).

## Wächter

- [`test/gates-fastpfad.bats`](../../test/gates-fastpfad.bats) — SKIP-Bedingung,
  fail-closed-Klassen, FORCE-Beleg (hermetisch über `--entscheide`), Verdrahtung
  (nur `exec make record-gates`, kein Stempel-Schreiben) und die drei
  `head_wert`-Fassungen gleich
- [`test/gate-nachweis-kante.bats`](../../test/gate-nachweis-kante.bats) — Kante
  an `record-gates` byte-gleich, `gates` ohne `make`-Prerequisites, Rezept startet
  nur den Wrapper

## Grenze

Der SKIP urteilt nie über das hinaus, was er sicher lesen kann; was er nicht
deckt, ist der benannte Rest und die Re-Evaluierungs-Trigger der ADR (bei jedem
künftigen Check im Kanten-Satz neu zu zeigen), nicht ein weiterer Sensor.
