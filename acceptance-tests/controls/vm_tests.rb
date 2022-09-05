title "Template Acceptance tests for Virtual Machine"

vm_name = input('vm_name')
vm_remote_port = input('vm_remote_port')

control "vm-acceptance-tests" do                            
    impact 1.0                             
    title "Check if IAC VM is as per specification"

    describe command("hostname ") do
      its('stderr') { should eq '' }
      its('stdout') { should match (vm_name)}
      its('exit_status') { should eq 0 }
    end
  
    describe sshd_config do
      its('Port') { should cmp vm_remote_port }
    end

    describe command("which az") do
        its('stderr') { should eq '' }
        its('exit_status') { should eq 0 }
    end

    
end