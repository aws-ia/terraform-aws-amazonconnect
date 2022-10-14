package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestInstanceStorageKinesisExample(t *testing.T) {
	// sut
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/instance-storage-config-kinesis",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

	// assertions
	moduleOutputs := terraform.OutputMapOfObjects(t, terraformOptions, "amazon_connect")

	// storage config
	instanceStorageConfig := moduleOutputs["instance_storage_configs"].(map[string]interface{})
	mediaStreams := instanceStorageConfig["MEDIA_STREAMS"].(map[string]interface{})
	storageConfig := mediaStreams["storage_config"].([]map[string]interface{})[0]
	kinesisVideoStreamConfig := storageConfig["kinesis_video_stream_config"].([]map[string]interface{})[0]
	encryptionConfig := kinesisVideoStreamConfig["encryption_config"].([]map[string]interface{})[0]

	assert.NotEmpty(t, mediaStreams["association_id"])
	assert.Equal(t, "KINESIS_VIDEO_STREAM", storageConfig["storage_type"])
	assert.Equal(t, "KMS", encryptionConfig["encryption_type"])
	assert.NotEmpty(t, encryptionConfig["key_id"])
}
