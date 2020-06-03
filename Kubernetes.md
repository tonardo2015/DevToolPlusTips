# Tips for Kubernetes configuration and triage

### issue: connection was refused
root@control:~# kubectl get --all-namespaces services
The connection to the server localhost:8080 was refused - did you specify the right host or port?

### Solution: 
Environment variable `KUBECONFIG` must be set explicit
````
$ sudo cp /etc/kubernetes/admin.conf $HOME/
$ sudo chown $(id -u):$(id -g) $HOME/admin.conf
$ export KUBECONFIG=$HOME/admin.conf
```` 

### List Master nodes
```
$ kubectl get nodes --selector='node-role.kubernetes.io/master'
```

### List worker nodes
```
$ kubectl get nodes --selector='!node-role.kubernetes.io/master'
```
