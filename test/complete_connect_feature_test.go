// The Go test file which tests all the Amazon connect features not covered in the examples

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCompleteConnectAdditionalFeature(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "connect_additional_feature_test/",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

	// assertions
	moduleOutputs := terraform.OutputMapOfObjects(t, terraformOptions, "amazon_connect")

	// contact flow module config
	contactflowmoduleconfig := moduleOutputs["contact_flow_modules"].(map[string]interface{})
	contactflowmodulename := contactflowmoduleconfig["inbound"].(map[string]interface{})

	assert.NotEmpty(t, contactflowmodulename["id"])
	assert.NotEmpty(t, contactflowmodulename["arn"])
	assert.Equal(t, "inbound", contactflowmodulename["name"])

	// Contact flow config
	contactflowconfig := moduleOutputs["contact_flows"].(map[string]interface{})
	contactflowvalue := contactflowconfig["inbound"].(map[string]interface{})

	assert.Equal(t, "CONTACT_FLOW", contactflowvalue["type"])
	assert.Equal(t, "inbound", contactflowvalue["name"])

	// Lambda association config
	lambdaassociation := moduleOutputs["lambda_function_associations"].(map[string]interface{})
	lambdaassociationname := lambdaassociation["example"].(map[string]interface{})

	assert.NotEmpty(t, lambdaassociationname["function_arn"])
	assert.NotEmpty(t, lambdaassociationname["id"])

	// Quick Connect config
	quickconnectconfig := moduleOutputs["quick_connects"].(map[string]interface{})
	quickconnectconfigid := quickconnectconfig["phone_number"].(map[string]interface{})

	assert.NotEmpty(t, quickconnectconfigid["quick_connect_id"])

	// Routing Profile config
	routingprofileconfig := moduleOutputs["routing_profiles"].(map[string]interface{})
	routingprofileconfigid := routingprofileconfig["sales"].(map[string]interface{})

	assert.Equal(t, "sales", routingprofileconfigid["name"])
	assert.NotEmpty(t, routingprofileconfigid["routing_profile_id"])

}
