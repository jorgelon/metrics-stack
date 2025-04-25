In order to persist the settings, the kubeadm-config configmap in the kube-system namespace should also be edited to include the following:

```yaml
    controllerManager:
      extraArgs:
        bind-address: 0.0.0.0
    scheduler:
      extraArgs:
        bind-address: 0.0.0.0
```

<https://sysdig.com/blog/how-to-monitor-kube-controller-manager/>

example
<https://gist.github.com/JoooostB/65358658519402b3035c85fb25aba262>
<https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/kubernetesControlPlane-serviceMonitorKubelet.yaml>
