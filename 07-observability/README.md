# Observability — Alerts & Dashboards

## Components

| File | Description |
|---|---|
| `alerts/prometheus-rules.yaml` | PrometheusRule CRD — 10 alerting rules (node, pod, cluster, application) |
| `dashboards/retail-store-dashboard.json` | Grafana dashboard JSON — CPU, memory, network, disk, pods |
| `runbooks/` | Incident response runbooks |

## Alerting Rules Summary

| Severity | Alert | Condition |
|---|---|---|
| 🔴 critical | NodeDown | Node unreachable > 5m |
| 🔴 critical | DiskFilling | Disk < 10% free |
| 🔴 critical | KubeAPIDown | API server unreachable |
| 🔴 critical | KubeNodeNotReady | Node NotReady > 10m |
| 🔴 critical | ServiceDown | Microservice unreachable > 3m |
| 🟡 warning | HighCPUUsage | CPU > 80% for 10m |
| 🟡 warning | HighMemoryUsage | Memory > 85% for 10m |
| 🟡 warning | PodCrashLooping | Restart in last 15m |
| 🟡 warning | PodNotReady | Non-Running pod > 10m |
| 🟡 warning | HighErrorRate | 5xx rate > 5% |

## Apply Alerting Rules

```bash
kubectl apply -f 07-observability/alerts/prometheus-rules.yaml
```

## Import Grafana Dashboard

1. Open Grafana: `http://localhost:3000` (port-forward) or via LoadBalancer
2. Go to **Dashboards > New > Import**
3. Upload `07-observability/dashboards/retail-store-dashboard.json`
4. Select Prometheus data source

## Grafana Dashboard Panels

| Panel | Metric | Type |
|---|---|---|
| Services Up | `count(up)` | Gauge |
| CPU Usage | `node_cpu_seconds_total` | Time series |
| Memory Usage | `node_memory_MemAvailable` | Time series |
| Pods per Namespace | `kube_pod_info` | Time series |
| Ready Nodes | `kube_node_status_condition` | Stat |
| Total Pod Restarts | `kube_pod_container_status_restarts_total` | Stat |
| Memory Working Set | `container_memory_working_set_bytes` | Stat |
| Total Pods | `kube_pod_info` | Stat |
| Network Traffic | `container_network_transmit_bytes_total` | Time series |
| Disk I/O | `container_fs_reads_total` | Time series |
