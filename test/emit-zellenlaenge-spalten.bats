#!/usr/bin/env bats
# Haelt die zwei Spaltennamen der emittierten structure-Regel (internal/emit/templates/d-check.yml,
# LH-QA-01) gegen die Kopfzeilen der vendorten Vorlage harness/README.template.md: benennt ein
# Baseline-Sprung eine Spalte um, startet jedes neue Ziel mit section-column-missing rot.
# Gegenbeispiel: ein umbenannter Spaltenname in der emittierten Konfiguration (test/mutations/).

setup() {
  V="$(ls -d .harness/baseline/*/templates/harness/README.template.md)"
  [ "$(wc -l <<<"$V")" -eq 1 ]
}

@test "zellenlaenge: jede Spalte der emittierten structure-Regel ist Kopfzeile einer Tabelle der Vorlage" {
  namen="$(awk '/^structure:/{f=1;next} f && /- name: "/{gsub(/.*- name: "|".*/,""); print}' internal/emit/templates/d-check.yml)"
  [ -n "$namen" ]
  while IFS= read -r n; do
    grep -qE "^\| ([^|]+\| )*${n} \|" "$V" || { echo "Spalte [$n] steht in keiner Kopfzeile von $V"; false; }
  done <<<"$namen"
}

@test "zellenlaenge: beide Spalten stehen unter dem Selektor ## Sensors (Feedback-Gates) der Vorlage" {
  [ "$(grep -c '^## Sensors (Feedback-Gates)$' "$V")" -eq 1 ]
  s="$(awk '/^## Sensors \(Feedback-Gates\)$/{f=1;next} /^## /{f=0} f' "$V")"
  grep -qE '^\| Target \| Vertrag \|' <<<"$s"
  grep -qE '^\| Target \| Tut was \|' <<<"$s"
}
