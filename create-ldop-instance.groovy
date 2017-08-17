job('create-ldop-instance') {
  parameters {
    stringParam("TF_VAR_ldop_username", "liatrio", "The initial admin username for LDOP's single sign on via LDAP.(\"liatrio\" unless user specified)")
    stringParam("TF_VAR_ldop_password", "example123", "The initial password for the admin user (\"example123\" unless user specified). Must be at least 8 characters in length and contain at least one number.")
  }
  scm {
    github('liatrio/ldop-via-jenkins', 'master')
  }
  steps {
    shell('./instantiate-demo-instance.sh')
  }
}
