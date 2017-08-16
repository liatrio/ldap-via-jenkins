job('create-ldop-instance') {
  scm {
    github('liatrio/ldop-via-jenkins', 'master')
  }
  steps {
    shell('./instantiate-demo-instance.sh')
  }
}
