# copyright: 2022, secopschef@autopsec.dev

title "Template Acceptance tests for Azure Resources"

resource_group_name = input('resource_group_name')
network_name = input('resource_group_name')
nsg_name = input('nsg_name')
vm_name = input('vm_name')
location = input('location')
restrict_to_ip_range = input('restrict_to_ip_range')
ssh_public_key_path = input('ssh_public_key_path')
vm_public_ip = input('vm_public_ip')
vm_remote_port = input('vm_remote_port')

control "azure-acceptance-tests" do                            
  impact 1.0                             
  title "Check if IAC infra is as per specification"

  describe azure_resource_group(name: resource_group_name ) do
    it { should exist }
    its('location') { should cmp location }
  end


  describe azure_network_interfaces( resource_group: resource_group_name).where { name.include?(vm_name) } do
    it { should exist }
  end

  describe azure_network_security_group(resource_group: resource_group_name, name: nsg_name) do
    it { should exist }
    it { should_not allow_rdp_from_internet }
    it { should_not allow_ssh_from_internet }
    it { should allow(source_ip_range: restrict_to_ip_range, destination_port: vm_remote_port, protocol: 'TCP', direction: 'inbound') }
  end

  describe azure_storage_accounts(resource_group: resource_group_name ) do
    it { should exist }
  end

  describe azure_virtual_machines(resource_group: resource_group_name).where { name.include?(vm_name) } do
    it { should exist }
  end

end

  
