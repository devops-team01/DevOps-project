# DevOps-project
DevOps group project

## Azure deployment

By default our cluster configuration can be deployed to a pre-provisioned AKS cluster.

azure-config contains the kubeconfig configuration for connecting to the test cluster we provisioned.

After adding a .ansible-vault-pass file with the vault password you can run:
`ansible-playbook ansible/deploy-azure.yml --vault-pass-file ansible/.ansible_vault_pass`

This deploys the following architecture:
1. kb indexer interface container (with role and bindings)
    with:
    - mongoDB database
    - Ingress
    - Redis task queue
2. kb-indexer-worker (will be expanded when more jobs are run)
2. Prometheus to monitor tasks and load
3. Grafana to visualize prometheus data
4. ElasticSearch to run indexing tasks on


# Frontend environment options

You are able to specify the environment options for each new job that is started.

ELASTICSEARCH_URL = 'elastic-elasticsearch.default.svc.cluster.local'
ELASTICSEARCH_USER = 'admin'

