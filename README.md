# Infra Acceptance Tests - Template 
 Template repo for Infrastrucure Acceptance tests

---

## Run Instructions
### Provision Azure cloud resources

Create a sample azure cloud virtual machine resource for testing following the steps below
```bash
# Populate following variables in override.tfvars file
subscription_id=<Your Azure subscription id>
tenant_id=<Your Azure tenant id>
client_id=<Your Azure service principal id>
client_secret=<Your Azure Service principal secret>
restrict_to_ip_range = <CIDR range to limit access to your VM>
ssh_public_key_path = <SSH public key path for linux VM>
vm_remote_port = <SSH port to listen to>

cd  provision/
terraform init
terraform plan -var-file=override.tfvars
terraform apply -auto-approve -var-file=override.tfvars
```
This shall create the following resources

Azure resource | Description 
--- | ---
Virtual Machine | Linux virtual machine with public ip. SSH keys loaded for login.
Virtual Network | Virtual network with public ip and nsg attached
Network security group | NSG which restricts traffic from restricted ip segment to restricted port on VM

### Re-use terraform vars for inspec

Terraform configuration is saved in 
- overide.tfvars (sensitive variables)
- terraform.tfvars (general variables)

These files are in HCL format and cant be used directly to initialize inspec validations. However, there exists an [utility **yj**](https://github.com/sclevine/yj) to convert HCL to YAML format
Using this we could generate validation input config for inspec directly from our infrastructure provisioning configuration
```bash
# Merge terraform config , convert to yaml and write to file
cat provision/terraform.tfvars provision/override.tfvars  | yj -cy > acceptance-tests/input.yml

```

### Run acceptance tests for cloud resources
There are two different validation controls

- azure-acceptance-tests - for testing azure resources
- vm-acceptance-tests - for testing virtual machine created 

```bash
# Export Azure Authentication ENV variables for inpsec
export AZURE_TENANT_ID=<Your Azure subscription tenant id>
export AZURE_CLIENT_SECRET=<Your Azure service principal client secret>
export AZURE_CLIENT_ID=<Your Azure service principal client id>
export AZURE_SUBSCRIPTION_ID=<Your Azure subscription id>

# Run azure-acceptance-tests 
inspec exec ./acceptance-tests --controls=azure-acceptance-tests --input-file ./acceptance-tests/input.yml -t azure://

# Run vm-acceptance-tests
inspec exec ./acceptance-tests --controls=vm-acceptance-tests --input-file ./acceptance-tests/input.yml -t ssh://azureuser@$vm_public_ip -i $ssh_id

```
## References

Utility to convert files between formats [ csv, json, HCL, yaml, toml ] [^1]

[^1]: https://github.com/sclevine/yj
