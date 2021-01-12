resource "null_resource" "setup-cluster" {
  depends_on = [
    azurerm_kubernetes_cluster.imply
  ]
  triggers = {
    id = azurerm_kubernetes_cluster.imply.id
    // Re-run script on deployment script changes
    script = sha1(file("00_setup_AKS.sh"))
  }

  provisioner "local-exec" {
    command = "./00_setup_AKS.sh ${var.location}  ${var.cluster_name} ${var.resource_group_name}"
  }
}

resource "null_resource" "setup-messaging" {
  depends_on = [
    null_resource.setup-cluster
  ]

  provisioner "local-exec" {
    command = "../01_installImply.sh ${var.location} ${var.cprovider}"
  }
}
