# MR-090 — Ein Sensor hält den Anker eines Mutations-Falls am Commit

> **ÜBERHOLT: §Grenze, der Halbsatz *„das bleibt beim nächtlichen `make mutate`"* → [`MR-091`](../conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt).** Ob der Wächter rot wird, prüft je Slice die Probe vor der Verifikation (lokal oder über den CI-Branch); der Nachtlauf bleibt der Vollsweep. Der Sensor, seine übrige Grenze und der Auflösungs-Trigger binden fort.

- **Datum:** 2026-10-09
- **Wirksamkeits-Anlass:** slice-mutations-anker-greift-in-den-gates — mit ihm läuft
  `make mutate-greift` in `make gates`, und der Satz *„Kein Sensor hält die Anlage"* in
  [`MR-071`](../conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  §Grenze stimmt nicht mehr.
- **Geltungsbereich:** [`MR-071`](../conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  §Grenze, Punkte 1 und 2 (die Meldung erst hinter Isolationskopie und Grün-Vorlauf; kein Sensor
  hält die Anlage) und die Entscheidung über seinen ersten Auflösungs-Trigger. **Nicht** die
  Regel von MR-071, nicht Punkt 3 ihrer Grenze, nicht die zwei Nachbar-Klassen `# files:` und
  `# expect:`, nicht die emittierte Ebene.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag nennt den Sensor zu einer Regel dieses Blocks
  und tritt an keine Baseline-Stelle; nach dem Wortlaut der Eintrags-Vorlage damit kein Fork, aus
  demselben Grund wie bei MR-071.
- **Adaption.** Den `sed`-Anker jedes Falls hält `make mutate-greift` (`harness/tools/mutate.sh
  --greift`, in `make gates`): je Fall laufen die `# files:` auf einer Kopie außerhalb des Repos,
  der Patch wird angewandt, und jede Datei muss sich ändern — sonst `mutate-greift: BEFUND <fall>`
  und Exit 1. Kein Grün-Vorlauf, kein Sensor-Lauf, kein Docker. Vertrag, Tests und Zähne stehen in
  [`harness/sensors/mutate.md`](../sensors/mutate.md) §Greift-Modus; dort und nicht hier, damit
  sie nicht in zwei Fassungen driften. Die Regel aus MR-071 bleibt die Feedforward-Hälfte, der
  Sensor ist ihre Feedback-Hälfte.
- **Grenze.** Der Sensor hält, dass der Anker **trifft**, nicht, dass der Wächter rot wird — das
  bleibt beim nächtlichen `make mutate`. Ein Anker, der die falsche Stelle trifft (Zeilennummer, zu
  breites Muster), geht durch; das ist
  [`mutations-fall-an-zeilennummer-verankert`](../../docs/plan/planning/observations/BEO-ALL/mutations-fall-an-zeilennummer-verankert/observation.md).
  Ob `# files:` die **richtige** Datei nennt, sieht er nicht, `# expect:` liest er nicht. Er läuft
  ohne Container und braucht GNU `sed`/`mktemp` auf dem Host — mehr, als
  [`AGENTS.md`](../../AGENTS.md) §3.9 als Host-Bedarf nennt; ein Nicht-GNU-Host ist nicht gemessen.
  Dass seine Fixtures den Stand `98bfab0b^` tragen, hält kein Sensor.
- **Auflösungs-Trigger von MR-071, der erste — eingetreten, Neuwägung: die Regel bleibt.** Der
  Trigger nennt die Meldung *vor der Isolationskopie*; der Greift-Modus meldet ohne sie, am Commit.
  Die Neuwägung, die der Trigger verlangt: Die Regel kostet nichts und macht den Commit beim ersten
  Lauf grün; der Sensor fängt, was sie verfehlt. Keine der beiden ersetzt die andere, MR-071 bleibt
  aktiv und trägt eine Kopf-Marke nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger);
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  greift nicht. **Der dritte Trigger** (*drei weitere Vorgänge … ein Sensor oder ein
  Folge-Vorgang ist die Antwort*) ist mit diesem Eintrag beantwortet, gleich ob er schon steht: die
  Antwort, die er verlangt, ist dieser Sensor.
- **Begründung:** Ein Satz *„kein Sensor"* neben einem laufenden Sensor ist eine Grenze, die zu
  wenig verspricht — der nächste Lauf sucht ihn nicht oder baut ihn doppelt.
- **Auflösungs-Trigger:** `make mutate-greift` verlässt `make gates` (Laufzeit, Host-Abhängigkeit):
  dann gilt MR-071 §Grenze Punkt 2 wieder, und dieser Eintrag geht nach `done/`. Ein Sensor hält
  auch die **Stelle** des Treffers: dann ist die Grenze oben neu zu fassen.
