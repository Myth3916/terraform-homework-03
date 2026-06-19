# 1. Создаем 3 одинаковых диска по 1 Гб
resource "yandex_compute_disk" "storage_disk" {
  count = 3
  name  = "disk-${count.index + 1}"
  zone  = var.default_zone
  size  = 1
}

# 2. Создаем одиночную ВМ "storage"
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v3"
  zone        = var.default_zone

  allow_stopping_for_update = true # Добавили на всякий случай

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = false # Оставляем false из-за лимита
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }

  # 3. Динамическое подключение созданных дисков
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disk[*].id
    content {
      disk_id = secondary_disk.value
    }
  }
}
