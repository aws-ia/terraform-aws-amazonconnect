package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSimpleExample(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

	// assertions
	moduleOutputs := terraform.OutputMapOfObjects(t, terraformOptions, "amazon_connect")

	// instance
	instance := moduleOutputs["instance"].(map[string]interface{})

	assert.NotEmpty(t, instance["id"])
	assert.Equal(t, "CONNECT_MANAGED", instance["identity_management_type"])
	assert.Equal(t, true, instance["inbound_calls_enabled"])
	assert.Equal(t, true, instance["outbound_calls_enabled"])
	assert.Len(t, instance["instance_alias"], 32)
}
