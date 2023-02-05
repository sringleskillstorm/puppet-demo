ec2_instance { 'agent007':
    ensure => running,
    region => 'us-east-1',
    image_id => 'ami-0aa7d40eeae50c9a9',
    instance_type => 't2.nano',
    key_name => 'YOUR KEY NAME HERE',
    subnet => 'puppet-demo-public-subnet',
    security_groups => ['puppet-demo-sg'],
}
