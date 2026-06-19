resource "yandex_compute_instance" "web" {
  count = 2

  name               = "web-${count.index + 1}"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  
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
    nat                = false  # ← было true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  depends_on = [yandex_compute_instance.db]
}