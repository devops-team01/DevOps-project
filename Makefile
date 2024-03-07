CONFIG_FILES := ./dev_deployment/flask-deployment.yml ./dev_deployment/mongodb-deployment.yml ./dev_deployment/job-creator-role.yaml ./dev_deployment/job-creator-role-binding.yaml ./dev_deployment/redis_deployment.yml ./dev_deployment/rq-worker-deployment.yml
NAMESPACE := default

PROM_CONFIG := ./dev_deployment/prometheus-deployment.yml

KB-INDEXER := kb-indexer:latest
TIMESTAMP := $(shell date +%Y%m%d%H%M%S)

k8: start-minikube \
	apply-configs \
	latest-backend-image \
	latest-kb-indexer-image\
	start-monitoring\


	minikube service python-flask-server --url

# # Load Docker images into Minikube
# load-images:
# 	@echo "Loading images into Minikube..."
# 	minikube image load python-flask-server:latest
# 	minikube image load kb-indexer:latest


# Start Minikube and configure Docker to use Minikube's Docker daemon
start-minikube:
	@echo "Checking if Minikube is already running..."
	@if minikube status | grep -q "Running"; then \
		echo "Minikube is already running."; \
	else \
		echo "Starting Minikube..."; \
		minikube config set memory 6000; \
		minikube config set cpus 4; \
		minikube start --driver=docker; \
		echo "Configuring local Docker client to use Minikube's Docker daemon..."; \
	fi
	eval $$(minikube -p minikube docker-env);

# Build the latest backend image with a timestamp tag
latest-backend-image:
	@echo "Building latest backend image with timestamp..."
	eval $$(minikube -p minikube docker-env) && \
	docker build -t python-flask-server:$(TIMESTAMP) ./backend/python-flask-server-generated && \
	kubectl set image deployment/python-flask-server python-flask-server=python-flask-server:$(TIMESTAMP) --namespace $(NAMESPACE)
	kubectl set image deployment/rq-worker rq-worker=python-flask-server:$(TIMESTAMP) --namespace $(NAMESPACE)

# Check if the kb-indexer Docker image exists, and build it if not
latest-kb-indexer-image:
	if [ -z "$$(eval $$(minikube -p minikube docker-env) && docker images -q $(KB-INDEXER) 2> /dev/null)" ]; then \
		echo "kb-indexer image not found, building..."; \
	eval $$(minikube -p minikube docker-env) && cd ./kb-indexer && docker build -f docker/Dockerfile -t $(KB-INDEXER) .; \
	else \
		echo "kb-indexer image already exists."; \
	fi

apply-configs:
	@echo "Applying Kubernetes configurations..."
	$(foreach file,$(CONFIG_FILES),kubectl apply -f $(file) --namespace $(NAMESPACE);)

# Deploy prometheus and grafana under namespace "monitoring"
start-monitoring:
	kubectl delete namespace monitoring --ignore-not-found=true
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	kubectl create namespace monitoring
	helm install -f $(PROM_CONFIG) prometheus prometheus-community/kube-prometheus-stack --namespace monitoring

# Setup your environment (placeholder for any setup commands you need)
setup: 
	python3 setup.py

tree: 
	tree -I 'indexers|__pycache__|'kb-indexer''

