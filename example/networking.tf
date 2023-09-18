resource "vsphere_host_port_group" "pg" {
  name                = "example"
  host_system_id      = data.vsphere_host.this.id
  virtual_switch_name = "vSwitch0"
}