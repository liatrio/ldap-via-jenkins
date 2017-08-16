job('destroy-ldop-instance') {
  scm {
    github('liatrio/ldop-via-jenkins', 'master')
  }
  steps {
    shell('./remove-demo-instance.sh')
  }
}
