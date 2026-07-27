# Review-Report: ADR-0010 (Proposed, Runde 3) — 2026-07-27

**Review-Art:** **Design** — dritte Proposed-Runde. Prüfgegenstand ist **nicht** die ganze ADR
erneut, sondern **(a)** ob die Befunde aus Runde 2 aufgelöst sind und **(b)** ob der Fix **neue**
Probleme eingeführt hat. Runde 3 ist fällig, weil der Fix die Runde-2-Festlegung **umgekehrt** hat
(treibende Seite: Composition Root → Schicht) und eine dritte Festlegung hinzukam — nach dem Verdikt
von Runde 2 genau der Fall „erneut substanzielle Änderung".

**Gegenstand:** [ADR-0010](../plan/adr/0010-hexagonal-arch-realisierung.md), Fassung Runde 3
(weiter *Proposed*), Commit `d05cd24`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Eingangs-Kontext:** die überarbeitete ADR · Runde 1 und Runde 2 der Proposed-Reviews · **die
Regel-Engine des gepinnten Arch-Gates im Quelltext** (Rollen-Inferenz, Purity-Regeln,
Erst-Treffer-Ordnung der Konnektivitäts-Regeln, `Direction`-Dimension) · die `.a-check.yml` **und der
reale Import-Graph** beider Referenz-Repos · unsere hexslice-Config in `internal/gen/golang.go` ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)

---

## Findings

### N-1 — Der Fix widerlegt die Prämisse von Festlegung 1: die Familie verdrahtet **in** der CLI

- `kategorie`: **HIGH**
- `quelle`: ADR §Entscheidung Festlegung 1 („emittiert wird die gelebte Familien-Konvention … real
  gebaut und real geprüft") gegen §Konsequenzen (treibende Seite als Schicht) ·
  [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (das Skelett muss lauffähig sein)
- `pfad`: ADR §Entscheidung, Festlegung 1 (Tabelle) + §Konsequenzen (Absatz „Negativ, und bewusst
  in Kauf genommen")
- `befund`: Runde 3 macht `internal/adapter/driving/**` zu einer Schicht mit `role: adapter` und
  nimmt `composition_root` auf `cmd/**` zurück. **Gemessen an beiden Referenzen ist genau das der
  Ort, an dem sie ihre getriebenen Adapter konstruieren:**

  | Repo | Datei | importiert getriebene Adapter |
  |---|---|---|
  | erstes Referenz-Repo | `internal/cli/cli.go` <!-- d-check:ignore (Pfad im externen Referenz-Repo) --> Zeilen 15–18 | `driven/config`, `driven/extract`, `driven/graph`, `driven/report` |
  | zweites Referenz-Repo | `internal/adapter/driving/cli/cli.go` <!-- d-check:ignore (Pfad im externen Referenz-Repo) --> Zeilen 20–24 | `driven/configyaml`, `driven/fs`, `driven/git`, `driven/httpcheck`, `driven/report` |

  Beim zweiten Repo importiert `cmd/**` <!-- d-check:ignore (Pfad im externen Referenz-Repo) -->
  **keinen einzigen** Adapter — die Verdrahtung liegt vollständig in der CLI. Beide Repos exemten
  ihre CLI also nicht aus Bequemlichkeit, sondern weil die Exemtion **tragend** ist.

  Unter Runde 3 ist derselbe Import ein Befund der Klasse **`lateral-adapter`** („Adapter importiert
  anderen Adapter"). Diese Regel ist **kategorisch und kanten-unabhängig**: sie steht in der
  Erst-Treffer-Ordnung der Konnektivitäts-Regeln **vor** allen Richtungs-Regeln
  (`lateral-adapter → lateral-slice → tech-leak → port-direction-mismatch → port-locality →
  wrong-direction`). Eine Kante `driving→driven` würde sie **nicht** aufheben.

  Damit steht die ADR in sich: Festlegung 1 begründet die Pfadwahl damit, dass die Familie so
  **real gebaut und real geprüft** wird — und Runde 3 verbietet demselben Code seine reale Form.
  Das emittierte Skelett muss seine Verdrahtung nach `cmd/**` verlegen; das ist eine
  **Struktur**-Vorgabe an den Renderer, die die ADR nicht macht.
- `verifizierbar`: ja — die vier bzw. fünf Import-Zeilen beider CLIs; `grep -rn
  "internal/adapter/driven" cmd/` im zweiten Repo (leer); die Erst-Treffer-Ordnung in der
  Regel-Engine (`connectivityRule` → `lateralRule`).
- **Konsequenz:** die ADR muss sagen, **wo im emittierten Skelett verdrahtet wird**, und die
  Abweichung von der Familien-Form an dieser Stelle **benennen**, statt sie unter „strenger als die
  Referenzen" zu subsumieren. Ohne das müsste der Renderer raten — dieselbe Klasse wie F-1 aus
  Runde 1, diesmal auf der Verdrahtungs-Seite.

### N-2 — Die Rolle der `core`- und `ports`-Schicht ist unbestimmt, und der Name entscheidet sie

- `kategorie`: **HIGH**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate, das falsch rot färbt oder still leer läuft)
- `pfad`: ADR §Entscheidung, Festlegung 1 (Tabelle: Spalte „im Arch-Gate")
- `befund`: Die Tabelle vergibt **explizite** Rollen nur für `driven` und `driving` („Rolle
  *adapter*"). Für `core` und `ports` steht nur „Schicht `core`" / „Schicht `ports`" — dort greift
  die **Namens-Inferenz** der Engine (`core→domain`, `ports→port`, `adapters→adapter`,
  `application`/`app`→`app`). Die Folge ist nicht kosmetisch:

  - Rolle `domain` ist **kategorisch rein**: importiert eine `domain`-Schicht `app`, `port`,
    `adapter` oder eine Tech, ist das `core-impurity` — **unabhängig von jeder Kante**. Ein
    `core→ports`-Import ist damit unmöglich, und die ADR führt eine solche Kante konsequenterweise
    auch nicht.
  - Dann kann der emittierte Kern **keinen getriebenen Port aufrufen**. Zusammen mit N-1 (die CLI
    darf keinen Adapter mehr sehen) bleibt als Konsument der Ports nur `cmd/**` — die
    `ports`-Schicht des Skeletts wäre nahezu funktionslos, obwohl das Layout sie trägt.
  - Die beiden Referenzen lösen das **verschieden**: das erste hält den Kern rein (kein einziger
    `hexagon/port`-Import unter `internal/hexagon/core/**` <!-- d-check:ignore (Pfad im externen Referenz-Repo) -->) und orchestriert in der exemten CLI; das zweite **teilt** den Kern
    (`model` = `role: domain`, `rules`/`app`/`coretest` = `role: app`) und führt genau deshalb die
    Kanten `rules→ports` und `app→ports`.
  - Unser eigenes `hexslice` umgeht die Frage über eine **eigene** `app`-Schicht mit `role: app`
    und der Kante `app→ports` (`internal/gen/golang.go:516`, `:525`).

  `hexagonal` hat nur **eine** Kern-Schicht. Ob sie `domain` (rein, aber ohne Port-Zugriff) oder
  `app` (Port-Zugriff, aber ohne Kern-Reinheitsprüfung) trägt, ist eine Festlegung — die ADR trifft
  sie nicht, und die Namens-Inferenz trifft sie stillschweigend zugunsten von `domain`.
- `verifizierbar`: ja — `EffectiveRole`/`inferRole` und `impurityFinding` in der Regel-Engine;
  `grep -rn "hexagon/port" internal/hexagon/core` im ersten Referenz-Repo (0 Treffer im Code); die
  `layers:`-Blöcke beider Referenz-Configs; `internal/gen/golang.go:504-534`.
- **Konsequenz:** Festlegung 1 muss die Rolle **jeder** Schicht ausschreiben, nicht nur die der
  beiden Adapter-Schichten — und mit ihr, ob der emittierte Kern getriebene Ports konsumieren darf.

### N-3 — Die Direction-Dimension des Gates kommt in einer ADR über *driving/driven* nicht vor

- `kategorie`: MEDIUM
- `quelle`: ADR §Konsequenzen („wir prüfen die treibende Seite **strenger als beide Referenzen**")
- `pfad`: ADR §Entscheidung, Festlegung 1
- `befund`: Das gepinnte Arch-Gate kennt eine **eigene, zweckgebaute Dimension** für genau diese
  Achse: `Direction` (`driving|driven`), orthogonal zur Rolle, **nie** aus dem Namen inferiert, und
  sie steuert die Regel `port-direction-mismatch`. Ein leerer Wert **meldet die Schicht davon ab** —
  `directionMismatch` verlangt auf **beiden** Seiten einen gesetzten Wert.

  Die ADR entscheidet die treibende Seite, ohne diese Dimension zu erwähnen; mit **einer**
  `ports`-Schicht ohne `direction:` bleibt `port-direction-mismatch` dauerhaft stumm. Ein
  treibender Adapter darf dann den **getriebenen** Port importieren, ohne dass etwas meldet — eine
  Lücke in genau der Richtung, für die Runde 3 die Strenge erhöht hat. Keine der beiden Referenzen
  nutzt `direction:`; „strenger als beide Referenzen" gilt also für die Schicht-Zuordnung, nicht
  für diese Achse.
- `verifizierbar`: ja — das `Direction`-Feld samt Kommentar im Layer-Modell der Engine,
  `directionMismatch` (beide Seiten müssen gesetzt sein), `grep -n "direction" <repo>/.a-check.yml`
  in beiden Referenzen (0 Treffer).
- **Konsequenz:** die ADR muss die Dimension entweder **nutzen** oder ihr Weglassen als Entscheidung
  benennen. Stillschweigen liest sich als Übersehen — und die Strenge-Aussage der Konsequenzen ist
  ohne sie enger, als sie klingt.

### N-4 — Alternative E: „gemessen" ohne Quelle, und die Zahl zählt zwei Zuwächse als einen

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.1 (keine Behauptung ohne Beleg) · ADR §Verglichene Alternativen, Zeile E
- `pfad`: ADR §Verglichene Alternativen
- `befund`: Zwei getrennte Probleme in derselben Zelle.

  **(a) Provenienz.** Die Zeile sagt „**gemessen**: … je belegter Kombination kostet der
  Voll-E2E-Smoke **~45 s** CI-Wanduhr (Median 174 s → 218 s beim letzten Zuwachs)". Die ADR nennt
  **keine Quelle** — kein Lauf, kein Target, kein Commit, kein Closure-Beleg. Im Repo ist zu keiner
  der drei Zahlen ein Fundort auffindbar. Eine Sitzung, in der gemessen wurde, ist kein Beleg für
  ein Dokument, das die Sitzung überlebt; „gemessen" ohne Zeiger ist in diesem Repo eine
  Behauptungs-Klasse, die es mit `comment-claims` selbst bekämpft.

  **(b) Arithmetik.** Belegt sind heute **vier** Kombinationen (`go × flat`, `go × hexslice`,
  `cpp × flat`, `cpp × hexslice` — `harness/tools/full-smoke.sh`). Die Flavour-Frage stellt sich
  **nur für `hexagonal`**: `flat` hat keine treibende Seite zu platzieren, `hexslice` hat sie
  festgelegt. Der Zuwachs von 4 auf 6 gehört also zu **dieser** ADR (die zweite Architektur), und
  die Flavour-Achse trägt **+2** (6 → 8), nicht +4. Auch die genannte Formel
  („2 Sprachen × 2 Architekturen × 2 Flavours") reproduziert die heutigen 4 nicht, weil `flat`
  darin nicht vorkommt. Die Contra-Spalte der **verworfenen** Option ist damit rund **doppelt** so
  teuer dargestellt, wie sie ist.
- `verifizierbar`: ja — `grep -rn "174\|218" docs/` (kein Fundort); die vier `add-lang`-Aufrufe in
  `harness/tools/full-smoke.sh`.
- **Konsequenz:** entweder die Messung mit Fundort versehen oder das Wort „gemessen" streichen; die
  Kombinations-Rechnung auf den Zuwachs beziehen, der der Flavour-Achse wirklich zufällt. Eine
  Ablehnung darf nicht auf einer Zahl stehen, die die Alternative teurer macht als sie ist.

### N-5 — Die Begründung nennt den falschen Wirkmechanismus

- `kategorie`: LOW
- `quelle`: ADR §Entscheidung, Festlegung 1 (Satz nach der Kanten-Aufzählung)
- `pfad`: ADR §Entscheidung
- `befund`: „**Keine** Kante `driving→driven`: ein treibender Adapter ruft keinen getriebenen direkt
  auf" — das Ergebnis stimmt, der genannte Grund nicht. Gefangen wird der Import von der
  **kategorischen** Regel `lateral-adapter` (zwei Schichten mit `role: adapter`), die **vor** den
  Richtungs-Regeln greift. Die Kanten-Abwesenheit ist nicht der Hebel: wer die Kante später
  **einträgt**, um den Import zu erlauben, bekommt weiterhin rot und hält das Gate für kaputt.
- `verifizierbar`: ja — `lateralRule` vor `directionRule` in `connectivityRule`; der Testfall zu
  „role:adapter → role:adapter" in der Engine.

### N-6 — Festlegung 3 ist eine repo-weite Regel im Bauch einer Layout-ADR

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 (Entscheidungen müssen auffindbar sein)
- `pfad`: ADR §Entscheidung, Festlegung 3
- `befund`: Festlegung 3 ist inhaltlich tragfähig und sauber begründet — aber sie sagt von sich
  selbst, sie gelte „**über diese ADR hinaus für jeden emittierten Prüfbereich**". Wer künftig nach
  der Default-Regel für emittierte Artefakte sucht, sucht sie nicht in einer ADR über das
  hexagonale Go-Layout. Dieselbe Regel wirkt bereits an drei Stellen (Guard-Boden,
  Mutations-Sensor, `comment-claims`), ohne dass eine davon auf sie zeigt.
- `verifizierbar`: ja — Volltextsuche nach „fail-closed" im Regel-/Konventions-Teil des Repos.

## Negativbefunde

- geprüft, ohne Befund: **N-1 aus Runde 2 ist geschlossen** — unterhalb `internal/adapter/` fällt
  kein Pfad mehr durch alle Globs; `driving/**` ist vollständig gedeckt. Die Klasse „stiller,
  ungeprüfter Bereich" existiert in dieser Fassung nicht mehr.
- geprüft, ohne Befund: **N-2 aus Runde 2 ist geschlossen** — Folgepflicht 5 ist ergänzt und
  benennt Doku-Pflicht *und* den Lockerungs-Weg.
- geprüft, ohne Befund: **die explizite `role: adapter` ist notwendig, nicht dekorativ** — die
  Namen `driven`/`driving` inferieren **keine** Rolle (die Inferenz kennt nur
  `core`/`ports`/`adapters`/`application`/`app`); ohne den expliziten Eintrag wären beide Schichten
  nur kanten-geprüft, und `lateral-adapter` könnte gar nicht feuern. Die ADR schreibt ihn hin.
- geprüft, ohne Befund: **der Runde-2-Absatz wurde ersetzt, nicht überschrieben** — die Umkehrung
  ist im Absatz selbst offengelegt; Status ist *Proposed*, [`AGENTS.md`](../../AGENTS.md) §3.4
  greift also noch nicht. Die Geschichte führt Runde 2 **vor** Runde 3 und verweist auf den Review,
  der den Fix ausgelöst hat.
- geprüft, ohne Befund: **Festlegung 2 ist unberührt** — die Trennung der Layouts und ihr
  Bewachbarkeits-Argument stehen unverändert; die Umbenennung `adapters` → `driven`/`driving`
  berührt sie nicht.
- geprüft, ohne Befund: **die neue Fitness-Function-Zeile nennt ein reales Target**
  (`make a-check-<modul>`, im `make full-smoke`) — kein Wunsch-Sensor. Zur Regel-Benennung siehe N-5.
- geprüft, ohne Befund: **`make gates` grün nach dem Commit**, `make docs-check` 222 Dateien /
  0 Befunde.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 0 |

## Verdikt

**Merge-blockierend:** **ja** — zwei HIGH. Runde 3 hat den Befund aus Runde 2 sauber geschlossen und
dabei die Klasse gewechselt: aus einem **stillen Loch** ist eine **laute Regel** geworden — das war
die Absicht, und der Weg dorthin (Festlegung 3) ist die stärkste Passage der ADR. Der Preis ist, dass
die neue Strenge zwei Dinge berührt, die die Fassung nicht mitzieht: **wo verdrahtet wird** (N-1 —
beide Referenzen tun es genau dort, wo es jetzt verboten ist) und **welche Rolle der Kern trägt**
(N-2 — die Namens-Inferenz entscheidet es sonst stillschweigend, und dann kann der Kern keinen Port
sehen). Beides muss der Renderer wissen; heute müsste er raten.

Das ist derselbe Ertrag wie in den Vorrunden — Runde 1 fing die fehlende treibende Seite, Runde 2 das
Loch unter ihr, Runde 3 die Struktur-Folgen ihrer Schließung. Kein Befund verlangt einen Umbau der
Entscheidung; alle vier oberen verlangen, dass die ADR **ausspricht**, was sie bereits impliziert.

**Empfehlung:** N-1 und N-2 in Festlegung 1 entscheiden, N-3 und N-4 in ihren Abschnitten
nachziehen; N-5/N-6 sind Präzision und Ablageort. Eine vierte Runde ist danach **nicht** nötig,
solange die Entscheidung selbst (Layout, Trennung, fail-closed) unverändert bleibt — dann prüft die
Verifikation des Slices, nicht ein weiterer Design-Review.

**Übergabe:** an die Architektur-Rolle. Nichts wird akzeptiert, solange N-1 und N-2 offen sind.
