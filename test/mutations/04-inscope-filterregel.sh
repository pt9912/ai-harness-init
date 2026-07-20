#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Die In-Scope-Regel laesst alles durch. Das Ziel bekommt Set-Index, Makefile,
# project-readme und die skills — LH-FA-02 gebrochen (Befund 022b F-1).
set -euo pipefail
perl -0pi -e 's/func inScope\(rel string\) bool \{\n\tswitch \{/func inScope(rel string) bool {\n\tif rel != "" {\n\t\treturn true\n\t}\n\tswitch {/' internal/emit/templates.go
