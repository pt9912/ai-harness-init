# Review-Report: slice-e2e-belegt-die-rolle-der-erfassung-im-ziel und E2E-Deklarationen — 2026-10-01

**Review-Art:** Code (gegen Plan + Lastenheft + Hard Rules)

**Gegenstand:** Commits baaeff66, 3538eb84 (Deklarationen und Rücknahme) und 25d12f62, 811888ea, b591bf8d (`rolle_im_ziel`, Deklaration LH-FA-15) in `harness/tools/full-smoke.sh` und `docs/user/e2e-abdeckung.md`. Bezug: LH-FA-15, LH-FA-12, LH-FA-13, LH-FA-16, LH-FA-17, AGENTS.md §3.6.

**Skill:** `.harness/skills/reviewer.md` · **Rolle:** Reviewer · **Datum:** 2026-10-01

## Findings

**F1 — MEDIUM (Bezug-/Abdeckungslücke, Zusage): Die Matrix behauptet für LH-FA-13, -15, -16, -17 mehr, als Stufe 3 und 6 messen.**
Beleg: `full-smoke.sh:447` und `:2267` deklarieren `LH-FA-13 … LH-FA-17`; die Kurzbeschreibungen bleiben „Das gates des Ziels laeuft vollstaendig …" bzw. „Das sprachlose Ziel faehrt ein reines Doku-Gate …" (`e2e-abdeckung.md` Z. 22, 25). Der Verifikationsbericht `2026-10-01-e2e-deklarationen-verifikation.md` stuft 13, 16, 17 dort ausdrücklich als „teilweise" ein (13: nur Pflichtfeld-Schlüssel; 16: nur Aufbewahrungs-Text und `span-clean`; 17: nur Leser-Abdeckung ohne Zähler). `make doc-trace` zeigt trotzdem „E2E ok". Die Abdeckungs-Sicht und die RTM lesen sich damit als Deckung der Anforderung; die Teilmessung steht nirgends am Ort der Aussage. Die Folge-Slice-Zusage (`slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`) trägt das **nicht**: sie ist ein künftiger Slice, kein Zustand; bis dahin ist die Aussage der RTM falsch-positiv. Gleiches gilt für LH-FA-15 (siehe F3). Abhilfe (Planner/Auftraggeber entscheidet, kein Implementer-Eingriff in Abnahme): Kurzbeschreibungen nennen die gemessenen Kriterien, oder die Deklaration für die nur teilweise gemessenen Anforderungen entfällt, bis der Folge-Slice sie trägt; mindestens muss der Folge-Slice als Adresse im Register stehen und aufgelöst sein.

**F2 — MEDIUM (§3.6, Zusicherung über einer Menge): `rolle_im_ziel` bleibt grün bei fünf fehlenden Rollen-Typen.**
Beleg: Zähl-Wächter nur für den Fall 0 (`full-smoke.sh` Zweig „keine Rollen-Typ-Datei"); LH-FA-15 und der Kommentar sagen „jeder emittierte Rollen-Typ", das Kriterium nennt **sechs** Rollen-Namen (Planner … Validator). Emittiert der Bootstrap nur einen Typ (`internal/emit/templates/agents/` trägt sechs: architect, implementer, planner, reviewer, validator, verifier), läuft die Funktion mit 1 + 2 Payloads grün. Typ-Namen sind nicht verdrahtet (gut), aber die Vollständigkeit der Menge hält die Funktion nicht; allein `rollen_typen_im_ziel` (Stufe 2/5) prüft Anwesenheit je Datei, nicht die Sechs. Bruchprobe nicht gefahren (Lesebefund, Zweig eindeutig: nur `-eq 0` fällt). Abhilfe: gegen die sechs kanonischen Namen aus `CanonicalRoles()`-Entsprechung zählen oder die Aussage auf „jeder vorhandene Typ" einschränken.

**F3 — LOW/MEDIUM (Bedeutung): Teilabdeckung von LH-FA-15 stimmt mit dem Wortlaut nur, wenn sie benannt wird.**
Gemessen: „Rolle besetzt" (Name → `agent_role`) und „leer heißt unbekannt" (`general-purpose`, fremder Typ → `"agent_role":""`). Nicht gemessen: „Rolle des Subagenten aus dem Ergebnis des Laufs (`tool_response.agentType`), nie `general-purpose` im Span", „Lesevorschrift", Haupt-Kontext. Der Plan schließt das in §1 aus (Ausschluss ehrlich); aber weder Kurzbeschreibung noch Abdeckungs-Sicht tragen es (F1). Der Funktionskommentar benennt die Grenze korrekt („Lesevorschrift und die Rolle aus tool_response.agentType messen andere Waechter") — **„andere Wächter" ist für `tool_response.agentType` unbelegt**: im E2E existiert keiner; ob ein Go-Test ihn deckt, hat dieser Lauf nicht geprüft. Der Satz behauptet damit Deckung ohne Beleg.

**F4 — MEDIUM (Prozess, DoD): Das Häkchen „Review durchgeführt" war zum Zeitpunkt des Setzens unwahr.**
Beleg: Slice-Plan DoD Z. 44 „`make gates` grün; Review; Closure-Notiz …" abgehakt; §7 Z. 76 sagt selbst „ohne Review-Bericht". Die Verifikation ersetzt den Review nicht (Modul 8: Reviewer prüft gegen Plan/ADR, Verifier gegen DoD). Dieser Bericht ist der nachgeholte Review. Damit das Häkchen wahr ist, muss der **Planner** (§3.10, nicht dieser Lauf) in einem eigenen Closure-Commit: den Wortlaut der DoD-Zeile/§7 auf „Review: `docs/reviews/2026-10-01-e2e-rolle-review.md`" nachziehen (Kennung statt Pfad, §3.11), und F1–F3 einen Ausgang geben (Folge-Slice-Zusage ersetzen/ergänzen, Register-Beleg). Die Zeile „Lücke benannt … ohne Review-Bericht" in §7 ist danach zu ersetzen, nicht zu ergänzen.

## Negativbefunde

- **Zahn (§3.6, Ursache):** Rot-Meldungen nennen `LH-FA-15`, den Typ, die erwartete Rolle und die Span-Zeile; der Verifier hat beide Seiten (Emitter verfälscht; Erwartung umgekehrt) selbst gefahren — keine Beanstandung der Ursachen-Bindung; Typ-Namen aus `name:` der emittierten Dateien, 0 Typen fällt rot, fehlendes `name:` fällt rot; offen nur F2. Ich habe die Funktion nicht erneut isoliert gefahren (Verifier-Beleg übernommen, daher keine zweite unabhängige Mutation).
- **Deklarations-Rücknahme (3538eb84):** Stufe 18 (LH-FA-13), Stufen 2/5 (LH-FA-14, LH-FA-15) entsprechen den „zu weit"-Befunden des Verifiers; keine verbleibende Beanstandung außer F1.
- **§3.2/§3.9:** keine Lint-Suppression in den Diffs, nur `bash`/`sed`/`grep`/`tr`/`cat` innerhalb des Skripts im Ziel-Verzeichnis, kein Host-Toolchain-Aufruf.
- **§3.7:** Funktionskommentar trägt Zusage, Grenze und Rang-Zeiger (Sensor genannt); keine Befund-Kennungen — bis auf den Punkt in F3 keine Beanstandung.
- **Grenze des Laufs:** Stufe selbst nicht im Docker-E2E (`make full-smoke`) gefahren, auch nicht von mir.

## Sensoren

`make gates` einmal am Ende (Ergebnis im Handoff).
