provider "vsphere" {
  user           = var.username
  password       = "${var.password}"
  vsphere_server = "${var.vcenter}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

# Importing datasources from vSphere

# Importing Datacenter Data Source
data "vsphere_datacenter" "dc" {
  name = var.datacenter
  #for_each = toset(var.datacenter)
  #name     = each.value
}

# Importing Cluster Data Source
data "vsphere_compute_cluster" "cluster" {
  for_each      = toset(var.cluster)
  name          = each.value
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  #datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

# Importing Host Data Source
data "vsphere_host" "host" {
  for_each      = toset(var.esxihost)
  name          = each.value
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  #datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

# Importing Datastore Data Source
data "vsphere_datastore" "datastore" {
  for_each      = toset(var.datastore)
  name          = each.value
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  #datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

# Importing Network Data Source
data "vsphere_network" "net" {
  for_each      = toset(var.network)
  name          = each.value
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  #datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

# Importing Folder Data Source
data "vsphere_folder" "folder" {
  for_each = toset(var.folder)
  path     = each.value
}

# Importing Readonly Role Data Source
data "vsphere_role" "readonly" {
  label = "Read-only"
}

# Create Packer Role
resource vsphere_role "role2" {
  name            = "packer"
  role_privileges = ["Datastore.AllocateSpace", "Datastore.Browse", "Datastore.FileManagement", "Host.Config.SystemManagement", "Network.Assign", "Resource.AssignVMToPool", "VirtualMachine.Config.AddExistingDisk", "VirtualMachine.Config.AddNewDisk", "VirtualMachine.Config.AddRemoveDevice", "VirtualMachine.Config.AdvancedConfig", "VirtualMachine.Config.Annotation", "VirtualMachine.Config.CPUCount", "VirtualMachine.Config.ChangeTracking", "VirtualMachine.Config.DiskExtend", "VirtualMachine.Config.DiskLease", "VirtualMachine.Config.EditDevice", "VirtualMachine.Config.HostUSBDevice", "VirtualMachine.Config.ManagedBy", "VirtualMachine.Config.Memory", "VirtualMachine.Config.MksControl", "VirtualMachine.Config.QueryFTCompatibility", "VirtualMachine.Config.QueryUnownedFiles", "VirtualMachine.Config.RawDevice", "VirtualMachine.Config.ReloadFromPath", "VirtualMachine.Config.RemoveDisk", "VirtualMachine.Config.Rename", "VirtualMachine.Config.ResetGuestInfo", "VirtualMachine.Config.Resource", "VirtualMachine.Config.Settings", "VirtualMachine.Config.SwapPlacement", "VirtualMachine.Config.ToggleForkParent", "VirtualMachine.Config.UpgradeVirtualHardware", "VirtualMachine.GuestOperations.Execute", "VirtualMachine.GuestOperations.Modify", "VirtualMachine.GuestOperations.ModifyAliases", "VirtualMachine.GuestOperations.Query", "VirtualMachine.GuestOperations.QueryAliases", "VirtualMachine.Hbr.ConfigureReplication", "VirtualMachine.Hbr.MonitorReplication", "VirtualMachine.Hbr.ReplicaManagement", "VirtualMachine.Interact.AnswerQuestion", "VirtualMachine.Interact.Backup", "VirtualMachine.Interact.ConsoleInteract", "VirtualMachine.Interact.CreateScreenshot", "VirtualMachine.Interact.CreateSecondary", "VirtualMachine.Interact.DefragmentAllDisks", "VirtualMachine.Interact.DeviceConnection", "VirtualMachine.Interact.DisableSecondary", "VirtualMachine.Interact.DnD", "VirtualMachine.Interact.EnableSecondary", "VirtualMachine.Interact.GuestControl", "VirtualMachine.Interact.MakePrimary", "VirtualMachine.Interact.Pause", "VirtualMachine.Interact.PowerOff", "VirtualMachine.Interact.PowerOn", "VirtualMachine.Interact.PutUsbScanCodes", "VirtualMachine.Interact.Record", "VirtualMachine.Interact.Replay", "VirtualMachine.Interact.Reset", "VirtualMachine.Interact.SESparseMaintenance", "VirtualMachine.Interact.SetCDMedia", "VirtualMachine.Interact.SetFloppyMedia", "VirtualMachine.Interact.Suspend", "VirtualMachine.Interact.TerminateFaultTolerantVM", "VirtualMachine.Interact.ToolsInstall", "VirtualMachine.Interact.TurnOffFaultTolerance", "VirtualMachine.Inventory.Create", "VirtualMachine.Inventory.CreateFromExisting", "VirtualMachine.Inventory.Delete", "VirtualMachine.Inventory.Move", "VirtualMachine.Inventory.Register", "VirtualMachine.Inventory.Unregister", "VirtualMachine.Namespace.Event", "VirtualMachine.Namespace.EventNotify", "VirtualMachine.Namespace.Management", "VirtualMachine.Namespace.ModifyContent", "VirtualMachine.Namespace.Query", "VirtualMachine.Namespace.ReadContent", "VirtualMachine.Provisioning.Clone", "VirtualMachine.Provisioning.CloneTemplate", "VirtualMachine.Provisioning.CreateTemplateFromVM", "VirtualMachine.Provisioning.Customize", "VirtualMachine.Provisioning.DeployTemplate", "VirtualMachine.Provisioning.DiskRandomAccess", "VirtualMachine.Provisioning.DiskRandomRead", "VirtualMachine.Provisioning.FileRandomAccess", "VirtualMachine.Provisioning.GetVmFiles", "VirtualMachine.Provisioning.MarkAsTemplate", "VirtualMachine.Provisioning.MarkAsVM", "VirtualMachine.Provisioning.ModifyCustSpecs", "VirtualMachine.Provisioning.PromoteDisks", "VirtualMachine.Provisioning.PutVmFiles", "VirtualMachine.Provisioning.ReadCustSpecs", "VirtualMachine.State.CreateSnapshot", "VirtualMachine.State.RemoveSnapshot", "VirtualMachine.State.RenameSnapshot", "VirtualMachine.State.RevertToSnapshot"]
}

# Assign permissions to proper vCenter objects 
resource "vsphere_entity_permissions" p1 {
  entity_id = data.vsphere_datacenter.dc.id
  #for_each    = toset(var.datacenter)
  #entity_id   = data.vsphere_datacenter.dc[each.key].id
  entity_type = "Datacenter"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = false
    is_group      = false
    role_id       = data.vsphere_role.readonly.id
  }
}

resource "vsphere_entity_permissions" p2 {
  for_each    = toset(var.cluster)
  entity_id   = data.vsphere_compute_cluster.cluster[each.key].id
  entity_type = "ClusterComputeResource"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = false
    is_group      = false
    role_id       = vsphere_role.role2.id
  }
}

resource "vsphere_entity_permissions" p3 {
  for_each    = toset(var.esxihost)
  entity_id   = data.vsphere_host.host[each.key].id
  entity_type = "HostSystem"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = true
    is_group      = false
    role_id       = vsphere_role.role2.id
  }
}

resource "vsphere_entity_permissions" p4 {
  for_each    = toset(var.datastore)
  entity_id   = data.vsphere_datastore.datastore[each.key].id
  entity_type = "Datastore"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = true
    is_group      = false
    role_id       = vsphere_role.role2.id
  }
}

resource "vsphere_entity_permissions" p5 {
  for_each    = toset(var.network)
  entity_id   = data.vsphere_network.net[each.key].id
  entity_type = "Network"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = true
    is_group      = false
    role_id       = vsphere_role.role2.id
  }
}

resource "vsphere_entity_permissions" p6 {
  for_each    = toset(var.folder)
  entity_id   = data.vsphere_folder.folder[each.key].id
  entity_type = "Folder"
  permissions {
    user_or_group = "${var.vsphereaccount}"
    propagate     = true
    is_group      = false
    role_id       = vsphere_role.role2.id
  }
}
