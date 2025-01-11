module "VPC" {
  source = "./modules/VPC"
  tags = var.tags
  vpc_cidr = var.vpc_cidr
  pub_sub_1a_cidr = var.pub_sub_1a_cidr
  pub_sub_2b_cidr = var.pub_sub_2b_cidr
  pri_sub_3a_cidr = var.pri_sub_3a_cidr
  pri_sub_4b_cidr = var.pri_sub_4b_cidr
  pri_sub_5a_cidr = var.pri_sub_5a_cidr
  pri_sub_6b_cidr = var.pri_sub_6b_cidr
}

module "nat" {
  source = "./modules/nat"
  igw_id = module.VPC.igw_id
  vpc_id = module.VPC.vpc_id
  pub_sub_1a_id = module.VPC.pub_sub_1a_id
  pub_sub_2b_id = module.VPC.pub_sub_2b_id
  pri_sub_3a_id = module.VPC.pri_sub_3a_id
  pri_sub_4b_id = module.VPC.pri_sub_4b_id
  pri_sub_5a_id = module.VPC.pri_sub_5a_id
  pri_sub_6b_id = module.VPC.pri_sub_6b_id 
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.VPC.vpc_id
}

#creating key for instances
module "key" {
  source = "../modules/key"
}

#creating application load balancer
module "alb" {
  source = "./modules/alb"
  project_name = module.vpc.tags
  alb_sg_id = module.security_group.alb_sg_id
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  vpc_id = module.vpc.vpc_id
}
  
module "asg" {
  source = "./modules/asg"
  project_name = module.vpc.tags
  key_name = module.key.key_name
  client_sg_id = module.security_group.client_sg_id
  pri_sub_3a_id = module.VPC.pri_sub_3a_id
  pri_sub_4b_id = module.VPC.pri_sub_4b_id
  tg_arn = module.alb.tg_arn
}

module "cloudfront" {
  source = "./modules/cloudfront"
  certificate_domain_name = var.certificate_domain_name
  alb_domain_name = module.alb.alb_dns_name
  additional_domain_name = var.additional_domain_name
  project_name = module.vpc.tags
}

module "rds" {
  source = "./modules/rds"
  db_sg_id = module.security-group.db_sg_id 
  pri_sub_5a_id = module.vpc.pri_sub_5a_id
  pri_sub_6b_id = module.vpc.pri_sub_6b_id
  db_username = var.db_username
  db_password = var.db_password
}

module "route53" {
  source = "./modules/route53"
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}