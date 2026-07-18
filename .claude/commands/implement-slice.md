# Implement Harness Slice

Argument: $ARGUMENTS

This command drives the **Implementation** role (Modul 9) for one slice, inside the role
sequence Planner → Architect → Implementation → Reviewer → Verifier → Validator →
Planner-closure (Modul 8). **Role separation is context separation:** the downstream roles
(Review, Verification, Validation, closure) run in a **fresh context** (subagent / cleared
context), never the same context that wrote the code — otherwise the same blind spot
repeats. No role jumps backward without a handoff artifact (Findings · Folge-ADR · Carveout,
Modul 8).

Canonical sources (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 9
(implementation), Modul 5 (lifecycle), Modul 8 (roles), Modul 10 (review), Modul 11
(verification).

## Read context (Modul 9, Schritte 1–3)

1. Read `CLAUDE.md`.
2. Read `harness/README.md`.
3. Read `AGENTS.md`.
4. Read `harness/conventions.md`.
5. Read the Regelwerk index (`.harness/baseline/<tag>/regelwerk/README.md`) and the
   task-relevant module **on-demand** (Source Precedence, committed vendored baseline).
   Do not load the whole tree.
6. Read the slice file passed as argument.
7. Read all referenced ADRs and requirements.
8. Report: slice id · LH ids · ADR ids · affected components · gates to run.

## Enter in-progress (Modul 5 lifecycle + Modul 8 handoff)

9. Implementation receives the slice **in `in-progress/`** (Planner→Implementation handoff,
   Modul 8; `next → in-progress` = "Implementer beginnt", Modul 5). If it is still in
   `open/`, move it there first (`open → next → in-progress`). Each `git mv` is a **pure
   move, committed separately from content** (Hard Rule 3.3).
10. WIP limit = 1 per implementer (Modul 5): no parallel `in-progress/`.
11. Lifecycle back-edges (Modul 5) if the slice proves wrong: too big → `in-progress → next`
    (return to slicing); blocked → `in-progress → open` (Carveout, Modul 7). Returning is
    discipline, not failure.

## Plan before code (Modul 9, Schritt 4 — nicht optional)

12. **Measure the current state against the slice plan before editing** (`grep`/`diff`, not
    `edit`) — sibling slices age plans (deleted paths, moved lifecycle files). Reconcile
    drift first; do not blindly execute a stale plan.
13. Plan the smallest viable diff against the DoD. Plan first, then code.

## Implement and gate (Modul 9, Schritte 5–6)

14. Implement the smallest viable diff.
15. Run the narrowest relevant gate first (e.g. one test file / one gate).
16. Run `make gates`.

**Plan-defect back-edges (Modul 9):** a red sensor (15) or red gate (16) sends you back to
the **plan** (13) — refine the plan, do not re-read context. Returning to step 1 signals a
context defect. A structural mismatch (too big / blocked) is a lifecycle back-edge (11).

## Pre-completion checklist (Modul 9 Schritt 8 — the Implementation role's last act)

17. Update docs, ADR index, and README if a public contract is touched.
18. Run the pre-completion checklist: **claim** the DoD point-by-point and attach the
    **sensor evidence** (`make gates` output). This is the Implementation role's *claim*
    and the Verifier's *input* — **not** the final DoD verdict (Modul 11: "Behauptung ohne
    Bestätigung ist die häufigste Verifier-Lücke"; a DoD-violation is a Verifier-only class,
    invisible to Review and to tests). Report sensors run + residual risks.

Implementation ends here. The remaining roles run in **separate contexts** (Modul 8).

## Handoffs to downstream roles (Modul 8 → 10 → 11)

19. **→ Reviewer (Code-Review, Modul 10):** hand the diff + plan reference to an
    **independent** reviewer (`.harness/skills/reviewer.md`, fresh context — kein
    Selbst-Review). It categorizes findings (HIGH/MEDIUM/LOW/INFO) into a report under
    `docs/reviews/`, checking the diff against **Plan + ADR + Hard Rules** (not the DoD).
    Resolve HIGH/MEDIUM; a HIGH with role-conflict follows Modul 8 §Konflikt-Pfad (sequence
    with handoff artifacts, never "downgrade because the implementer disagrees").
20. **→ Verifier (Modul 11):** in a separate context, **confirm** the DoD/Spec claim and the
    plan-vs-code diff, plus ADR-conformance. This catches what tests miss and Review does not
    see (DoD-Verletzung).
21. **→ Validator (Modul 8):** if the slice delivers user-facing value, validate against real
    need ("build the right thing"). Usually n/a for internal maintenance slices — then say so
    explicitly rather than skipping silently.

## Closure — Planner role (Modul 8 + Modul 5)

22. Only once Review is conform **and** Verification confirms the DoD, the **Planner** closes:
    write the Closure-Notiz with a **Steering-Loop entry** (geschärfte Regel · neuer Sensor ·
    benannte Spec-Lücke — Modul 5: the `→ done` transition requires a learning entry, not just
    green gates), then move the slice `in-progress → done` (`git mv`, its own commit, separate
    from content — Hard Rule 3.3). A red gate reaches `done/` **only** with a documented
    Carveout (Modul 7), never as a silent red.

Do not skip gates. Do not claim completion without command output.
