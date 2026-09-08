# Verifikation — slice-127: Hard Rule §3.4 bekommt ihren Sensor (`vcs`-Modul)

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-08

**Prüfgegenstand:** die zwei Implementer-Commits `0a20eff6` (erste Runde, sieben Commits ab
`6a2e0d5f`) und `fc92aca5` (Behebungs-Runde, ein Commit gegen den Review-Report
`docs/reviews/2026-09-08-slice-127-adr-immutabilitaet-vcs-review.md`, der mit 1 HIGH/5 MEDIUM/3
LOW/2 INFO blockierte). `HEAD` beim Abschluss dieser Prüfung ist `82ec62201c04c9f3b2342a5012d9304cdc13a262`,
`git status --porcelain` leer. Zwischen dem Ende des Auftrags (`fc92aca5`) und diesem Abschluss
liegen drei weitere Planner-Commits (`ffcba387`, `63d85a30`, `87cd30cd` — slice-203/205) sowie ein
vierter (`82ec6220` — Beobachtungs-Register `hintergrund-lauf-wird-gepollt-statt-abgewartet`);
selbst geprüft mit `git show --stat --pretty=format:'%s' <c>` für jeden: **keiner** berührt eine
Datei von `slice-127`. **Kein Self-Review:** dieser Lauf hat weder `0a20eff6` noch `fc92aca5`
geschrieben, und der vorausgehende Review-Report stammt aus einem eigenen Kontext.

**Prüfgrundlage:** die DoD-Punkte (1)–(3) aus dem Slice-Plan (alle drei unangehakt), die
Review-Behauptungen des Implementer-Fix-Commits, `AGENTS.md` §3.4/§3.6/§3.7/§3.10/§3.11,
`LH-QA-01`/`LH-QA-02`, `MR-001`/`MR-007` Setzung 3.

---

## Gate-Stand (selbst gefahren, zweimal)

Zwei unabhängige Läufe, beide **EXIT 0**:

1. In einer isolierten Kopie (`git clone --local --no-hardlinks`, außerhalb des Arbeitsbaums, HEAD
   = `fc92aca5`): `make gates` → `baseline-verify: v6.5.0 OK — 54 Dateien`,
   `d-check: 993 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 57 Datei(en) geprueft,
   0 Befund(e)`, alle sieben `vcs`-bats-Fälle (`ok 232`–`ok 238`) grün.
2. Direkt im Arbeitsbaum, auf dem tatsächlichen aktuellen `HEAD` (`82ec6220`, drei fremde Commits
   später): `make gates` → `EXIT 0`, `d-check: 994 Datei(en) geprüft, 0 Befund(e)` (eine Datei mehr
   als in der Kopie — das neue Register-Verzeichnis aus `82ec6220`, keine Diskrepanz),
   `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)`, dieselben sieben `vcs`-Fälle grün,
   `git status --porcelain` danach weiterhin leer.

`make docs-check` separat gegen `HEAD` gefahren: `994 Datei(en) geprüft, 0 Befund(e)`.

---

## Die Review-Fixes — unabhängig reproduziert

Eigenes Sonden-Paar (isolierte Kopie, `git config user.*` lokal gesetzt, `git commit`), gepinnter
Digest `sha256:e31a372b…` (Tag `v0.74.1`) über `make adr-immutable RANGE=<base>..HEAD`. Alle
Proben gegen `BASE=fc92aca5`, ein Test-Commit je Probe, danach `git reset --hard`:

| Probe | Erwartung | Ergebnis (selbst gemessen) |
|---|---|---|
| **HIGH-1**: Zusatz hinter `Accepted` (`Accepted (ueberholt, gilt nicht mehr — siehe ADR-0041)`) | rot | `1 Befund(e)` · `core-drift-vcs` — **behoben** |
| Kontrolle: beliebige andere Kernzeile geändert | rot | `1 Befund(e)` · `core-drift-vcs` — Modul trennt weiterhin scharf |
| **MEDIUM-1**: Übergang auf gelebte Link-Supersede-Form (`Superseded by [ADR-0040](0040-x.md)`) | grün | `0 Befund(e)` |
| Übergang auf `Deprecated` (neu erlaubt) | grün | `0 Befund(e)` |
| Übergang auf `Accepted` unverändert | — | `0 Befund(e)` (kein Diff im Kern) |
| Übergang auf bare Supersede-Form (`Superseded by ADR-0040`, weiterhin ausgeschlossen) | rot | `1 Befund(e)` · `core-drift-vcs` — bewusst so, MEDIUM-1-Zusage eingehalten |
| **MEDIUM-1-Begründung** (`ids` deckt die bare Form NICHT innerhalb `docs/plan/adr/`): bare `ADR-0005`-Erwähnung angehängt an eine Datei unter `docs/plan/adr/` | grün (kein `ids`-Befund) | `make docs-check` → `993 Datei(en) geprüft, 0 Befund(e)` |
| dieselbe bare Erwähnung in `docs/plan/planning/in-progress/roadmap.md` | rot (`id-unlinked`) | `1 Befund(e)` · `docs/plan/planning/in-progress/roadmap.md:185 ADR-0005 id-unlinked` |
| **MEDIUM-2**: `status-line` entfernt, dann legitimer Link-Supersede-Übergang | rot (Statuszeile fällt in den vollen Kern) | `1 Befund(e)` · `core-drift-vcs` — **behoben**, Zusage hält |
| **DoD (3)**: `RANGE=HEAD..HEAD` | Abbruch, Exit ≠ 0 | `history-range-guard: … aufloesbar, aber LEER (0 Commits)`, **Exit 2** |
| **LOW-1**: reiner `git mv` einer `Accepted`-ADR (`0003-…` → `0003-umbenannt.md`) | rot | `1 Befund(e)` · `core-drift-vcs` — *„immutable Datei geloescht oder umbenannt"* — bestätigt weiterhin ungetrennt, wie `harness/README.md` jetzt selbst sagt |

**Die zwei ADR-Bezüge, die der Plan nennt** (§1: *„die zwei superseded ADRs tragen `**Status:**
Superseded by [ADR-0003](0003-go-native-binaries.md)` bzw. dieselbe Form mit ADR-0005"*), gegen
ihren tatsächlichen Text gehalten: `docs/plan/adr/0001-skelett-distribution.md` Zeile 3 trägt
wörtlich `**Status:** Superseded by [ADR-0005](0005-ziel-repo-distribution.md)`,
`docs/plan/adr/0002-test-tooling-grenze.md` Zeile 3 wörtlich `**Status:** Superseded by
[ADR-0003](0003-go-native-binaries.md)` — beide exakt die Link-Form, die `head-allow` jetzt trägt
und die oben als grün reproduziert ist. Die Charakterisierung des Plans trägt.

**Byte-Messungen der MEDIUM-3-Begründung** (`harness/README.md`) selbst nachgerechnet:
`8.0 %`-Durchschnitt und `28.1 %`-Maximum (`0012-haupt-kontext-ohne-token-bilanz.md`) stimmen exakt;
die drei `Revidiert (Teil-Supersede)`-Treffer liegen alle **vor** ihrem jeweiligen
`## Geschichte`-Header (Zeilennummern-Vergleich je Datei), bestätigen also *„liegen im geschützten
Kern, keine im Geschichte-Abschnitt"*.

**Negativbefunde des Reviews** (Checkout-Zählung, `Deprecated` im ADR-Vokabular) ebenfalls
nachgerechnet: 8 `actions/checkout`-Vorkommen repo-weit, genau 1 mit `fetch-depth: 0`; die
ADR-Vorlage (`.harness/baseline/v6.5.0/templates/docs/plan/adr/NNNN-titel.template.md` Zeile 11)
und `docs/plan/adr/README.md` Zeile 60 führen `Proposed`/`Accepted`/`Deprecated`/`Superseded by
ADR-NNNN` — beide bestätigt.

**Alle sechs neuen/geänderten `test/mutations/`-Fälle** (`277`, `280`–`284`) sind über den
vollständigen `make mutate`-Lauf gefahren (nicht nur einzeln in Isolation) — siehe unten.

---

## Die `mutate`-Behauptung — vollständig nachgefahren

Eigener, vollständiger `make mutate`-Lauf in einer isolierten Kopie (`git clone --local
--no-hardlinks`, HEAD = `fc92aca5`, 4 Worker, kein Docker-Netz, hermetisch außer den vendored
Images). Laufzeit ca. 30 Minuten, vollständig protokolliert (849 Log-Zeilen). Ergebnis:

```
mutate: untere Schranke jeder Parallelisierung = laengster Einzelfall: 105.70 s (199-mutate-zeitschranke-greift-nie); Fall-Arbeit gesamt 6852.1 s
mutate: 269 ok, 1 Befund(e)
```

`grep -cE "OK \(|BEFUND \(" mutate-out.log` → **270** (deckt sich mit *„270 Faelle auf 4 Worker"*
aus der Lauf-Kopfzeile) — **kein** Fall fehlt in der Auswertung. Genau **eine** `BEFUND`-Zeile:

```
mutate: [w2] 221-ignore-refs-restbreite                 BEFUND (43.26 s)
mutate: BEFUND  221-ignore-refs-restbreite   rot, aber '…jede Top-Level-ignore-refs-Ausnahme deckt hoechstens einen Markdown-Link ihrer Quelldatei' faellt nicht — falscher Grund
```

Das ist wortgleich der Zustand, den Review-INFO-1 unabhängig hergeleitet hat (stale `# expect:`,
Wächter selbst intakt, Treiber meldet fail-closed *„falscher Grund"*). **Die sechs neuen/geänderten
vcs-Fälle sind darunter alle `OK`:** `277-vcs-head-allow-bare-kennung`,
`278-vcs-exclude-sections-ohne-geschichte`, `279-vcs-in-modules-aktiviert`,
`280-vcs-head-allow-ohne-endanker`, `281-vcs-status-line-entfernt`,
`282-vcs-paths-klasse-verfehlt`, `283-vcs-immutable-when-verfehlt-kopfzeile`,
`284-vcs-head-allow-duplikat` — acht, nicht sechs, weil der Fix-Commit auch die zwei
Bestandsfälle `277`–`279` der ersten Runde unverändert mitträgt; alle acht treffen ihren
`# expect:`-Wächter.

**Auftragspunkt 3 ist damit beantwortet:** Der eine Befund ist **exakt** `221`, kein zweiter. Die
Aussage aus der Commit-Message (*„269 ok, 1 Befund(e) — der eine ist der vorbestehende,
außerhalb dieses Slice liegende Fall 221"*) trägt vollständig — selbst reproduziert, nicht
übernommen. Der Zwischen-Stand der Koordinator-Nachricht (`.harness/state/mutate.lock` weg,
`mutate-passed.key` fehlt, also `fail_count > 0`) ist mit diesem Ergebnis konsistent, war aber für
diese Prüfung nicht die tragende Quelle — die eigene Reproduktion ist es.

**Was diese Reproduktion nicht abdeckt:** Sie lief in einer isolierten Kopie auf `fc92aca5`, nicht
auf dem heutigen `HEAD` (`82ec6220`). Die drei dazwischenliegenden Commits ändern keine Datei, die
`make mutate` als Fall oder als geprüfte Datei führt (slice-203/205-Pläne, ein
Beobachtungs-Register-Eintrag) — der Fall-Satz und sein Ergebnis sind damit für den heutigen `HEAD`
ebenso gültig, aber nicht noch einmal am heutigen Stand gefahren.

---

## DoD, Punkt für Punkt

1. **„Eine Änderung am Kern einer angenommenen ADR färbt den Lauf rot — und eine Änderung in einem
   ausgenommenen Abschnitt nicht."** — **erfüllt.** Beide Hälften oben unabhängig reproduziert
   (Kern-Änderung → `core-drift-vcs`; `## Geschichte`-Änderung bleibt grün, bereits im Review
   geprüft und in dieser Prüfung durch die HIGH-1-Kontrollzeile — beliebige Kernzeile geändert →
   rot — erneut bestätigt).
2. **„Der erlaubte Supersede-Übergang bleibt grün, und das ist belegt."** — **erfüllt.** Der
   gelebte Link-Übergang bleibt grün (oben reproduziert, zusätzlich gegen die zwei realen ADRs
   0001/0002 gehalten), `head-allow`/`exclude-sections`/`status-line` sind gegen den realen Bestand
   gesetzt (nicht den Default-Vorschlag), und die MEDIUM-2-Lücke (`status-line` ungewacht) ist
   geschlossen — eigene Reproduktion des vorher blockierenden Fehlschlags nach Entfernen des
   Schlüssels bestätigt, dass der Fix trägt.
3. **„Der Lauf fällt, wenn seine Range nichts hergibt — statt grün zu melden."** — **erfüllt.**
   `make adr-immutable RANGE=<h>..<h>` bricht mit `history-range-guard: … LEER (0 Commits)`,
   Exit 2, selbst reproduziert. Die Kettung an `history-range-guard` (aus slice-123) bleibt intakt.

Alle drei Häkchen im Slice-Plan sind **unverändert offen gelassen** — korrekt, das Setzen ist
Planner-Arbeit (`AGENTS.md` §3.10), nicht Sache dieser Prüfung.

**Standard-Punkte:**

- `make gates` grün — **erfüllt**, zweimal selbst gefahren (isolierte Kopie **und** Arbeitsbaum auf
  aktuellem `HEAD`).
- `make mutate` ohne Befund — **nicht erfüllt, im engen Wortlaut, aber ohne Blocker-Charakter.**
  `269 ok, 1 Befund(e)` — der eine Befund ist der vorbestehende, außerhalb dieses Slice liegende
  Fall `221` (INFO-1 des Reviews, Klasse *Mutations-Fall überlebt die Umbenennung seines
  Wächters*, verortet auf `slice-197`). Kein Fall aus diesem Slice ist betroffen. Der Wortlaut der
  DoD-Vorlage („ohne Befund") deckt diesen Fall nicht als Ausnahme — das ist ein **Formmangel im
  Standard-Punkt selbst**, kein neuer Sachbefund dieses Slice, und identisch zu dem, was der Review
  in INFO-1 bereits als eigenständig zu behandelnden Vorgang eingeordnet hat.
- Doku-Update — **erfüllt**: `harness/README.md` trägt den vollständigen `vcs`-Absatz inklusive
  aller drei MEDIUM-3-Nachträge.
- Closure-Notiz mit Steering-Loop-Lerneintrag — **nicht fällig**, korrekt unangehakt, Planner-Arbeit.

---

## Plan-vs-Code-Diff

**§3 Plan (vor Code), Zeile für Zeile gegen die zwei Commits gehalten:**

| Geplante Änderung | Eingehalten? |
|---|---|
| `.d-check.yml` — `vcs:`-Block (paths, immutable-when, exclude-sections, status-line, head-allow) | **ja**, plus über den Plan hinaus: `status-line` war im Plan nicht als eigener Schlüssel genannt, ist aber Teil der Umsetzung — sachlich richtig, denn ohne ihn ist DoD (2) nicht herstellbar (MEDIUM-2) |
| `Makefile` — Range-Lauf-Ziel | **ja** (`adr-immutable`, plus `history-range-guard` als Vorlauf-Wächter) |
| `.github/workflows/ci.yml` — Schritt mit Tiefe aus slice-123 | **ja**, Job `adr-immutable`, `fetch-depth: 0`, event-abhängige Range-Bestimmung |
| `docs/plan/adr/` — prüfen, nicht ändern | **eingehalten**: `git diff --stat 6a2e0d5f..fc92aca5 -- docs/plan/adr/` selbst gefahren → leer |
| `test/` — neue Fälle zu DoD (1)/(2) plus Mutations-Zahn | **ja, über den Plan hinaus erweitert**: ursprünglich 3 Mutations-Fälle (`277`–`279`), nach dem Review 6 (`277`, `280`–`284`) — die drei zusätzlichen (`282`/`283`/`284`) waren im Plan nicht vorgesehen, schließen aber genau die LOW-2-Lücke, die der Review fand |
| `harness/README.md` — was der Sensor prüft und nicht sieht | **ja**, deutlich ausgeweitet gegenüber dem ursprünglichen Umfang (drei offene Grenzen im Erst-Commit auf eine reduziert, zwei davon entschieden statt offen gelassen — MEDIUM-3/LOW-1) |
| `AGENTS.md` §3, `harness/conventions.md` — nicht durch diesen Slice | **eingehalten**: `git diff --stat 6a2e0d5f..fc92aca5 -- AGENTS.md harness/conventions.md harness/conventions/` selbst gefahren → leer |

**Gebaut, aber vom Plan nicht benannt:** keine Fläche außerhalb der oben genannten Dateien. Die
Fix-Runde bewegt sich vollständig innerhalb der im Plan vorgezeichneten Dateimenge; die
Erweiterungen (`status-line`-Schlüssel, drei zusätzliche Mutations-Fälle, die erweiterte
`README.md`-Passage) sind **Vertiefungen** innerhalb der geplanten Punkte, keine neuen Punkte.

**Versprochen, aber fehlend:** nichts gegenüber dem engen DoD-Text (1)–(3). Die vom Review
identifizierten Lücken MEDIUM-4 und MEDIUM-5 gehören nach eigener Einordnung des Review-Reports
dem **Vorgang** (Lifecycle-Move-Timing, Verweis-Nachzug in eingefrorenes Artefakt), nicht der
**Sache** des Slice — sie sind Beobachtungs-Register-Kandidaten für die Planner-Closure, kein
offener Code-Liefer-Punkt. Diese Einordnung wurde nicht neu geprüft (Review-Übernahme), da sie
außerhalb des DoD-Textes liegt und explizit als Planner-Sache benannt ist.

**§4 Trigger, §5 Closure-Trigger:** unverändert zutreffend — keine der drei benannten
Rückführungs-Bedingungen ist eingetreten; Closure-Trigger („DoD (1)–(3), `make gates` grün,
`make ci-lint` grün, `make mutate` ohne Befund, Review + Verifikation ohne blockierenden Befund")
ist mit einer Einschränkung erreicht: `make mutate` trägt einen (vorbestehenden, außerhalb
liegenden) Befund, kein „ohne Befund" im engen Wortlaut.

---

## Urteil

**DoD erfüllt: im Kern ja, im Wortlaut eines Standard-Punktes nein.**

Alle drei slice-eigenen DoD-Punkte (1)–(3) sind erfüllt und selbst reproduziert, nicht nur
übernommen. Alle sechs Review-Findings (HIGH-1, MEDIUM-1/2/3, LOW-1/2/3 — LOW-2 zählt als eine
Klasse mit drei neuen Fällen) sind behoben und ihre Fixes unabhängig gegengeprüft, einschließlich
der vom Implementer selbst widerrufenen und neu gemessenen MEDIUM-1-Begründung (`ids` deckt die
bare Supersede-Form innerhalb `docs/plan/adr/` nicht — bestätigt). `make gates` ist zweimal selbst
gefahren, beide Male grün. `make mutate` ist vollständig selbst gefahren (nicht nur die sechs
neuen Fälle isoliert): **269 ok, 1 Befund(e)**, und der eine Befund ist exakt `221`, derselbe
vorbestehende, außerhalb dieses Slice liegende Fall, den Review-INFO-1 bereits `slice-197`
zugeordnet hat. Kein zweiter Befund.

Der einzige echte Abweichungspunkt von der DoD ist **formal**: der Standard-Punkt „`make mutate`
ohne Befund" ist im engen Wortlaut nicht erfüllt, weil ein vorbestehender, unabhängig
dokumentierter Befund im Fall-Satz steht. Das ist keine neue Zusage-Lücke dieses Slice und ändert
an der Sache nichts — es ist eine Lücke in der DoD-Formulierung selbst, die keinen Raum für „ein
bekannter, andernorts verorteter Altbefund" vorsieht.

**Was einer Closure im Weg steht:**

1. **Formal:** Der DoD-Standard-Punkt „`make mutate` ohne Befund" ist im Wortlaut nicht erfüllt.
   Empfehlung an den Planner: bei Closure entweder den Punkt mit Verweis auf `221`/`slice-197` als
   erfüllt einordnen (die Sache trägt, der Wortlaut ist zu eng) oder — sauberer — den offenen
   Vorgang `221`/`slice-197` vorab oder parallel schließen, damit ein künftiger `make mutate`-Lauf
   wirklich `0 Befund(e)` zeigt. Beides ist Planner-Entscheidung, keine, die dieser Lauf trifft.
2. **Aus dem Review übernommen, nicht Sache des Codes:** MEDIUM-4 (Lifecycle-Move-Timing —
   Arbeits-Commit vor Anspruchs-Commit, für keinen Sensor sichtbar) und MEDIUM-5 (Verweis-Nachzug
   schrieb in ein eingefrorenes Artefakt ohne vorgeschriebene Vorab-Entscheidung, §3.11) — beide
   sind Register-Klassen, die laut Review-Summary bei Closure als weiterer Beleg eingetragen
   gehören (5×→6× bzw. 4×→5×, beide bereits `offen` über der Schwelle).
3. **Sonst nichts.** Alle Sensor-Läufe sind selbst reproduziert, keine Behauptung des
   Implementer-Commits musste ungeprüft übernommen werden.

---

## Übergabe an den Planner

- DoD-Häkchen (1)–(3) setzen — alle drei sind nach eigener Prüfung erfüllt.
- Entscheidung zum Standard-Punkt „`make mutate` ohne Befund" treffen (s. o.).
- Closure-Notiz mit Steering-Loop-Lerneintrag schreiben; Kandidat: die widerrufene und neu
  gemessene MEDIUM-1-Begründung (`ids` deckt bare Kennungen nicht innerhalb ihres eigenen
  Zieldateibaums) als eigenständige, verallgemeinerbare Beobachtung für künftige `link-policy:
  always`-Konfigurationen.
- Beobachtungs-Register: Belege für `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`
  (MEDIUM-4) und `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (MEDIUM-5) eintragen, wie im
  Review-Summary vorbereitet.
- Risiken §6 des Slice-Plans mit Ausgang versehen (nicht Gegenstand dieser Prüfung, da über die
  DoD-Punkte hinausgehend — für die Closure: Risiko „eines gemessen/eines widerlegt/eines offen"
  ist inzwischen vollständig geklärt: `head-allow` in Default-Form widerlegt, `immutable-when`
  trifft die Kopfzeile bestätigt, `paths` ist jetzt über einen eigenen Mutations-Fall geprüft, nicht
  mehr nur über eine Datei).
