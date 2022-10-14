package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLexBotAssociationExample(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/lex-bot-association",
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

	// bot associations
	botAssociations := moduleOutputs["bot_associations"].(map[string]interface{})
	botAssociationexample := botAssociations["example"].(map[string]interface{})
	lexBot := botAssociationexample["lex_bot"].([]map[string]interface{})[0]

	assert.NotEmpty(t, botAssociationexample["id"])
	assert.Equal(t, instance["id"], botAssociationexample["instance_id"])
	assert.Equal(t, "example", lexBot["name"])
}
