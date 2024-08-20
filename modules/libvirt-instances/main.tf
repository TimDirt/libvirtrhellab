terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.2"
    }
  }
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "rhel-qcow2" {
  name   = var.vm_name
  pool   = var.pool
  source = "/vm/rhel-9.4-x86_64-kvm.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${coalesce(var.template_path, path.module)}/user-data")
  #template = "#cloud-config\n${yamlencode(local.user-data)}"
}

data "template_file" "meta_data" {
  template = file("${coalesce(var.template_path, path.module)}/meta-data")

  vars = {
    hostname = var.vm_name
  }
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit-${var.vm_name}.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered
  pool      = var.pool
}

# Create the machine
resource "libvirt_domain" "domain-rhel" {
  name    = var.vm_name
  memory  = var.memory
  vcpu    = var.vcpu
  machine = "q35"

  # Default XML adds an IDE drive for the cloud init image. This XSLT file swaps it to a SATA drive
  # which is compatible with the Q35 machine type.
  # See https://github.com/dmacvicar/terraform-provider-libvirt/issues/885
  xml {
    xslt = file("${path.module}/cdrom-model.xsl")
  }

  cpu {
    mode = "host-passthrough"
  }

 
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id = var.network_id
    addresses  = var.ip_addresses
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.rhel-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  dynamic "filesystem" {
    for_each = var.filesystems
    content {
      source   = filesystem.value["source"]
      target   = filesystem.value["target"]
      readonly = filesystem.value["readonly"]
      accessmode = filesystem.value["accessmode"]
    }
  }


  connection {
    type     = "ssh"
    user     = "student"
    password = "student"
    host     = self.network_interface[0].addresses[0]
  }

  provisioner "remote-exec" {
    when   = create
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do",
        "echo -e \"\\033[1;36mWaiting for cloud-init...\"",
        "sleep 1",
      "done"
    ]
    
  }

  provisioner "remote-exec" {
    when    = destroy
    inline = [ 
      "sudo subscription-manager unregister"
    ]
  }
}
