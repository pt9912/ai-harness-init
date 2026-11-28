# Slice rules-pointer-emission-v1: Drei Quellen-Pointer je `.claude/rules/` emittieren

**Welle:** ohne Welle — die Closure-Bedingung (DoD + Lerneintrag) ist keine weitere Bedingung, die eine Welle trüge.

**Bezug:** [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (das gebootstrappte Repo trägt den Agenten-Kontext), [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl) (Geltungsbereich-Grenze: „Dieses Repo, nicht das emittierte — was ein emittiertes Repo an Kontext-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet"), [`ADR-0109`](../../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) (Gates/Läufer docker-los).

**Berührte Spec-Stellen:** `—` — die `.claude/`-Emit-Struktur trägt keine Kennung in Lastenheft, Spezifikation oder Architektur; die Spezifikation nennt den Emitter ausschließlich für die Span-Erfassung (`SPEC-056`–`SPEC-065`), und die `.claude/rules/`-Kontext-Form ist Werkzeug-Ebene (MR-035, Geltungsbereich). Nicht ausgeschlossen, sondern nicht vorhanden: Es gibt kein Zielelement, auf das der Verweis in einem Hop auflöste.

**Verantwortlich:** —

**Autor:** pt9912 (Rolle Planner). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Bootstrap legt in jedem gebootstrappten Ziel die drei Quellen-Pointer unter `.claude/rules/` an — der Agenten-Kontext des Ziels rückt beim Sitzungsstart auf seine eigenen kanonischen Quellen und den Regelwerk-Index der vendored Baseline. Bestand (gemessen am Dogfood, `ls -la .claude/rules/`):

- `.claude/rules/AGENTS.md` → `../../AGENTS.md`
- `.claude/rules/harness-README.md` → `../../harness/README.md`
- `.claude/rules/regelwerk-README.md` → `../../.harness/baseline/v7.0.0/regelwerk/README.md`

Die `../../`-Formen gelten unverändert für das Ziel: `ls -la` des full-smoke-Baums zeigt `.claude/rules/` einen Schritt unter der Ziel-Wurzel, beide `..` lösen auf `<Ziel>/` — der `AGENTS.md`-, der `harness/`- und der `.harness/baseline/<tag>/`-Zweig existieren je emittiertem Ziel (AGENTS-Template, `harness/README.md`-Emission, Baseline-Fetch je `internal/fetch/baseline.go`, Tag `fetch.DefaultTag` = `v7.0.0`, derselbe wie im Dogfood-Zielpfad).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die vier Baseline-Modul-Pointer des Dogfood** (`modul-01-entwicklungszyklus.md`, `modul-05-planning-harness.md`, `modul-08-agentenrollen.md`, `grundlagen-traceability.md`) werden **nicht** emittiert. Sie folgen der geschlossenen Modul-Auswahl, die `MR-035` als Eigenschaft *dieses Repos* festlegt — Setzung 2: die Menge ist geschlossen, ein Eintrag mehr oder weniger ein neuer Eintrag des Blocks; der Geltungsbereich des Eintrags sagt ausdrücklich „Dieses Repo, nicht das emittierte". Eine vom Werkzeug hart emittierte Modul-Auswahl wäre ein Verzeichnis, das ohne Register-Eintrag wächst, und nähme der Ziel-Adoption eine Entscheidung ab, die ihr MR-035 überlässt. Die drei oben genannten sind anders geschnitten: Sie zeigen auf den Ziel-Baum selbst (AGENTS, harness/README, Baseline-Index) und sind für jedes gebootstrappte Ziel wahr.
- **Kein neuer make-Target, keine Gate-Konfigurations-Änderung.** Der Wächter ist ein Go-Test über dem Emit-Baum und eine full-smoke-Stufe — beide als Muster existierend (`internal/emit/*_test.go`, Stufen-Deklarationen in `harness/tools/full-smoke.sh`). Ein neuer Sensors-Eintrag wäre §3.1 (AGENTS.md) eine Ebene tiefer: eine Zusage, die der Gate-Index nicht trägt.
- **Kein Regelwerk-Inhalt wird kopiert, kein `paths:`-Frontmatter gesetzt.** `MR-035` Setzung 5 — die Symlink-Form schließt die bedingte Ladung aus, und ein kopierter Text wäre ein zweiter Wortlaut derselben Module, der driftet. Der Pointer trägt keinen eigenen Text.
- **Der `.claude/rules/`-Bestand des Dogfood bleibt unberührt.** Schicht-Abgrenzung: Dieser Slice entscheidet die Tool-Ebene (`internal/emit/`), nicht den Dogfood-Kontext; eine Änderung der Dogfood-Auswahl wäre ein neuer `MR-035`-Eintrag (§3.8 AGENTS.md: Architect), kein Teil dieser Implementation.

**ADR-Bedarf:** keiner vorgesehen. Die Form folgt dem bestehenden Emit-Muster (per-Datei-Ziele, Klassen `Konvergent`/`SkipIfPresent` je Bestand, neue Symlink-Anlage ist Werkzeug-Mechanik, kein neue Gate-Konfiguration). Nur wenn der Implementer die Bestands-Behandlung (Risiko 3) nicht in die bestehende Mechanik herunterbrechen kann und eine zweite Klassen-Achse bräuchte, wäre das ein Folge-ADR-Vorschlag — benannt im Plan, nicht vorab geöffnet.

## 2. Definition of Done

Gezählte Liefer-Punkte (drei):

- [ ] Der Bootstrap legt die drei Symlinks je gebootstrapptem Ziel an — Namen, Zielpfade und Quelle des Tags: der Baseline-Zweig trägt `fetch.DefaultTag` (`internal/fetch/baseline.go`), nicht einen hart kodierten String, damit ein Pin-Bump Zeiger und Baseline gemeinsam bewegt. Beleg: full-smoke-Stufe im gebootstrappten Baum — Existenz und Auflösung je Pointer (`os.Lstat`/`os.Readlink`-Form, Lesestelle `internal/archive/scan.go:160`). Nicht gemessen wird hier die Sitzungsstart-Ladung der Werkzeugschicht — die liegt außerhalb dieses Baums.
- [ ] Wächter: Go-Test über dem Emit-Baum (`internal/emit/rules_test.go`) hält je Pointer den Symlink-Modus (`os.Lstat`, `Mode()&fs.ModeSymlink`) und den `os.Readlink`-Wert byte-gleich gegen die drei erwarteten Zielpfade; fehlender Bestand oder ein regular file an der Stelle fällt rot. Nicht geprüft: ein Byte-Vergleich „Pointer-Text" — ein Symlink hat keinen Text, sein git-Blob ist der Zielpfad (Klasse des Fundes: `internal/archive/scan.go:155–161`, `lies()`).
- [ ] Mutations-Fall je `MR-071`: ein Fall in `test/mutations/<NN>-rules-pointer-fehlt.sh` (oder je Fall-Anlage-Konvention), dessen Patch den Pointer wegnimmt oder zum regular file macht und der den Wächter aus DoD-Punkt 2 rot färbt; `# files:` trägt je Bestand. Der Fall misst die Emission, nicht die Wirkung im Ziellauf — dafür ist der Wächter der Träger, und nach §3.6 (AGENTS.md) ist der Lauf des Wächters der Rot-Beleg.

Ungezählt (pro Slice konstant): `make gates` grün, Review-Report unter `docs/reviews/`, Doku-Update falls ein öffentlicher Vertrag berührt (hier: Stufen-Deklaration in `harness/tools/full-smoke.sh` und damit [`docs/user/e2e-abdeckung.md`](../../../docs/user/e2e-abdeckung.md) via `make e2e-abdeckung`, falls die Stufe deklariert wird — die Deklaration nennt, was der Lauf im Ziel misst), Closure-Notiz mit Lerneintrag, Beobachtungs-Register, Risiko-Ausgänge §6, drei Paarungen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/rules.go` | neu | Emit-Einheit je Pointer auf `.claude/rules/<name>`; Bestands-Prüfung je exaktem Namen; Tag aus `fetch.DefaultTag` |
| `internal/emit/rules_test.go` | neu | Happy (drei Pointer, Symlink-Modus + Readlink-Wert) / Negative (regular file statt Pointer, fehlender Bestand) |
| `internal/emit/emit.go` | update | Aufruf der neuen Emission im Bootstrap-Fluss — nach `fetch.Baseline`, das den Zielpfad des Baseline-Pointers voraussetzt |
| `harness/tools/full-smoke.sh` | update | Stufe: drei Pointer im gebootstrappten Ziel geprüft; Deklaration nennt die Teilmessung (Existenz + Auflösung, nicht Werkzeugschicht-Ladung) |
| `test/mutations/<NN>-rules-pointer-…` | neu | Rot-Fall je DoD-Punkt 3 (`MR-071` Fall-Anlage-Form) |
| `docs/user/e2e-abdeckung.md` | update | neu erzeugt via `make e2e-abdeckung`, falls die Stufe deklariert wird |

**Ansatz (Form der Bestands-Behandlung, trägt Risiko 3):** Die drei sind vom Werkzeug getragene Namen an einem vom Agenten-Werkzeug fixierten Pfad — dieselbe Verdrahtungs-Klasse wie `.claude/commands/`. Je exaktem Namen gilt: Kein Bestand → `os.Symlink` anlegen. Bestand als Symlink mit anderem Zielpfad → umsetzen (Pointer-Reparatur — genau der Re-Baseline-Fall, der den Tag im Zielpfad bewegt). Bestand als regular file → unberührt lassen (SkipIfPresent gegen fremden Text; MR-035 Setzung 5 schließt Überschreiben fremden Wortlauts aus). Reihenfolge im Bootstrap-Fluss nach `fetch.Baseline`, damit der Baseline-Zweig beim Anlegen auflöst.

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, `Verantwortlich:` gesetzt; kein Blocker — der gepinnte Baseline-Stand (`fetch.DefaultTag` = `v7.0.0`) ist derselbe, auf den der Dogfood-Zielpfad zeigt, die Zielpfade lösen netzlos.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Umfang wächst über die drei exakt genannten Pointer hinaus — insbesondere wenn während der Implementation die Modul-Pointer-Frage je Ziel ausgereizt wird oder ein vierter Name aufkommt; der Schnitt trägt genau drei Dateien und eine Stufe.
- `in-progress` → `open` (blockiert, Carveout?): Die Symlink-Anlage lässt sich nicht als Bestands-treue Erweiterung der bestehenden Emit-Mechanik (`writeFileMode` schreibt nur regular files) herunterbrechen und bräuchte eine zweite Klassen-Achse oder eine Gate-Konfiguration — dann zurück zum Schnitt mit Folge-ADR-Vorschlag.

## 5. Closure-Trigger

DoD einschließlich der drei Liefer-Punkte bestätigt (`make gates` grün, Wächter-Beleg je `internal/emit/rules_test.go`, Rot-Beleg des Mutations-Falls, full-smoke-Stufe im gebootstrappten Ziel), Review-Report unter `docs/reviews/`, Closure-Notiz §7 mit Lerneintrag fortgeschrieben, die drei Paarungen geprüft — Repo ohne Wellen-Betrieb: die Slice-Closure trägt sie selbst.

## 6. Risiken und offene Punkte

- **Der git-Blob eines Symlinks ist sein Zielpfad, kein Text** — die Pointer laufen in d-check/dok-check-Scans des Ziels als nicht-regular Einträge auf (Lesestellen `internal/archive/scan.go:155–161`). — **Ausgang:** entfallen: `lies()` überspringt nicht-regular Einträge (`Mode().IsRegular()` → übersprungen), und der Dogfood-Bestand unter `.claude/rules/` belegt dieselbe Klasse im laufenden Gate; die Pointer vergrößern den Scan des Ziels um keine geprüfte Datei.
- **Der Zielpfad des Baseline-Pointers trägt den Tag** (`v7.0.0`) — nach einem Baseline-Sprung im Ziel löst ein nicht nachgezogener Pointer ins Leere. — **Ausgang:** weiter offen: → `BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` im Register (der Slice trägt die gemeinsame Tag-Quelle `fetch.DefaultTag`, so dass ein Pin-Bump Zeiger und Baseline gemeinsam bewegt, und konvergiert den Pointer bei jedem Bootstrap-Lauf; ob ein Ziel, das den Baseline-Tausch ohne Bootstrap-Lauf vollzieht, einen Wächter braucht, trägt die Geplant-Kennung `slice-162-versions-sensor-baseline-pins`).
- **Ein Ziel trägt unter `.claude/rules/` eigenes Material des Adopters** (regular file oder eigener Pointer an denselben Namen). — **Ausgang:** entfallen: die Bestands-Behandlung je exaktem Namen (Ansatz in §3) nimmt keinen Adopter-Text umgeordnet — regular files bleiben unberührt, nur der eigene Pointer-Bestand wird auf den aktuellen Zielpfad umgesetzt; getragen je DoD-Punkt 1 (Form) und 2 (Negative-Fall regular file).
- **Bezugs-Prüfung aus dem Auftrag: MR-072** (Review-Report-Stub beim Archivieren) trifft die Pointer nicht — die Stub-Anlage läuft über denselben Scan-Zugriff wie das Doku-Gate und liest nicht-regular Einträge nicht; die Scan-Klassen-Form gilt damit nicht für diesen Slice. — **Ausgang:** entfallen: Klasse gemessen an `internal/archive/scan.go` (dieselbe `lies()`-Stelle), keine Berührung des Stub-Mechanismus.

## 7. Closure-Notiz

*(leer — fällt bei Closure; Reihenfolge je Template-Vermerk, `git mv` nach `done/` nach ADR-0109-Läuferlage in der Namensform je `MR-057`.)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen** (Schwelle ≥ 2 von 3 Achsen je berührter Sub-Area):

- `internal/emit` — Konventionen-Dichte: hoch (Generator-Klasse je `ADR-0005` „Tool-als-Quelle" in Code-Kommentaren getragen, per-Datei-Klassen-Mechanik, Träger-Tests je `*_test.go`); Phase-Reife: Phase 4 Produktionsbestand; Evidenz-/Diskrepanz-Risiko: gering, Code führt und Doku-Zellen folgen je Emission. ✓
- `test/` (full-smoke-Stufe, Mutations-Fall) — Konventionen-Dichte: hoch (Stufen-Deklarationen als Muster in `harness/tools/full-smoke.sh`, Fall-Anlage-Form je `MR-071`); Phase-Reife 4; Evidenz-Risiko: gering. ✓
- Doku-Zellen `harness/sensors/full-smoke.md` + `docs/user/e2e-abdeckung.md` — Konventionen-Dichte: Strukturregeln in `harness/conventions.md`/Index; Phase-Reife 4; Evidenz-Risiko: die Abdeckungs-Deklaration nennt ihre Teilmessung (gemessene Klasse: §3.6, emittierte Abdeckungs-Aussage). ✓

**Vorgelagert — offene Beobachtungen sichten** (Register, gemergter Stand, `docs/plan/planning/observations/`):

- `BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` — Stand offen. Trifft als Klasse dieses Slices: Der emittierte Pointer nennt Pfade; alle drei lösen im Ziel (Baseline vendored je `internal/fetch/baseline.go`), die Klasse des toten Pfades trägt auf den Tag-Fall des Risikos 2 und ist dort adressiert. Berührung notiert, Zähler 1×.
- `BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` — Stand geplant (`slice-162-versions-sensor-baseline-pins`). Trifft mit dem Tag-Zielpfad des Baseline-Pointers; §6 führt das Risiko mit Ausgang an diese Register-Kennung — zitiert statt neu benannt.
- `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` — Stand offen, 1×. Trifft: Die Emission gewinnt den Kontext-Pointer-Baum, den der Dogfood bereits trägt; die Abweichung ist hier Design-Frage (drei Quellen-Pointer, keine Modul-Auswahl) und in §1 mit MR-035 entschieden, keine neue Register-Anlage.
- Keine Treffer für `internal/emit` in der Pointer-Klasse selbst; keine Treffer unterhalb der Schwelle für die Doku-Zellen-Sub-Area.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — `internal/emit` ist Generator-Code, den das Doc-Briefing führt (Quelle: Code-Kommentare und Träger-Tests, kein Bestand, den die Doku erst beschreiben müsste); `test/` folgt der bestehenden Stufen-/Fall-Anlage-Konvention; die Doku-Zellen sind Fortschreibung zweier bestehender, vom Prozess erzeugter Sichten. Keine BF- oder Hybrid-Sub-Area berührt, darum kein Block pro Sub-Area.
