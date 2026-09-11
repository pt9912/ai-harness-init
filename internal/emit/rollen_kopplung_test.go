package emit_test

import (
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/span"
)

// TestRollenAchseFolgtDerEinenQuelle haelt die Kopplung zwischen der Quelle der
// emittierten Rollen-Typen (emit.CanonicalRoles, die ihrerseits span.CanonicalRoles
// liest) und der Abbildung des Traegers (span.RoleFromAgentType) gegen genau EINEN
// Bestand — beide Richtungen, sonst prueft er eine Teilmenge:
//
//  1. jeder Name der Quelle normalisiert ueber die Abbildung auf sich selbst (ein
//     nicht-leeres Rollen-Feld), UND jeder Name der Quelle hat einen eingebetteten
//     Rollen-Typ (emit.AgentFile), also einen wirklichen Bestand hinter dem Namen;
//  2. ein Name AUSSERHALB der Quelle normalisiert auf ein LEERES Rollen-Feld.
//
// Die Laengen-Pruefe ist absichtlich Teil DIESES Waechters (nicht nur von
// TestAgents_KanonischeRollenLiegenImZiel): kuerzt eine Mutation die Quelle um eine
// Rolle, faellt dieser Waechter ueber der falschen Laenge, BEVOR die Schleife ueber der
// (dann schon verkuerzten) Liste still bestehen koennte. Kuerzt eine Mutation
// stattdessen nur die ABBILDUNG — die Quelle bleibt bei sechs, aber ein einzelner Name
// normalisiert nicht mehr auf sich selbst —, faellt derselbe Waechter in der Schleife.
func TestRollenAchseFolgtDerEinenQuelle(t *testing.T) {
	roles := emit.CanonicalRoles()
	if len(roles) != 6 {
		t.Fatalf("emit.CanonicalRoles liefert %d Rollen, die Rollen-Sequenz aus Modul 8 hat 6: %v", len(roles), roles)
	}
	for _, role := range roles {
		if got := span.RoleFromAgentType(role); got != role {
			t.Errorf("Rolle %q normalisiert ueber die Abbildung des Traegers auf %q, nicht auf sich selbst — Quelle und Abbildung weichen voneinander ab", role, got)
		}
		if emit.AgentFile(".claude/agents/"+role+".md") == nil {
			t.Errorf("die Quelle fuehrt %q, aber AgentFile liefert dafuer keinen eingebetteten Typ-Text", role)
		}
	}
	// Negativ-Richtung: ein Name, den die Quelle NICHT fuehrt, ergibt ein leeres Feld —
	// ohne diese Haelfte waere der Waechter unter einer Quelle wahr, die "jeden Typ"
	// akzeptiert.
	if got := span.RoleFromAgentType("general-purpose"); got != "" {
		t.Errorf("ein Agenten-Typ ausserhalb der Quelle ergibt %q, muss leer sein", got)
	}
}
