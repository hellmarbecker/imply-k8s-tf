

output "values_yaml" {
  value = data.template_file.launch-template-imply.rendered
}


output "dbservice_yaml" {
  value = data.template_file.k8-dbservice.rendered
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.imply-eks-cluster.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.imply-eks-cluster.config_map_aws_auth
}
