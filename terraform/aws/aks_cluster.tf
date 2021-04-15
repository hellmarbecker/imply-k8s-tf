data "aws_eks_cluster" "cluster" {
  name = module.imply-eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name  = module.imply-eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false

}

module "imply-eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster-name
  cluster_version = "1.19"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_create_security_group = false
  cluster_security_group_id = module.imply_service_sg.this_security_group_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 200

  }

  node_groups = {
    masterandzk = {
      desired_capacity =var.master_count
      max_capacity     = var.master_count
      min_capacity     = var.master_count
      #root_volume_type = "io1"
      #root_volume_size  = 100
      #root_iops = 64000
      instance_types = ["m4.xlarge"]
      capacity_type  = "SPOT"


      additional_tags = {
          nodetype = "masterandzk"
      }
      },
      query = {
        desired_capacity = var.master_count
        max_capacity     = var.master_count
        min_capacity     = var.master_count
        #root_volume_type = "io1"
        #root_iops = 64000
        instance_types = ["c5.xlarge"]
        capacity_type  = "SPOT"


        additional_tags = {
          nodetype = "query"
        }
        },
        data = {
          desired_capacity = 2
          max_capacity     = 3
          min_capacity     = 2

          block_device_mappings = {
            device_name = "io1-data"
          ebs = {
            volume_size           = 1800
            volume_type           = "io1"
            delete_on_termination = true
           encrypted             = false
            }
            }
          #root_volume_type = "io1"
          #root_volume_size  = 1800
          #root_iops = 64000
          instance_types = ["i3.8xlarge"]



          additional_tags = {
              nodetype = "data"
          }
          }
    }
  }



data "template_file" "launch-template-imply" {
  template = file("${path.module}/templates/imply-aws.yaml.tpl")

  vars = {
    host = module.db.this_db_instance_address
    user = var.db_username
    password = var.db_password
    s3path = var.bucket_name
    s3user = var.aws_access_key
    s3password = var.aws_secret_key
    master_count = var.master_count
    query_count = var.query_count
    data_count = var.data_count

    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "null_resource" "kube-apply" {

  provisioner "local-exec" {
    command = <<EOF
aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster-name}
EOF
}
  depends_on = [
    module.imply-eks-cluster.kubeconfig
    ]
}

locals {
  valuesfile = <<-EOT
    ${data.template_file.launch-template-imply.rendered}
  EOT
}

resource "local_file" "write-yaml" {
    filename = "${path.module}/values_gen.yaml"
    content=  local.valuesfile

    depends_on = [
      module.imply-eks-cluster.kubeconfig
    ]
  }
