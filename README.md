# K8s Infra

- One-password
- Cert-manager
- External-dns
- Nginx-ingress
- Atlas-operator
- Redis
- Prometheus
- Alert-manager
- Loki
- Tempo

## Get kubeconfig credentials

This will retrieve the credentials and append them you your kubeconfig

```sh
az aks get-credentials --resource-group prop_rg --name prop_aks
```

## Debug command

```sh
kubectl run -it --rm --image=brenwell/busybox busybox -n prop -- sh
```

## Atlas operator

This keeps the db migrated

## Uploading to blob storage

```sh
az storage blob upload \
  --container-name examplecontainer \
  --file /path/to/large.csv \
  --name large.csv \
  --account-name $(terraform output -raw storage_account_name) \
  --account-key $(terraform output -raw primary_access_key)
```

## Prometheus

Accessing Prometheus

```sh
kubectl port-forward svc/kube-prometheus-kube-prome-prometheus -n monitoring 9090
```

Then visit http://localhost:9090

## Grafana

Accessing Grafana

```sh
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 9999:80
```

Then visit http://localhost:9999. Username is `prop`. The password can be found from the secret.

```sh
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ;
echo
```

## Postgres-Exporter

The Postgres-Exporter needs a db user with read-only permissions

```sql
GRANT CONNECT ON DATABASE "prop-db" TO grafana_ro;
GRANT USAGE ON SCHEMA public TO grafana_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO grafana_ro;
GRANT pg_monitor TO grafana_ro;
```
