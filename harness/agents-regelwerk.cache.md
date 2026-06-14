# Betriebsregelwerk (Agenten-Kurzform) — In-Repo-Cache

> **Derivativer, gepinnter Cache.** Repo-lokale Kurzfassung der operativen
> Regeln für AI-Coding-Agenten. **Autoritativ ist die Quelle**; bei Konflikt
> gelten die kanonischen Quellen dieses Repos (Source Precedence) und das
> Upstream-Regelwerk.
>
> - **Quelle:** <https://raw.githubusercontent.com/pt9912/ai-harness-course/main/kurs/de/agents-regelwerk.md>
> - **Abgerufen/gepinnt:** 2026-06-14
> - **Zweck:** SessionStart-Injektion (Claude Code + Codex), damit die in
>   AGENTS.md §1 verlangte Vorbedingung erzwungen statt nur erinnert wird.
> - **Pflege:** manueller Refresh bei Upstream-Änderung (kein Netz-Fetch im Hook).

## 1. Source Precedence (nicht verhandelbar)

Bei Konflikt gewinnt die höherrangige Quelle; die niederrangige wird korrigiert
— nie umgekehrt. Reihenfolge: Lastenheft (Vertrag) → Spezifikation/Technik →
Architektur (Sicht) → ADRs → Roadmap/Welle → Betriebsdoku → README → AGENTS.md
→ harness/README.md. Bei Konflikt: melden und der höherrangigen Quelle folgen.

## 2. Traceability & Commit-Disziplin

Jeder Commit referenziert mindestens eine Requirement-ID, eine ADR-ID, ein
Test-/Gate-/Demo-Artefakt oder ein Doku-Update an einem öffentlichen Vertrag.
Ein konsistentes ID-Schema klammert Requirement ↔ Make-Target ↔ ADR ↔ Commit
↔ PR.

## 3. Gate-Disziplin (fail-closed)

- **Keine halluzinierten Gates:** Nur Gates behaupten, die real im
  Makefile/CI existieren und auf frischem Checkout laufen.
- **Fail-closed:** fehlende/unlesbare Eingabe → block, nie Durchwinken.
- **Inhaltsbasierter Nachweis** (nicht diff-basiert): beweist den Lauf auf
  exakt diesem Arbeitsbaum.
- **Loop-Guard:** zweite Blockade am selben Handoff-Gate nicht erneut blocken.
- **Bootstrap-aware:** nur bereits existierende Gates erzwingen.
- Gate-*Anheben* → Steering-Loop; Gate-*Lockern* (Schwellen-Senkung) → ADR.

## 4. Slice-Workflow (WIP = 1)

Ein Slice: in einem Agentenlauf erledigbar, in einer Session reviewbar, höchstens
drei DoD-Kriterien. Lifecycle open → next → in-progress → done. Übergang nach
done nur mit zwei beobachtbaren Closure-Kriterien **und** einem Lerneintrag
(Steering-Loop: Regelverstoß → Guide-/Sensor-Verbesserung). Rotes Gate nur in
done mit dokumentiertem Carveout (Trigger). WIP-Limit: ein Slice je
Implementierer in in-progress.

## 5. Referenz-Richtung (SDP — stabile Abhängigkeiten)

Normativität fließt nur aufwärts (stabil ← volatil): ADR → Requirement erlaubt,
Slice → ADR erlaubt; **Spec → ADR im Bindungstext verboten** (nur Historie-
Tabelle). Ein ADR darf die *Technik*-Spec schärfen, nie den *Vertrag*
(Lastenheft) — Vertragsänderung ist ein eigener Change-Request/Slice.

## 6. Command-/Tool-Guards (Computational Feedforward)

Der Pre-Tool-Use-Hook blockt out-of-scope-Kommandos nach Position und Kontext.
Stolperdraht gegen versehentliche Drift, **keine Sandbox** (verhindert keinen
entschlossenen Umgehungsversuch vollständig). Abdeckung transparent
dokumentieren — ein Guard, der mehr behauptet als er erzwingt, ist eine
Harness-Lüge.

## 7. Modus pro Sub-Area

Greenfield (Doc führt, Code folgt) · Brownfield (Code führt, Doc folgt; braucht
Graduation-Plan) · Hybrid. Sub-Area-Inklusion ≥ 2 von 3 Achsen
(Konventionsdichte · separierbare Inventur · Pfad-Cluster). Brownfield ohne
Graduation-Plan = getarnte Dauerausnahme.

## 8. Vier Trigger-Klassen (Bootstrap & Steering-Loop)

Sync (Pointer in einem Doc muss im anderen erscheinen) · Promotion (Eintrag
wandert aus „Nicht behauptet" in die Haupttabelle, sobald das Target existiert)
· Cross-Reference (Links nur volatil → stabil) · Acceptance (Phasenübergang per
Sign-off, z. B. ADR Proposed → Accepted wird bindend).

## 9. Reviewer/Verifier-Trennung

Review prüft Code gegen Plan + ADR (Design-Absicht). Verifikation prüft Code
gegen DoD + Spec (Anforderung). Verschiedene Agenten, verschiedene Kriterien.

## 10. Entropie-Management (laufend)

Gegen Doku-Drift, tote Constraints (Regel ohne Code-Pfad), Carveout-Wildwuchs
(abgelaufene Trigger) und Golden-Set-Overfitting. Jeder Carveout braucht einen
expliziten Auflösungs-Trigger; dauerhaft → als permanent dokumentieren.

## Hard-Rules-Zusammenfassung

1. Keine halluzinierten Gates. 2. Source Precedence ist total. 3. Spec → ADR im
Bindungstext verboten. 4. Traceability je Commit. 5. WIP = 1. 6. Closure braucht
Lerneintrag. 7. Brownfield braucht Graduation-Plan. 8. Carveout braucht Trigger.
9. Fail-closed Gates. 10. Entropie-Management ist dauerhaft.
