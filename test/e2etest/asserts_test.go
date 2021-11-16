package e2etest

import (
	"testing"
)

func TestIngressAssert(t *testing.T) {
	t.Skip("Only for internal testing")
	assertIngressAccess(t, "bamboo", "abrokes-tf-test", "deplops.com")
}
