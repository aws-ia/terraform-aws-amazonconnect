package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestHoopExample(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/hours-of-operations",
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

	// hoops
	hoops := moduleOutputs["hours_of_operations"].(map[string]interface{})

	assert.Contains(t, hoops, "weekday")
	assert.Contains(t, hoops, "weekend_with_lunch_break")

	weekday := hoops["weekday"].(map[string]interface{})
	weekend := hoops["weekend_with_lunch_break"].(map[string]interface{})

	assert.Equal(t, "HOOP for weekdays", weekday["description"])
	assert.Equal(t, "EST", weekday["time_zone"])
	assert.Equal(t, 5, len(weekday["config"].([]map[string]interface{})))

	assert.Equal(t, "HOOP for weekends with a lunch break", weekend["description"])
	assert.Equal(t, "EST", weekend["time_zone"])
	assert.Equal(t, 4, len(weekend["config"].([]map[string]interface{})))
}
