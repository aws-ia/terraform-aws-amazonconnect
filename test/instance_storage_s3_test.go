package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3StorageAssociationExample(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/instance-storage-config-s3",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

	// assertions
	moduleOutputs := terraform.OutputMapOfObjects(t, terraformOptions, "amazon_connect")

	// storage config
	instanceStorageConfig := moduleOutputs["instance_storage_configs"].(map[string]interface{})
	callRecordings := instanceStorageConfig["CALL_RECORDINGS"].(map[string]interface{})
	storageConfig := callRecordings["storage_config"].([]map[string]interface{})[0]
	s3Config := storageConfig["s3_config"].([]map[string]interface{})[0]

	assert.NotEmpty(t, callRecordings["association_id"])
	assert.Equal(t, "S3", storageConfig["storage_type"])
	assert.NotEmpty(t, s3Config["bucket_name"])
}
