

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_identifier

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.large"
  allocated_storage = 10
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = "3306"

  vpc_security_group_ids = [module.imply_service_sg.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  multi_az = false

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = var.owner
    Environment = "dev"
  }

  enabled_cloudwatch_logs_exports = ["audit", "general"]

  # DB subnet group
  subnet_ids = module.vpc.database_subnets

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"
  skip_final_snapshot = true
  # Snapshot name upon DB deletion
  # final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

data "template_file" "k8-dbservice" {
  template = file("${path.module}/templates/mysql-service.tpl")

  vars = {
    db_host = module.db.this_db_instance_address
  }
}

locals {
  dbfile = <<-EOT
    ${data.template_file.k8-dbservice.rendered}
  EOT
}

resource "local_file" "write-db-yaml" {
    filename = "${path.module}/k8-dbservice.yaml"
    content=  local.dbfile

    depends_on = [
      module.db
    ]
  }
