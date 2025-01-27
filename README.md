# Azure Infra

- Azure Kubernetes Service
- Azure Container Registry
- Azure Blob Storage
- Azure Service Principals

It will also setup

- One-password
- Cert-manager
- External-dns
- Nginx-ingress
- Atlas-operator
- Redis
- Prometheus
- Loki
- Tempo

# Terraform Authentication

You need this role for Terraform to authenticate with Azure

```sh
az ad sp create-for-rbac \
--name "tf" \
--role="Contributor" \
--scopes="/subscriptions/c7d61291-28b2-423a-a1c7-5ce8d6a51fec"

az role assignment create \
--assignee "<service-principal-id>" \ # client_id
--role "User Access Administrator" \
--scope /subscriptions/c7d61291-28b2-423a-a1c7-5ce8d6a51fec

# https://acloudguy.com/2021/08/17/azure-ad-determine-app-roles-and-scope-permissions/
az ad app permission add \
--id <service-principal-id> \
--api "00000003-0000-0000-c000-000000000000" \ # Microsoft Graph
--api-permissions "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9=Role=Role" # Application.ReadWrite.All
```

After you need the Global Administrator to

- Navigate to Azure Active Directory > App registrations.
- Find and select your app "tf".
- Under API permissions, click on Grant admin consent.

# Get kubeconfig credentials

This will retrieve the credentials and append them you your kubeconfig

```sh
az aks get-credentials --resource-group prop_rg --name prop_aks
```

# Debug command

```sh
kubectl run -it --rm --image=brenwell/busybox busybox -n prop -- sh
```

# Atlas operator

This keeps the db migrated

# Uploading to blob storage

```sh
az storage blob upload \
  --container-name examplecontainer \
  --file /path/to/large.csv \
  --name large.csv \
  --account-name $(terraform output -raw storage_account_name) \
  --account-key $(terraform output -raw primary_access_key)
```

# Prometheus

Accessing Prometheus

```sh
kubectl port-forward svc/kube-prometheus-kube-prome-prometheus -n monitoring 9090
```

Then visit http://localhost:9090

# Grafana

Accessing Grafana

```sh
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 9999:80
```

Then visit http://localhost:9999. Username is `prop`. The password can be found from the secret.

```sh
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ;
echo
```

###

The Postgres-Exporter needs a db user with read-only permissions

```sql
GRANT CONNECT ON DATABASE "prop-db" TO grafana_ro;
GRANT USAGE ON SCHEMA public TO grafana_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO grafana_ro;
GRANT pg_monitor TO grafana_ro;
```

# Database

In order to access the database from your computer you need to allow your IP address through the firewall. This can be done via the interface or with the following script

```sh
# Retrieve the current public IP address
MY_IP=$(curl -s https://ipinfo.io/ip)

# Add the IP address to the PostgreSQL Flexible Server firewall rules
az postgres flexible-server firewall-rule create \
    --resource-group prop_rg \
    --name prop-server \
    --rule-name BrendonClient \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP
```
