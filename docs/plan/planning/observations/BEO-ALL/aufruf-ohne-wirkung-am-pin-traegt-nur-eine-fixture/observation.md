# Aufruf ohne Wirkung am Pin trägt nur eine Fixture

**Sub-Area:** `*` (gesamtes Repo)

Ein Aufruf im Emitter ist am gepinnten Stand ein No-op, weil der Text, den er umschreibt, am Pin nicht mehr
vorkommt (`NeutralizeConventionsTemplateRef` an `v6.18.1`). Der Mutations-Fall, der ihn bewachte, färbt nichts
und wird entfernt; übrig bleibt ein Test über eine Fixture im Wortlaut älterer Stände. Dass der Aufruf am Pin
**keinen realen Wächter** hat, steht in Commit-Message und ADR, nicht am Kommentar der Stelle — wer ihn entfernt
oder `COURSE_TAG` zurücksetzt, wird nur von der Fixture gewarnt.
