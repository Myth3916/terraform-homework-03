locals {
  # Собираем данные о ВМ из count (web-1, web-2)
  webservers_data = [
    for instance in yandex_compute_instance.web : {
      name = instance.name
      network_interface = instance.network_interface
      fqdn = instance.fqdn
    }
  ]

  # Собираем данные о ВМ из for_each (main, replica)
  databases_data = [
    for instance in yandex_compute_instance.db : {
      name = instance.name
      network_interface = instance.network_interface
      fqdn = instance.fqdn
    }
  ]

  # Собираем данные о ВМ storage
  storage_data = [
    {
      name = yandex_compute_instance.storage.name
      network_interface = yandex_compute_instance.storage.network_interface
      fqdn = yandex_compute_instance.storage.fqdn
    }
  ]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.webservers_data
    databases  = local.databases_data
    storage    = local.storage_data
  })
  filename = "${path.module}/inventory.ini"
}