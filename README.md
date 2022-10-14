<!-- BEGIN_TF_DOCS -->
# Amazon Connect Module

This module can be used to deploy an Amazon Connect instance and all supporting resources, such as Hours of Operation, queues, etc (full list below). It also supports passing in an existing instance ID, and creating supporting resources associated to it. Common deployment examples can be found in the [./examples](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples) directory.

**NOTE: At this time, due to limitations in the Amazon Connect API certain operations are not supported, such as deleting a queue. If you have created these resources with Terraform, and wish to destroy the instance, you must first remove them from the Terraform state with `terraform state rm`.**

**Specifically with queues, if you delete them via Terraform and get a duplicate name error when trying to create them again, you will need to rename or import them into the Terraform state.**

## Usage

The example below is the basic usage of this module and will create an Amazon Connect instance.

```hcl
module "amazon_connect" {
  source  = "aws-ia/amazonconnect/aws"
  version = "~> 0.0.1"

  instance_identity_management_type = "CONNECT_MANAGED"
  instance_inbound_calls_enabled    = true
  instance_outbound_calls_enabled   = true
  instance_alias                    = "my-instance-alias"
}
```

## Usage Examples

* [Simple](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/simple/main.tf)
* [Instance w/ S3 Storage Configuration](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/instance-storage-config-s3/main.tf)
* [Instance w/ Kinesis Storage Configuration](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/instance-storage-config-kinesis/main.tf)
* [Instance w/ Hours of Operations](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/hours-of-operations/main.tf)
* [Instance w/ Queue](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/queue/main.tf)
* [Instance w/ Lex Bot Association](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/lex-bot-association/main.tf)
* [Complete](https://github.com/aws-ia/terraform-aws-amazonconnect/tree/main/examples/complete/main.tf)

## Dependent Resources

Many resources within Amazon Connect have dependencies. A basic example is if you are creating a Queue that depends on an Hour of Operation. If you were not using this module, this would look straightforward:

Without module:

```hcl
resource "aws_connect_hours_of_operation" "example" { ... }

resource "aws_connect_queue" "example" {
  ...
  hours_of_operation_id = aws_connect_hours_of_operation.example.hours_of_operation_id
}
```

With this module, you can do the same thing in a single use of the module. It's possible by using the modules outputs as values for its variables/inputs. At first glance, this might not seem intuitive/possible, but since the Terraform plan phase "flattens" everything to resolve the DAG/order of operations for the deployment, it is completely fine.

With module:

```hcl
module "amazon_connect" {
  ...
  hours_of_operations = {
    example = { ... }
  }
  queues = {
    example = {
      hours_of_operation_id = try(module.amazon_connect.hours_of_operations["example"].hours_of_operation_id, null)
    }
  }
}
```

### Important note for Amazon Connect User Hierarchy Group

The one place where this is not possible is for User Hierarchy Group resources, which have a circular dependency through `parent_group_id`. In the module, resources are created through a single resource combined with a `for_each` loop. Because of this, it would create a circular reference for Terraform to have one iteration reference itself. Instead, if you need a child/parent group relationship to be created, make a second module call for the parent group.

❌ Invalid example:

```hcl
module "amazon_connect" {
  ...
  user_hierarchy_groups = {
    parent = { ... }
    child = {
      parent_group_id = module.amazon_connect.user_hierarchy_groups["parent"].hierarchy_group_id
    }
  }
}
```

✔️ Valid example:

```hcl
module "amazon_connect" {
  ...
  user_hierarchy_groups = {
    child = {
      parent_group_id = try(module.amazon_connect_parent_group.user_hierarchy_groups["parent"].hierarchy_group_id, null)
    }
  }
}

module "amazon_connect_parent_group" {
  ...
  create_instance = false
  instance_id     = module.amazon_connect.instance.id
  user_hierarchy_groups = {
    parent = {}
  }
}
```

## Creating/Exporting Contact Flow JSON

Terraform and the Amazon Connect API expect Contact Flows and Contact Flow Modules to be provided in JSON format. Currently, the easiest way to do that is to first create the Contact Flow in the Amazon Connect management console as desired, and then retrieve the JSON format using the AWS CLI or AWS Tools for PowerShell.

AWS CLI:

```shell
aws connect describe-contact-flow --instance-id <value> --contact-flow-id <value>
aws connect describe-contact-flow-module --instance-id <value> --contact-flow-id <value>
```

AWS Tools for PowerShell

```powershell
Get-CONNContactFlow -ContactFlowId <String> -InstanceId <String>
Get-CONNContactFlowModule -ContactFlowId <String> -InstanceId <String>
```

## Module Outputs

With the exception of `instance_id`, which returns the Amazon Connect Instance ID that was created or passed in, all outputs of this module return the entire resource, or collection or resources. This methodology allows the consumer of the module to access all resource attributes created, but does require some HCL if you'd like to transform it to a different structure.

As an example, if you want to get a list of the queue ARNs:

```hcl
module "amazon_connect" { ... }

locals {
  queue_arns = [ for k, v in module.amazon_connect.queues : v.arn ]
}
```

## License

Apache 2 Licensed. See [LICENSE](./LICENSE) for full details.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_connect_bot_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_bot_association) | resource |
| [aws_connect_contact_flow.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow) | resource |
| [aws_connect_contact_flow_module.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow_module) | resource |
| [aws_connect_hours_of_operation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_hours_of_operation) | resource |
| [aws_connect_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance) | resource |
| [aws_connect_instance_storage_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance_storage_config) | resource |
| [aws_connect_lambda_function_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_lambda_function_association) | resource |
| [aws_connect_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_queue) | resource |
| [aws_connect_quick_connect.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_quick_connect) | resource |
| [aws_connect_routing_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_routing_profile) | resource |
| [aws_connect_security_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_security_profile) | resource |
| [aws_connect_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user) | resource |
| [aws_connect_user_hierarchy_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_group) | resource |
| [aws_connect_user_hierarchy_structure.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_structure) | resource |
| [aws_connect_vocabulary.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_vocabulary) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bot_associations"></a> [bot\_associations](#input\_bot\_associations) | A map of Amazon Connect Lex Bot Associations.<br><br>The key of the map is the Lex Bot `name`. The value is the configuration for that Lex Bot, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_bot_association) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <lex_bot_association_name> = {<br>    name       = string<br>    lex_region = optional(string)<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_contact_flow_module_tags"></a> [contact\_flow\_module\_tags](#input\_contact\_flow\_module\_tags) | Additional tags to add to all Contact Flow Module resources. | `map(string)` | `{}` | no |
| <a name="input_contact_flow_modules"></a> [contact\_flow\_modules](#input\_contact\_flow\_modules) | A map of Amazon Connect Contact Flow Modules.<br><br>The key of the map is the Contact Flow Module `name`. The value is the configuration for that Contact Flow, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow_module) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <contact_flow_module_name> = {<br>    content      = optional(string) # one required<br>    content_hash = optional(string) # one required<br>    description  = optional(string)<br>    filename     = optional(string) # one required<br>    tags         = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_contact_flow_tags"></a> [contact\_flow\_tags](#input\_contact\_flow\_tags) | Additional tags to add to all Contact Flow resources. | `map(string)` | `{}` | no |
| <a name="input_contact_flows"></a> [contact\_flows](#input\_contact\_flows) | A map of Amazon Connect Contact Flows.<br><br>The key of the map is the Contact Flow `name`. The value is the configuration for that Contact Flow, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <contact_flow_name> = {<br>    content      = optional(string) # one required<br>    content_hash = optional(string) # one required<br>    description  = optional(string)<br>    filename     = optional(string) # one required<br>    tags         = optional(map(string))<br>    type         = optional(string)<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_create_instance"></a> [create\_instance](#input\_create\_instance) | Controls if the aws\_connect\_instance resource should be created. Defaults to true. | `bool` | `true` | no |
| <a name="input_hours_of_operations"></a> [hours\_of\_operations](#input\_hours\_of\_operations) | A map of Amazon Connect Hours of Operations.<br><br>The key of the map is the Hours of Operation `name`. The value is the configuration for that Hours of Operation, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_hours_of_operation) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <hours_of_operation_name> = {<br>    config = [<br>      {<br>        day = string<br>        end_time = {<br>          hours   = number<br>          minutes = number<br>        }<br>        start_time = {<br>          hours   = number<br>          minutes = number<br>        }<br>      }<br>    ]<br>    description = optional(string)<br>    tags        = optional(map(string))<br>    time_zone   = string<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_hours_of_operations_tags"></a> [hours\_of\_operations\_tags](#input\_hours\_of\_operations\_tags) | Additional tags to add to all Hours of Operations resources. | `map(string)` | `{}` | no |
| <a name="input_instance_alias"></a> [instance\_alias](#input\_instance\_alias) | Specifies the name of the instance. Required if instance\_directory\_id not specified. | `string` | `null` | no |
| <a name="input_instance_auto_resolve_best_voices_enabled"></a> [instance\_auto\_resolve\_best\_voices\_enabled](#input\_instance\_auto\_resolve\_best\_voices\_enabled) | Specifies whether auto resolve best voices is enabled. Defaults to true. | `bool` | `null` | no |
| <a name="input_instance_contact_flow_logs_enabled"></a> [instance\_contact\_flow\_logs\_enabled](#input\_instance\_contact\_flow\_logs\_enabled) | Specifies whether contact flow logs are enabled. Defaults to false. | `bool` | `null` | no |
| <a name="input_instance_contact_lens_enabled"></a> [instance\_contact\_lens\_enabled](#input\_instance\_contact\_lens\_enabled) | Specifies whether contact lens is enabled. Defaults to true. | `bool` | `null` | no |
| <a name="input_instance_directory_id"></a> [instance\_directory\_id](#input\_instance\_directory\_id) | The identifier for the directory if instance\_identity\_management\_type is EXISTING\_DIRECTORY. | `string` | `null` | no |
| <a name="input_instance_early_media_enabled"></a> [instance\_early\_media\_enabled](#input\_instance\_early\_media\_enabled) | Specifies whether early media for outbound calls is enabled. Defaults to true if instance\_outbound\_calls\_enabled is true. | `bool` | `null` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | If create\_instance is set to false, you may still create other resources and pass in an instance ID that was created outside this module. Ignored if create\_instance is true. | `string` | `null` | no |
| <a name="input_instance_identity_management_type"></a> [instance\_identity\_management\_type](#input\_instance\_identity\_management\_type) | Specifies the identity management type attached to the instance. Allowed values are: SAML, CONNECT\_MANAGED, EXISTING\_DIRECTORY. | `string` | `null` | no |
| <a name="input_instance_inbound_calls_enabled"></a> [instance\_inbound\_calls\_enabled](#input\_instance\_inbound\_calls\_enabled) | Specifies whether inbound calls are enabled. | `bool` | `null` | no |
| <a name="input_instance_outbound_calls_enabled"></a> [instance\_outbound\_calls\_enabled](#input\_instance\_outbound\_calls\_enabled) | Specifies whether outbound calls are enabled. | `bool` | `null` | no |
| <a name="input_instance_storage_configs"></a> [instance\_storage\_configs](#input\_instance\_storage\_configs) | A map of Amazon Connect Instance Storage Configs.<br><br>The key of the map is the Instance Storage Config `resource_type`. The value is the configuration for that Instance Storage Config, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance_storage_config#storage_config) (except `resource_type` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <instance_storage_config_resource_type> = {<br>    kinesis_firehose_config = optional({<br>      firehose_arn = string<br>    })<br>    kinesis_stream_config = optional({<br>      stream_arn = string<br>    })<br>    kinesis_video_stream_config = optional({<br>      encryption_config = {<br>        encryption_type = string<br>        key_id          = string<br>      }<br>      prefix                 = string<br>      retention_period_hours = number<br>    })<br>    s3_config = optional({<br>      bucket_name   = string<br>      bucket_prefix = string<br>      encryption_config = optional({<br>        encryption_type = string<br>        key_id          = string<br>      })<br>    })<br>    storage_type = string<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_lambda_function_associations"></a> [lambda\_function\_associations](#input\_lambda\_function\_associations) | A map of Lambda Function ARNs to associate to the Amazon Connect Instance, the key is a static/arbitrary name and value is the Lambda ARN.<br><br>Example/available options:<pre>{<br>  <lambda_function_association_name> = string<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_queue_tags"></a> [queue\_tags](#input\_queue\_tags) | Additional tags to add to all Queue resources. | `map(string)` | `{}` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | A map of Amazon Connect Queues.<br><br>The key of the map is the Queue `name`. The value is the configuration for that Queue, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_queue) (except `name` which is the key, and `instance_id which` is created or passed in).<br><br>Example/available options:<pre>{<br>  <queue_name> = {<br>    description            = optional(string)<br>    hours_of_operation_id  = string<br>    max_contacts           = optional(number)<br>    outbound_caller_config = optional({<br>      outbound_caller_id_name      = optional(string)<br>      outbound_caller_id_number_id = optional(string)<br>      outbound_flow_id             = optional(string)<br>    })<br>    quick_connect_ids = optional(list(string))<br>    status            = optional(string)<br>    tags              = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_quick_connect_tags"></a> [quick\_connect\_tags](#input\_quick\_connect\_tags) | Additional tags to add to all Quick Connect resources. | `map(string)` | `{}` | no |
| <a name="input_quick_connects"></a> [quick\_connects](#input\_quick\_connects) | A map of Amazon Connect Quick Connect.<br><br>The key of the map is the Quick Connect `name`. The value is the configuration for that Quick Connect, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_quick_connect) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <quick_connect_name> = {<br>    description          = optional(string)<br>    quick_connect_config = {<br>      quick_connect_type = string<br>      phone_config = optional({<br>        phone_number = string<br>      })<br>      queue_config = optional({<br>        contact_flow_id = string<br>        queue_id        = string<br>      })<br>      user_config  = optional({<br>        contact_flow_id = string<br>        queue_id        = string<br>      })<br>    })<br>    tags = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_routing_profile_tags"></a> [routing\_profile\_tags](#input\_routing\_profile\_tags) | Additional tags to add to all Routing Profile resources. | `map(string)` | `{}` | no |
| <a name="input_routing_profiles"></a> [routing\_profiles](#input\_routing\_profiles) | A map of Amazon Connect Routing Profile.<br><br>The key of the map is the Routing Profile `name`. The value is the configuration for that Routing Profile, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_routing_profile) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <routing_profile_name> = {<br>    default_outbound_queue_id = string<br>    description               = string<br>    media_concurrencies = [<br>      {<br>        channel     = string<br>        concurrency = number<br>      }<br>    ]<br>    queue_configs = optional([<br>      {<br>        channel  = string<br>        delay    = number<br>        priority = number<br>        queue_id = string<br>      }<br>    ])<br>    tags = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_security_profile_tags"></a> [security\_profile\_tags](#input\_security\_profile\_tags) | Additional tags to add to all Security Profile resources. | `map(string)` | `{}` | no |
| <a name="input_security_profiles"></a> [security\_profiles](#input\_security\_profiles) | A map of Amazon Connect Security Profile.<br><br>The key of the map is the Security Profile `name`. The value is the configuration for that Security Profile, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_security_profile) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <security_profile_name> = {<br>    description = optional(string)<br>    permissions = optional(list(string))<br>    tags        = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_user_hierarchy_group_tags"></a> [user\_hierarchy\_group\_tags](#input\_user\_hierarchy\_group\_tags) | Additional tags to add to all User Hierarchy Group resources. | `map(string)` | `{}` | no |
| <a name="input_user_hierarchy_groups"></a> [user\_hierarchy\_groups](#input\_user\_hierarchy\_groups) | A map of Amazon Connect User Hierarchy Groups.<br><br>The key of the map is the User Hierarchy Group `name`. The value is the configuration for that User, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_group) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <user_hierarchy_group_name> = {<br>    parent_group_id  = optional(string)<br>    tags             = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_user_hierarchy_structure"></a> [user\_hierarchy\_structure](#input\_user\_hierarchy\_structure) | A map of Amazon Connect User Hierarchy Structure, containing keys for for zero or many levels: `level_one`, `level_two`, `level_three`, `level_four`, and `level_five`. The values are the `name` for that level. See [documentation here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user_hierarchy_structure).<br><br>Example/available options:<pre>{<br>  level_one = string<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_user_tags"></a> [user\_tags](#input\_user\_tags) | Additional tags to add to all User resources. | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | A map of Amazon Connect Users.<br><br>The key of the map is the User `name`. The value is the configuration for that User, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <user_name> = {<br>    directory_user_id  = optional(string)<br>    hierarchy_group_id = optional(string)<br>    identity_info = optional({<br>      email      = optional(string)<br>      first_name = optional(string)<br>      last_name  = optional(string)<br>    })<br>    password = optional(string)<br>    phone_config = {<br>      phone_type                    = string<br>      after_contact_work_time_limit = optional(number)<br>      auto_accept                   = optional(bool)<br>      desk_phone_number             = optional(string)<br>    }<br>    routing_profile_id   = string<br>    security_profile_ids = list(string)<br>    tags                 = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_vocabularies"></a> [vocabularies](#input\_vocabularies) | A map of Amazon Connect Vocabularies.<br><br>The key of the map is the Vocabulary `name`. The value is the configuration for that Vocabulary, supporting all arguments [documented here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_vocabulary) (except `name` which is the key, and `instance_id` which is created or passed in).<br><br>Example/available options:<pre>{<br>  <vocabulary_name> = {<br>    content       = string<br>    language_code = string<br>    tags          = optional(map(string))<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_vocabulary_tags"></a> [vocabulary\_tags](#input\_vocabulary\_tags) | Additional tags to add to all Vocabulary resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bot_associations"></a> [bot\_associations](#output\_bot\_associations) | Full output attributes of aws\_connect\_bot\_association resource(s). |
| <a name="output_contact_flow_modules"></a> [contact\_flow\_modules](#output\_contact\_flow\_modules) | Full output attributes of aws\_connect\_contact\_flow\_module resource(s). |
| <a name="output_contact_flows"></a> [contact\_flows](#output\_contact\_flows) | Full output attributes of aws\_connect\_contact\_flow resource(s). |
| <a name="output_hours_of_operations"></a> [hours\_of\_operations](#output\_hours\_of\_operations) | Full output attributes of aws\_connect\_hours\_of\_operation resource(s). |
| <a name="output_instance"></a> [instance](#output\_instance) | Full output attributes of aws\_connect\_instance resource. |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Amazon Connect instance ID. If create\_instance = false, var.instance\_id is returned. |
| <a name="output_instance_storage_configs"></a> [instance\_storage\_configs](#output\_instance\_storage\_configs) | Full output attributes of aws\_connect\_instance\_storage\_config resource(s). |
| <a name="output_lambda_function_associations"></a> [lambda\_function\_associations](#output\_lambda\_function\_associations) | Full output attributes of aws\_connect\_lambda\_function\_association resource(s). |
| <a name="output_queues"></a> [queues](#output\_queues) | Full output attributes of aws\_connect\_queue resource(s). |
| <a name="output_quick_connects"></a> [quick\_connects](#output\_quick\_connects) | Full output attributes of aws\_connect\_quick\_connect resource(s). |
| <a name="output_routing_profiles"></a> [routing\_profiles](#output\_routing\_profiles) | Full output attributes of aws\_connect\_routing\_profile resource(s). |
| <a name="output_security_profiles"></a> [security\_profiles](#output\_security\_profiles) | Full output attributes of aws\_connect\_security\_profile resource(s). |
| <a name="output_user_hierarchy_groups"></a> [user\_hierarchy\_groups](#output\_user\_hierarchy\_groups) | Full output attributes of aws\_connect\_user\_hierarchy\_group resource(s). |
| <a name="output_user_hierarchy_structure"></a> [user\_hierarchy\_structure](#output\_user\_hierarchy\_structure) | Full output attributes of aws\_connect\_user\_hierarchy\_structure resource(s). |
| <a name="output_users"></a> [users](#output\_users) | Full output attributes of aws\_connect\_user resource(s). |
| <a name="output_vocabularies"></a> [vocabularies](#output\_vocabularies) | Full output attributes of aws\_connect\_vocabulary resource(s). |
<!-- END_TF_DOCS -->