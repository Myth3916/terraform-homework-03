resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }
  
  allow_stopping_for_update = true #Это разрешит Terraform автоматически останавливать ВМ при необходимости изменения параметров.

  name               = each.value.vm_name
  platform_id        = "standard-v3"
  zone               = var.default_zone
  
  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = false  # ← было true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }
}