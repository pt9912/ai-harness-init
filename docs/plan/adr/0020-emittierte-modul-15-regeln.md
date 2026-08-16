# ADR-0020: Vom Observability-Modul geht nur die Doku-Konsistenz-Regel ins Ziel — als Konfiguration eines bereits mitgelieferten, advisory Trägers

**Status:** Proposed

**Datum:** 2026-08-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline — sie trägt den Träger von Festlegung 4 bereits, und ihre
Wachstums-Bedingung deckt dessen Konfiguration),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Durchsetzungs-Mechanik samt ihrem Budget — sie wächst durch keine
Festlegung dieser Entscheidung),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, an der die Verdrahtungs-Frage von Festlegung 5 hängt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
behaupten, was nicht läuft — die Regel, die der emittierte Träger durchsetzt und an der die
Rollen-Typen scheitern),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das
Abhängigkeitsbudget — es trägt die erste Nicht-Emission ausdrücklich **nicht**, s. Festlegung 1),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (die
konditionale Gate-Emission, deren Muster Festlegung 6 prüft und verwirft),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung und die
Idempotenz-Klassifikation; beide tragen Festlegung 1 und Festlegung 4),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — die Erfassungs-Policy des
Dogfood samt ihrer Werkzeug-Grenze),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — die permanente Grenze
derselben Achse),
[ADR-0013](0013-technik-stratum-als-zielort.md) (**Accepted** — das Gefäß folgt dem Gegenstand;
ihr vierter Re-Evaluierungs-Trigger fragt genau die Frage, die Festlegung 1 für heute
beantwortet),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form der Regelwerks-Belege
unten: Tag, Dateiname, Abschnitt, Zitat),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) (**Proposed** — ihre Folgepflicht 4 hält
fest, dass die emittierte Ebene keinen Agent-Guard führt und eine künftige Grenze dort **genannt**
gehört; Festlegung 2 baut darauf auf),
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md) (der Auflösungs-Trigger zweier Zellen —
verwiesen, nicht abgeschrieben),
[`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop: die Klasse, in der die Konfiguration des Trägers liegt),
[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
tool-generierte Gate-Fragment, in dem der Träger verbatim liegt),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — Festlegung 4 wendet sie an, Festlegung 5 grenzt
sie ab)

**Schärft:**
[`architecture.md §5 Idempotenz, Fragment-Assembly und Resume`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
— dort steht die Fragment-Assembly, an die Festlegung 4 die Konfiguration des Doc-Gates koppelt.
Aufwärts-Deklaration der Änderungskopplung: wer diese Entscheidung ändert, zieht von hier die
betroffene Spec-Stelle nach. **Das Vertrags-Stratum ist nicht berührt:** keine der sechs
Festlegungen bewegt eine Anforderung, und eine Nicht-Umsetzung mit Auflösungs-Trigger ist in einem
abnahmebindenden Stratum ein Widerspruch in sich ([ADR-0013](0013-technik-stratum-als-zielort.md):
das Gefäß folgt dem Gegenstand).

---

## Kontext

### Was entschieden ist, und was diese Entscheidung daran tut

Das Observability-Modul der adoptierten Baseline führt **vier** Regelblöcke — Span-/Audit-Attribute,
Token-Attribution, Cache-Counter, Doku-Konsistenz-Drift. Das Werkzeug emittiert das Regelwerk
**vollständig** ins Ziel; ein gebootstrapptes Repo bekommt damit alle vier Regeln und, bis hierher,
keinen einzigen Träger. Der Wellen-Plan der Modul-15-Konformität verlangt je Regelblock **und je
Ebene** einen belegten Zustand. Für die Tool-Spalte nennt er zwei eigene Werte, zu denen das
**ADR-Verdikt** als dritter tritt — permanent ist eine Eigenschaft der Abweichung, nicht der Ebene.
Die zwei lauten dort verbatim:

> **emittiert** — im Ziel vorhanden **und dort rot gesehen** (s. u.)
>
> **nicht emittiert** — begründete Entscheidung **mit Auflösungs-Trigger** — dieselbe Pflicht wie
> bei „deklariert"; eine Entscheidung, die sich ohne Trigger als temporär ausgibt, ist nach Modul 7
> die permanente Ausnahme, die lügt. Ist sie wirklich permanent, gehört sie in eine ADR und die
> Zelle trägt „ADR-Verdikt"

**Die Sach-Entscheidung ist am 2026-08-16 vom Auftraggeber gefallen** (zwei Setzungen desselben
Tages); diese ADR **trifft** sie nicht. Sie leistet vier Dinge: sie begründet die vier Werte, sie
prüft jeden Auflösungs-Trigger gegen den Trichter aus Modul 7 (beobachtbare Schwelle oder Absicht —
wo keine Schwelle trägt, gehört die Zelle auf *ADR-Verdikt*, und das ist eine Architektur- und keine
Auftraggeber-Frage), sie entscheidet die zwei Architektur-Fragen, die am Träger von Block 4 hängen,
und sie entkräftet die konditionale Emission, statt sie zu übergehen.

### Was heute im Ziel liegt — und was davon wirkt

Gemessen am Emissions-Pfad dieses Repos (2026-08-16, gelesen, nicht an einem frischen Ziel
gefahren):

- **Der Träger von Block 4 ist bereits da.** Das tool-generierte `d-check.mk` kommt aus
  `--print-mk` des gepinnten Doku-Gate-Images und trägt die advisory `doc-*`-Rezepte **verbatim**
  ([`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)),
  darunter `doc-targets`, das Modul der Deklarations-Konsistenz Doku ↔ Build-Targets. Es kostet
  keine Anforderung und kein Budget: es liegt in einer Datei, die
  [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) ohnehin
  zusagt.
- **Er ist wirkungslos, nicht grün.** Das Modul wertet erst mit einem `targets:`-Block der
  Konfiguration aus; weder die emittierte noch die hiesige `.d-check.yml` führt einen. Die Sonde,
  die das zeigt — heutige Konfiguration `0 Befund(e)`/Exit 0, mit Block `2 Befund(e)` der Art
  `gate-phantom`/Exit 1 —, ist im Plan dieses Schnitts gefahren und dort niedergelegt; dieser
  Architect-Lauf hat sie **nicht** wiederholt.
- **Der Erfassungs-Mechanismus ist ein Kompilat.** `cmd/span-emit` wird per Docker für die
  Host-Plattform gebaut, landet im gitignorierten Zustands-Bereich und wird von `.claude/settings.json`
  gerufen. Emittiert wird davon **nichts**: der Emit-Pfad führt die Kurs-Vorlagen, die
  Durchsetzungs-Mechanik, die Workflow-Commands, die Gate-Fragmente und den Aggregator — keinen
  Span-Emitter und kein `.claude/agents/`.
- **Die Rollen-Achse hängt nicht am Verzeichnis, und emittiert wird es von niemandem gelesen.**
  `grep -rn "claude/agents" --include=*.go .` liefert **null** Treffer, und dieselbe Zeichenkette
  steht in **keiner** Emissions- und keiner vendored Vorlage (beides am 2026-08-16 in diesem Lauf
  gefahren). Die Zuordnung Typ → Rolle lebt in einer hart notierten Liste in
  `internal/span/emit.go`; die erste der zwei Messungen steht als Grenze schon in
  [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md).

### Was das Werkzeug dem `targets:`-Block anbietet

Die Startkonfiguration des gepinnten Images führt den Block auskommentiert mit; der Wortlaut ist
verbatim (2026-08-16 aus dem gepinnten Image gedruckt, `--network none`):

```yaml
# targets:
#   makefiles: [Makefile]                        # Regelnamen-Quelle(n)
#   doc-tables: [AGENTS.md, harness/README.md]   # Dateien mit make-X-Tabellen (Richtung 1 ⇒ gate-phantom)
#   authority: AGENTS.md                         # Vollständigkeits-Quelle (Richtung 2 ⇒ gate-undocumented)
#   exempt-targets: []                           # Regelnamen EXAKT (kein Glob, anders als tracked) — Utility-Targets ohne Doku-Pflicht
```

Zwei Eigenschaften entscheiden Festlegung 4, und beide sind im Plan dieses Schnitts gemessen: das
Modul folgt `include` **nicht** (Targets aus einem eingebundenen Fragment gelten als Phantome, wenn
nur der Aggregator gelistet ist) und es nimmt **keine Globs** (`"*.mk"` endet fail-closed).

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Entscheidung; alle drei stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Der Erfassungs-Mechanismus bleibt ein Kompilat. Fällt das, fällt der tragende Grund von
  Festlegung 1.
- **(b)** Das Modul `targets` liest weiter nur genannte Dateien, folgt keinem `include` und nimmt
  keine Globs. Fällt das, verliert Festlegung 4 ihre harte Bedingung und die Kopplung an die
  Fragment-Assembly fällt weg.
- **(c)** Die emittierte Konfiguration bleibt *skip-if-present*
  ([ADR-0007](0007-bootstrap-phasen.md) Festlegung 3). Fällt das, ist der Wachstums-Weg aus
  Festlegung 4 neu zu wählen.

## Entscheidung

**Wir wählen Option F: nur Block 4 geht mit, ohne neues Artefakt, und die drei übrigen Blöcke
tragen begründete Nicht-Emissionen mit beobachtbarem Trigger.** Sechs Festlegungen.

**1. Der Erfassungs-Block wird nicht emittiert. Der tragende Grund ist die Phasen-Ordnung — nicht
das Abhängigkeitsbudget.** Geltungsbereich: die emittierte Ebene, jede Bootstrap-Variante. Der
Mechanismus ist ein kompiliertes Binär; ihn zu emittieren hieße eines von zwei Dingen, und beide
scheitern. **Quelle plus Bauschritt zur Init-Zeit** gäbe dem Ziel **Code vor seiner eigenen
Doc-Chain und vor seinem Sprach-ADR** — genau die Inversion, gegen die
[ADR-0007](0007-bootstrap-phasen.md) entschieden hat, und sie legte die Sprache am Schritt 0 fest,
nachdem dieselbe Entscheidung `--lang` gerade optional gemacht hat. **Ein vorgebautes Binär je
Zielplattform** wäre eine neue Artefakt-Klasse mit eigener Distribution und eigener
Plattform-Matrix und ließe die Aufzählung aus
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wachsen.
**Was den Grund ausdrücklich NICHT trägt:**
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 4 zieht die Grenze *„nicht zwischen
‚Shell' und ‚Sprache', sondern zwischen **vorhanden** und **zu installieren**"* und führt `docker`
auf der erlaubten Seite; das Budget allein verböte die Emission nicht. Wer sie später mit dem
Budget begründet, begründet sie falsch.

**Auflösungs-Trigger (T1) — eine Schwelle am Bestand dieses Repos, nicht am Ziel:** *die Erfassung
läuft ohne Kompilat* — `make span-check` ist grün, ohne dass zuvor `make span-emit-build` gelaufen
ist und ohne dass im gitignorierten Zustands-Bereich ein Binär liegt. Der Trigger liegt beim
**Mechanismus**, weil der Grund beim Mechanismus liegt. Er ist ohne Rückfrage beurteilbar, er liegt
in unserer Hand, und er ist kein Wunsch: dieses Repo liest dieselbe Hook-Payload bereits in
POSIX-awk (`harness/tools/extract-agent-call.awk`) und kodiert JSON in awk
(`harness/tools/json-encode.awk`) — die kompilierte Form ist eine Wahl, keine Notwendigkeit. Damit
ist der Trichter aus Modul 7 (`v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz)
Frage 2 mit *Ja* beantwortet, und die Zelle trägt **nicht emittiert**, nicht *ADR-Verdikt*.
**Und der Trigger beendet die Begründung, nicht die Entscheidung:** tritt er ein, ist die Frage neu
zu stellen, und ihr Inhalt ist dann die **Policy** — Schema, Redaktion, Ablageort. Was
[ADR-0011](0011-telemetrie-erfassung-policy.md) für den Dogfood entschieden hat, ist damit nicht
automatisch ein Adopter-Vertrag.

**2. Die Rollen-Typen gehen nicht mit.** Geltungsbereich: die sechs Dateien unter `.claude/agents/`.
Die Rolle ist ein Pflichtfeld genau des Erfassungs-Blocks; ohne Erfassung im Ziel hat sie dort
keinen Abnehmer. **Ohne Abnehmer wären sie eine Behauptung:** kein emittiertes Artefakt liest das
Verzeichnis (die zwei Null-Messungen oben), und ein Ziel ohne Span misst an einem rollen-benannten
Lauf nichts — das ist die Klasse, die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
höher verbietet. **Das Ziel bleibt darum nicht rollenlos:** die emittierte Ebene führt die
Workflow-Commands und den Reviewer-Skill; was die Typen hinzufügen, ist allein der **rollen-benannte
Span**, und genau der hat dort keine Senke.
**Auflösungs-Trigger (T3):** *der Erfassungs-Block wird emittiert* — ablesbar an einem frisch
gebootstrappten Ziel, das bei einem Tool-Call einen Span schreibt, in der Beleg-Form, die
`make full-smoke` für die Tool-Ebene führt. **T3 enthält T1 und ist kein zweiter Weg dorthin:**
wandert die Zelle aus Festlegung 1 je auf *ADR-Verdikt*, wandert diese mit.

**3. Token-Attribution und Cache-Counter werden nicht emittiert; ihr Trigger ist der von
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md), verwiesen und nicht wiederholt.** Beide
Blöcke hängen am selben Eingang wie die Repo-Seite: solange kein Agenten-Span Zähler trägt, trüge
auch ein emittierter Bericht nie eine Zahl. Eine zweite Fassung derselben Schwelle wäre die zweite
Wahrheit, die driftet. **Was hier hinzukommt und kein zweiter Trigger ist:** in dieser Spalte wirkt
die Schwelle **konjunktiv mit T1**. Ein Ziel, das nicht erfasst, hat nichts zu verrechnen; die
Auflösung von [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) allein macht keinen der beiden
Blöcke emittierbar. Das ist die Kopplung zu benennen, nicht eine Schwelle zu verdoppeln.
**Der zweite Ausgang gehört in dieselbe Festlegung:** fällt die Messung hinter dem Carveout negativ
aus und wird er in eine Folge-ADR überführt, wechseln **beide** Zellen von *nicht emittiert* auf
**ADR-Verdikt** — permanent ist eine Eigenschaft der Abweichung, nicht der Ebene.

**4. Der Doku-Konsistenz-Block wird emittiert, ohne neues Artefakt. Die Konfiguration nennt genau
den Datei-Satz, den die emittierende Phase selbst schreibt.** Träger ist das bereits mitgelieferte
`doc-targets`; neu ist **nur** seine Konfiguration. Vier Teil-Festlegungen:

- **(a) `makefiles:` nennt die fünf Init-invarianten Dateien** — den Aggregator `Makefile`, das
  tool-generierte `d-check.mk` und die drei Init-Fragmente aus `harness/mk/*.mk` (`baseline.mk`,
  `doc-gate.mk`, `enforce.mk`). **Das Kriterium ist keine Liste, sondern eine Eigenschaft:** genannt
  wird, was die emittierende Phase selbst schreibt und was darum in **jeder** Variante dieser Phase
  existiert. Fragmente späterer Phasen — das Code-Gate-Fragment je Modul, das Arch-Gate-Fragment,
  `a-check.mk` — werden **nicht** genannt.
- **(b) Warum diese Grenze und keine andere: die zwei Fehlerbilder sind nicht gleich schwer.** Eine
  genannte Datei, die einer Variante fehlt, tötet das Modul fail-closed für diese Variante; eine
  ungenannte Makefile lässt es echte Targets als Phantome melden. **Existenz ist die harte
  Bedingung, Vollständigkeit die weiche** — und die fünf sind der **eindeutig größte** Satz, der die
  harte Bedingung in jeder Variante erfüllt. Genau so entscheidet
  [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  einen emittierten Prüfbereich: nach dem Fehlerbild, nicht nach vermuteter Präferenz — der zu enge
  Default wird laut und kostet eine Zeile in einer Datei, die dem Adopter gehört.
- **(c) Die weiche Bedingung wird als benannte Wachstums-Pflicht getragen, nicht mechanisch.** Die
  emittierte Konfiguration führt den Block mit einem Kopplungs-Kommentar, der die Regel und beide
  Fehlerbilder nennt — dieselbe Form, in der sie ihre `ids`- und `codepaths`-Blöcke schon
  auskommentiert mitführt, und die Form, die
  [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) mit *„der
  Gate-Config wächst mit den Artefakten"* verlangt. **Eine tool-seitige Erweiterung ist
  ausgeschlossen:** die Konfiguration ist *skip-if-present*, und eine anhängende Sprach-Phase wäre
  der In-Place-Edit, den [ADR-0007](0007-bootstrap-phasen.md) für die Makefile verworfen hat
  (*„In-Place-Edit ist fragil + nicht idempotent (Re-Lauf/Reihenfolge-Drift)"*). Damit ist die
  Kopplung entschieden: sie ist **deklariert**, nicht automatisiert. **Warum die Konfiguration
  dennoch hier steht und nicht im Steering-Loop:** sie ist ein Gate-*Anheben* und bräuchte für sich
  keine Entscheidung
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
  Zu entscheiden ist nicht das Anheben, sondern die **Kopplung**, die es erzeugt.
- **(d) `authority:` bleibt weg — Richtung 2 wird nicht emittiert.** Sie verlangte, dass **jeder**
  Regelname der genannten Makefiles im `AGENTS.md` des Ziels dokumentiert ist; allein `d-check.mk`
  führt die advisory `doc-*`-Rezepte, die bewusst **kein** Gate behaupten. Richtung 2 machte damit
  aus der Regel des Qualitäts-Moduls (`v3.5.2`, `modul-13-quality-gates.md` §Hard Rule
  (Doku-Disziplin): *„Vorhanden ≠ behauptet. Verboten ist ein behauptetes Gate ohne Deckung, nicht
  ein vorhandenes Target ohne Anspruch."*) einen Befund. Die Ausnahmeliste nähme nur **exakte**
  Namen und driftete mit jedem Pin-Sprung des Images. Das Observability-Modul selbst trennt die
  Richtungen nach Härte (`v3.5.2`, `modul-15-observability.md` §Doku-Konsistenz-Drift-Regeln: *„ein
  neu hinzugefügtes Target ohne AGENTS.md-Eintrag ist Vorwärts-Drift (Doku hinkt nach), andere Härte
  als behauptete Geister-Befehle."*), und die Hard Rule, die es mindestens verlangt, ist
  Richtung 1. `doc-tables:` nennt die zwei Dokumente, die dasselbe Modul nennt.
- **(e) Reihenfolge, und sie ist Teil der Entscheidung:** der Block wird **nicht** emittiert,
  solange die emittierten Dokumente selbst Targets behaupten, die ein frisches Ziel nicht hat. Sonst
  benennt der erste Befund die Datei des Adopters, während die Ursache in unserer Emission liegt —
  und der Beleg der zweiten Richtung ginge im Grundrauschen unter.

**5. Ein advisory Träger verdient den Wert *emittiert*. Die Verdrahtung in `make gates` des Ziels
ist heute doppelt ausgeschlossen — und die Zelle trägt den Wert mit benanntem Gegen-Ausgang.**

- **(a) Der Wert verlangt zwei Dinge, und keines davon ist ein Gate-Lauf.** *„Im Ziel vorhanden und
  dort rot gesehen"* — `doc-targets` endet auf Befund mit Exit 1, und das ist rot, wer immer es
  fährt. *Rot gesehen* und *im Gate-Lauf* sind zweierlei.
- **(b) So ist
  [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  für einen advisory Träger zu lesen:** sein Geltungsbereich ist *„jeder Prüfbereich, dessen Schärfe
  wir für unbekannte Nutzer festlegen"*. Er entscheidet die **Schärfe eines emittierten
  Prüfbereichs** — und damit Festlegung 4(b) —, nicht den **Lebenszyklus seines Trägers**. Ihn auf
  die Verdrahtung auszudehnen, hieße *„laut falsch schlägt leise falsch"* von der Konfiguration auf
  die Aufhängung zu übertragen; das kollidierte mit der anderen Hälfte von
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und mit
  *„Vorhanden ≠ behauptet"*, auf dem die Nicht-Gate-Verify-Klasse dieses Repos steht.
- **(c) Was advisory kostet, ist nicht der Wert, sondern eine Angabe.** Das Observability-Modul
  verlangt je Doku-Konsistenz-Regel ein Feld **Lebenszyklus**; für die emittierte Regel lautet es
  *pre-integration, auf Abruf* — nicht *continuous*, und es gehört dort **genannt**, wo die Regel
  aufgeschrieben wird. Das Verifikations-Modul stellt eine Doku-Frage von sich aus dorthin
  (`v3.5.2`, `modul-11-verification.md` §Fitness Function ohne Standard-Tool: *„eine DoD-/
  Closure-Frage hängt an `verify:` (nicht `make gates` — das ist für Code-Architektur-Fragen)"*).
- **(d) Die Verdrahtung ist nicht bloß ungewählt, sondern heute zweifach ausgeschlossen, und beide
  Gründe sind strukturell.** Ein frisches Ziel bekommt Dokumente, die Targets behaupten, die es
  nicht hat — ein verdrahteter Träger wäre out-of-the-box rot und bräche
  [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen). Und nach der Sprach-Phase
  ist der Datei-Satz aus Festlegung 4(a) unvollständig, bis der Adopter ihn erweitert — ein
  verdrahteter Träger wäre rot für eine Variante, die wir selbst erzeugt haben. Beide Gründe sind
  behebbar; beide stehen unten als Re-Evaluierungs-Trigger.
- **(e) Die Zelle trägt den Wert, und seine zweite Hälfte ist geschuldet.** *Vorhanden* ist heute
  wahr; *rot gesehen* ist es nicht. Der Beleg gehört dem Slice, der ihn führt. **Gegen-Ausgang,
  damit ein gescheiterter Beleg keine leere Zelle hinterlässt:** lässt sich der eingebrachte Drift
  im Ziel nicht rot sehen, fällt die Zelle auf *nicht emittiert*, und ihr Auflösungs-Trigger ist
  dann Festlegung 4 dieser Entscheidung — der konfigurierte Träger, der rot werden kann.

**6. Die Erfassung wird auch nicht KONDITIONAL emittiert. Das Muster der konditionalen
Gate-Emission kondiert auf der falschen Achse.**
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) knüpft sein Gate
an die Existenz seines **eigenen Prüfbereichs** im Ziel — *„eine strukturelle Bedingung … keine
Liste von Architektur-Namen"*. Übertragen heißt die analoge Bedingung **nicht** *„das Ziel führt
eine Sprache"*, sondern *„das Ziel führt die Toolchain, die der Mechanismus braucht"* — und die ist
unsere, nicht die des Ziels. Ein Ziel mit Python-Skelett und Python-Sprach-ADR ist für diesen
Mechanismus so sprachlos wie ein reines Doku-Ziel; die konditionale Variante schrumpft damit auf
*„nur Ziele einer Sprache bekommen Telemetrie"* — die Namensliste, die dasselbe Lastenheft für
Architekturen ausdrücklich verbietet. **Zweitens ist der Gegenstand entgegengesetzt:** die
konditionale Emission nimmt einem Ziel ein Gate, das **nichts zu prüfen** hätte; hier nähme sie ihm
einen Mechanismus, der **alles zu erfassen** hätte — ein reines Doku-Ziel erzeugt Tool-Calls wie
jedes andere. **Drittens ist Telemetrie ein Init-Belang**, kein Sprach-Belang; ihn in die
Sprach-Phase zu hängen, gäbe einem Infrastruktur-Belang eine Bedingung, die er nicht hat.
**Und T1 ist die ehrliche Fassung derselben Idee:** die konditionale Variante kondiert auf das
**Ziel**, T1 auf den **Mechanismus**. Das erste kauft Telemetrie für eine Teilmenge zum Preis eines
sprach-gekoppelten Observability-Vertrags, das zweite für jedes Ziel zum Preis eines Umbaus.
**Das Muster selbst ist nicht verworfen:** es bleibt für jeden Observability-Belang verfügbar,
dessen Prüfbereich im Ziel strukturell entscheidbar ist.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **alle vier Blöcke emittieren** (Span-Emitter, Rollen-Typen, Auswertung, Doku-Konsistenz) | das Ziel bekäme das Modul, das sein Regelwerk führt, vollständig | die Inversion aus [ADR-0007](0007-bootstrap-phasen.md) am Schritt 0; eine neue Artefakt-Klasse mit Sicherheitsfläche (redigierte Tool-Argumente) im Ziel; zwei Blöcke ohne jeden Eingang — ein Bericht, der nie eine Zahl trägt, ist die Gate-Lüge als Kennzahl |
| B — **gar nichts emittieren**, das Ziel bekommt das Regelwerk und keinen Träger | ein Handgriff weniger; keine Kopplung an die Fragment-Assembly | der Träger von Block 4 **liegt schon im Ziel** — ihn ungenutzt zu lassen, ist keine Entscheidung, sondern die Leere, die diese Welle schließen soll. Und der billigste der vier Blöcke bliebe der offene |
| C — **konditionale Erfassung** nach dem Muster der Arch-Gate-Emission | „gar nicht" wäre nicht die einzige Alternative zu „immer"; ein Ziel mit Skelett bekäme sie | kondiert auf die falsche Achse — die gebrauchte Toolchain ist unsere, nicht die des Ziels; schrumpft auf eine Namensliste über Sprachen und koppelt einen Observability-Vertrag an die Zielsprache (Festlegung 6) |
| D — **Block 4 mit eigenem Artefakt** (ein Konsistenz-Skript in `bash`/`awk` im Ziel) | unabhängig vom Doku-Gate-Image und seiner Konfiguration | ein zweiter Träger neben dem mitgelieferten; die Aufzählung aus [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wüchse um eine Artefakt-Klasse — und damit entstünde eine Vertragsänderung, wo keine nötig ist |
| E — **Block 4 in `make gates` des Ziels verdrahten** | ein Gate schlägt einen Bericht, wo es tragen kann | heute doppelt ausgeschlossen: die emittierten Dokumente behaupten Targets, die ein frisches Ziel nicht hat, und der Datei-Satz der Konfiguration ist nach der Sprach-Phase unvollständig. Beides machte das Ziel out-of-the-box rot (Festlegung 5(d)) |
| **F — nur Block 4, ohne neues Artefakt, advisory; drei Nicht-Emissionen mit Trigger (gewählt)** | der vorhandene Träger wird wirksam, ohne dass eine Anforderung wächst; jede Nicht-Emission trägt eine am Bestand ablesbare Schwelle statt Schweigen; die Kopplung an die Fragment-Assembly ist entschieden statt vertagt | drei von vier Blöcken bleiben im Ziel ohne Mechanismus; die Vollständigkeit der Konfiguration ist eine **Adopter**-Pflicht, und wer ihr nicht folgt, bekommt wahr aussehende, falsche Befunde |

## Konsequenzen

- **Positiv:** die Tool-Spalte der Konformitäts-Matrix hat ihre vier Werte, und drei
  Nicht-Emissionen tragen je eine Schwelle statt Schweigen. Keine Anforderung wächst: kein Artefakt
  kommt hinzu, das Budget aus
  [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bleibt unberührt, und
  die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wächst nicht.
- **Positiv:** die offene Frage aus [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md)
  Folgepflicht 4 hat für heute eine Antwort — die emittierte Ebene bekommt keine Agenten-Telemetrie,
  und die Schwelle, die die Frage wieder öffnet, ist benannt statt vorausgesetzt.
- **Negativ, und das ist der Preis:** ein gebootstrapptes Repo liest ein Regelwerk mit vier
  Observability-Blöcken und bekommt für drei davon keinen Mechanismus. Der Trigger macht das
  vorläufig, nicht weniger wahr. **Und das Ziel erfährt es nicht:** eine Deklaration im Ziel wäre
  ein Artefakt, und genau das ist hier ausgeschlossen — die Grenze wird benannt, nicht geschlossen.
- **Negativ:** der emittierte Träger ist nur so lange stimmig, wie der Datei-Satz seiner
  Konfiguration dem Makefile-Satz des Ziels entspricht. Das Werkzeug kann diese Invariante über die
  Phasen hinweg nicht halten (Festlegung 4(c)); sie ist eine Adopter-Pflicht, und wer ihr nicht
  folgt, liest einen Befund, der ein echtes Target ein Phantom nennt.
- **Grenze, benannt statt nachgerüstet: über einer Abwesenheit gibt es keinen Wächter.** Der
  einzige geschlossene Datei-Satz im Emit-Pfad ist der der Kurs-Vorlagen; die Durchsetzungs-Emission
  prüft **Enthaltensein**, keine Vollständigkeit, und `make full-smoke` prüft Anwesenheit und Inhalt
  **genannter** Artefakte. Ein künftiger Span-Emitter oder ein mitgeliefertes `.claude/agents/`
  färbte damit keinen dieser Tests rot. Die drei Nicht-Emissionen tragen ihre Verbindlichkeit aus
  dieser Entscheidung, nicht aus einem Sensor.
- **Folgepflicht 1 — der Beleg emittiert nichts, was der Dogfood nicht selbst fährt.** Die
  Konfiguration aus Festlegung 4 ist auf **beiden** Ebenen dieselbe Frage: auch dieses Repo bindet
  sein `d-check.mk` per `include` ein und liefe in dasselbe fail-closed. Was ins Ziel geht, ist hier
  erprobt — die Reihenfolge *Erprobung → Entscheidung → Emission*, die derselbe Wellen-Plan zieht.
- **Folgepflicht 2 — die Reihenfolge aus Festlegung 4(e) bindet den emittierenden Schnitt.** Der
  `targets:`-Block darf erst mitgehen, wenn die emittierten Dokumente keine Targets mehr behaupten,
  die ein frisches Ziel nicht hat. Die Bedingung ist eine **Eigenschaft**, keine Adresse.
- **Folgepflicht 3 — [`architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
  nachziehen:** die Fragment-Assembly beschreibt heute den Aggregator und den Fragment-Drop, nicht
  die Kopplung, die Festlegung 4 an sie hängt. Der Nachzug gehört dem Eigentümer des Stratums, nicht
  dieser Entscheidung.
- **Folgepflicht 4 — wandert [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) in eine
  Folge-ADR, wandern zwei Zellen mit** (Festlegung 3). Das Carveout-Audit der Welle liest diese
  Festlegung mit.
- **Folgepflicht 5 — wird der Erfassungs-Block je emittiert, ist die Policy ein Adopter-Vertrag.**
  Dann sind Schema, Redaktion und Ablageort für ein fremdes Repo zu entscheiden, die Frage aus
  [ADR-0013](0013-technik-stratum-als-zielort.md) Folgepflicht 3 (bekommt das Zielrepo die
  Feldtabelle in seinem Technik-Stratum?) wird fällig, und die Grenze aus
  [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Folgepflicht 4 gehört dort **genannt**.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | Im frisch gebootstrappten Ziel läuft `make gates` grün, **und** das emittierte `make doc-targets` meldet eine eingebrachte, targetlose `make`-Zeile als `gate-phantom` und schweigt nach ihrer Rücknahme — die zwei Richtungen, die die Welle für die Tool-Spalte verlangt. **Geschuldet, nicht geliefert:** diese Entscheidung schreibt die Begründung, der Nachweis gehört dem Slice, der ihn führt | `make full-smoke` |
| **keines** | Für die drei Nicht-Emissionen gibt es keinen Wächter, und das ist eine Aussage, kein Auslassen: *„X wird nicht emittiert"* ist eine Behauptung über eine offene Menge. Der einzige denkbare Sensor wäre eine geschlossene Liste des gesamten emittierten Datei-Satzes; sie existiert nicht (§Konsequenzen). An ihrer Stelle steht diese Entscheidung — Feedforward, kein Feedback | — |

## Re-Evaluierungs-Trigger

- **Wenn T1 eintritt** *(feedforward — eine Schwelle am Bestand dieses Repos, kein Gate meldet
  sie)*: Annahme (a) fällt, Festlegung 1 ist neu zu prüfen, und mit ihr Festlegung 2. Die
  Folge-Entscheidung hat die Policy zu treffen, nicht bloß die Emission.
- **Wenn die Messung hinter [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) entschieden ist**
  *(feedback — sie hat einen entscheidbaren Ausgang, und beide Ausgänge binden)*: trägt der Weg,
  bleibt Festlegung 3 mit ihrer konjunktiven Bedingung; trägt er nicht, wechseln die zwei Zellen auf
  *ADR-Verdikt*.
- **Wenn das Modul `targets` einem `include` folgt oder Globs nimmt** *(feedforward — fremder
  Vertrag, sichtbar bei einem Pin-Sprung des Images)*: Annahme (b) fällt, Festlegung 4(a) verliert
  ihre harte Bedingung, und die Kopplung an die Fragment-Assembly entfällt samt der Adopter-Pflicht
  aus Festlegung 4(c).
- **Wenn beide Ausschlüsse aus Festlegung 5(d) gefallen sind** *(feedforward — an zwei Zuständen
  ablesbar: die emittierten Dokumente behaupten kein abwesendes Target mehr, und der Datei-Satz der
  Konfiguration bleibt über die Phasen vollständig)*: dann ist die Verdrahtung des Trägers in
  `make gates` des Ziels neu zu entscheiden. Sie ist heute ausgeschlossen, nicht abgelehnt.
- **Wenn die emittierte Konfiguration ihre Idempotenz-Klasse wechselt** *(feedforward — eine
  Änderung an [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3, kein Sensor)*: Annahme (c) fällt,
  und der Wachstums-Weg aus Festlegung 4(c) ist neu zu wählen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-16 | **Proposed** | Architect-Verdikt zu den zwei Auftraggeber-Setzungen desselben Tages: die Erfassung geht nicht mit, Block 4 bekommt kein neues Artefakt. Diese Entscheidung begründet sie, prüft die drei Trigger gegen Modul 7, entscheidet die Kopplung der Doku-Gate-Konfiguration an die Fragment-Assembly und entkräftet die konditionale Emission |
