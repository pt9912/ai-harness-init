# Slice slice-067: Der Docker-only-Guard verlässt den veralteten Entscheidungs-Kanal

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung) — Befund aus der Umsetzung von
[slice-060](../done/slice-060-rollen-achse.md).

**Bezug:** [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(die Hook-Verdrahtung dieses Repos),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — Docker-only, das der Guard
durchsetzt),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Satz über den
Tool-Build ohne Host-Toolchain — genau die Zusage, die der Guard bewacht).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Der `PreToolUse`-Guard antwortet in der aktuellen Form.**
`.claude/hooks/pretooluse-command-guard.sh` verweigert heute über die Felder `decision` und
`reason` auf oberster Ebene. Die vendored Werkzeug-Referenz sagt dazu: *„PreToolUse verwendete
zuvor Top-Level-Felder `decision` und `reason`, diese sind jedoch für dieses Ereignis
**veraltet**. Verwenden Sie stattdessen `hookSpecificOutput.permissionDecision` […] Die veralteten
Werte `"approve"` und `"block"` werden auf `"allow"` und `"deny"` **abgebildet**."*

**Der Guard funktioniert also nur noch über eine Abwärtskompatibilitäts-Abbildung.** Das ist kein
Schönheitsfehler: fällt die Abbildung weg, verweigert der Guard **nicht mehr** — und zwar
**lautlos**, weil ein unverstandenes Ausgabe-Objekt wie „keine Meinung" aussieht und der Tool-Call
dann durchläuft. Die Docker-only-Zusage aus
[`ADR-0003`](../../adr/0003-go-native-binaries.md) verschwände, ohne dass ein Gate rot wird.

**Herkunft:** Befund bei der Umsetzung von
[slice-060](../done/slice-060-rollen-achse.md) — dessen neuer Guard die aktuelle Form
bereits verwendet und sie am 2026-07-29 an einem echten abgelehnten Aufruf **gemessen** hat.
Dieser Slice zieht den **bestehenden** Guard nach.

## 2. Definition of Done

- [ ] **(1) Der Guard verweigert über `hookSpecificOutput.permissionDecision: "deny"`**, das
  Top-Level-`decision` ist entfernt — nicht zusätzlich geschrieben, sondern **ersetzt**, sonst
  bleibt die Abhängigkeit von der Abbildung bestehen. Der Ablehnungsgrund wandert nach
  `permissionDecisionReason`. **Belegt an einem echten Aufruf**, nicht am Skript-Trockenlauf:
  ein geblocktes Host-Toolchain-Kommando muss weiterhin abgelehnt werden, und der Text muss beim
  Aufrufer ankommen (in slice-060 gemessen: er kommt **wörtlich** an).
- [ ] **(2) Der Zahn prüft die WIRKUNG, nicht die Ausgabe.** Ein Wächter, der nur die Existenz
  eines JSON-Schlüssels prüft, hätte den heutigen Zustand für gesund gehalten — genau das ist die
  Lücke, die diesen Slice nötig macht. Der Mutations-Fall dreht die Ausgabeform auf eine
  **unverstandene** zurück (etwa ein erfundenes Entscheidungs-Feld) und muss rot werden, weil das
  verbotene Kommando dann **durchliefe** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **(3) Die Form steht in [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  samt der Regel je Ereignis.** Die Umstellung gilt **nur** für `PreToolUse`: dieselbe Referenz
  sagt, dass `PostToolUse` und `Stop` die Top-Level-Felder *„weiterhin […] als ihr aktuelles
  Format"* verwenden. Wer die Umstellung pauschal ausrollt, bricht die anderen Hooks.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/pretooluse-command-guard.sh` | update | `emit_block` schreibt die aktuelle Form; nur diese eine Funktion ist betroffen, die Scan-Logik bleibt unberührt |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die Ausgabeform je Hook-Ereignis in [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |
| `test/mutations/` | neu | der Zahn aus DoD (2) |

**Was NICHT dazugehört:** die anderen Hook-Ereignisse dieses Repos
(`PostToolUse`, `PostToolUseFailure`, `SubagentStart`, `Stop`) bleiben auf den Top-Level-Feldern —
das ist laut Referenz ihr **aktuelles** Format, keine Altlast. `SubagentStart` ist seit dem
2026-08-08 verdrahtet und war beim Schnitt dieses Slice noch nicht in der Liste.

## 4. Trigger

**`open` → `next`:** sobald [slice-060](../done/slice-060-rollen-achse.md) geschlossen ist
— er fasst dieselbe Verdrahtung an, und zwei gleichzeitige Änderungen an `.claude/settings.json`
und `.claude/hooks/` erzeugen vermeidbare Konflikte.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls sich zeigt, dass die Umstellung mehr als `emit_block` berührt.
- `in-progress` → `open`: falls die aktuelle Form in der eingesetzten Werkzeug-Version **nicht**
  greift. Dann ist die Reihenfolge falsch — erst messen, dann umstellen.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` und
`make mutate` grün; `git mv` nach `done/` (eigener Move-Commit); Closure-Notiz mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Umstellung ist selbst der Risikofall.** Wird sie falsch gebaut, verweigert der Guard
  nichts mehr — und der Ausfall ist **still**. Deshalb verlangt DoD (1) einen echten abgelehnten
  Aufruf als Beleg und DoD (2) einen Zahn auf die Wirkung.
- **Die Referenz ist vendored, aber nicht gegen die eingesetzte Version gepinnt.**
  `docs/user/claude-hooks-referenz.md` beschreibt, was die Doku sagt; ob die Abbildung in der hier
  laufenden Version noch existiert, ist nicht gemessen — und **muss** es auch nicht sein: der
  Slice entfernt gerade die Abhängigkeit davon.
- **Zeitdruck gibt es keinen, Vergessen ist die Gefahr.** Der Befund entstand als Nebenprodukt
  von [slice-060](../done/slice-060-rollen-achse.md) und lebte zunächst nur in einer
  Commit-Message. Deshalb steht er hier — auf Nutzer-Hinweis, dass genau das nicht verloren gehen
  darf.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/` und `test/`
gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
