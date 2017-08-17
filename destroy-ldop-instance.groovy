job('destroy-ldop-instance') {
  parameters {
    stringParam("", null, "The name of the instance you want to destroy")
    }
  scm {
    github('liatrio/ldop-via-jenkins', 'master')
  }
  steps {
    shell('./remove-demo-instance.sh')
  }
}
