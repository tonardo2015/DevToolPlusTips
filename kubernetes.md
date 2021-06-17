```
$ kubectl get statefulset -n unity
$ kubectl describe statefulset unity-controller -n unity
$ kubectl logs unity-controller-0 -c driver -n unity
$ kubectl get daemonset -n unity
$ kubectl describe daemonset unity-node -n unity
$ kubectl logs <node plugin pod name> -c driver -n unity
```

