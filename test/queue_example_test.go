/*
	NOTE: This example is currently not testable. The Connect API currently does not support deleting a Queue.
				For this reason, Terraform Destroy will always fail. When resolved, these tests can be written/run.
				The Queue example has been manually tested successfully.
*/

package test

// import (
// 	"testing"

// 	"github.com/gruntwork-io/terratest/modules/terraform"
// )

// func TestQueueExample(t *testing.T) {
// 	// sut
// 	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
// 		TerraformDir: "../examples/queue",
// 	})

// 	defer terraform.Destroy(t, terraformOptions)
// 	terraform.InitAndApply(t, terraformOptions)
// 	terraform.ApplyAndIdempotent(t, terraformOptions)

// 	// assertions
// 	moduleOutputs := terraform.OutputMapOfObjects(t, terraformOptions, "amazon_connect")
// }
