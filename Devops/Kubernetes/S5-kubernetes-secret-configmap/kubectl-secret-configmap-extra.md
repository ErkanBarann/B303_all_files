### Creating a Secret Using kubectl

- Secrets can contain user credentials required by Pods to access a database. For example, a database connection string consists of a username and password. You can store the username in a file ./username.txt and the password in a file ./password.txt on your local machine.

```bash
# Create files needed for the rest of the example.
echo -n 'admin' > ./username.txt
echo -n '1f2d1e2e67df' > ./password.txt
```

- The kubectl create secret command packages these files into a Secret and creates the object on the API server. The name of a Secret object must be a valid DNS subdomain name. Show types of secrets with opening : (Kubetnetes Secret Types)[https://kubernetes.io/docs/concepts/configuration/secret/]

```bash
kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
```

- The output is similar to:

```bash
secret "db-user-pass" created
```

- Default key name is the filename. You may optionally set the key name using `[--from-file=[key=]source]`.

```bash
kubectl create secret generic db-user-pass-key --from-file=username=./username.txt --from-file=password=./password.txt
```

>Note:
>Special characters such as `$`, `\`, `*`, `=`, and `!` will be interpreted by your shell and require escaping. In most shells, the easiest way to escape the password is to surround it with single quotes (`'`). For example, if your actual password is S!B\*d$zDsb=, you should execute the command this way:
>
>```bash
>kubectl create secret generic dev-db-secret --from-literal=username=devuser --from-literal=password='S!B\*d$zDsb='
>```
>You do not need to escape special characters in passwords from files (--from-file).

- You can check that the secret was created:

```bash
kubectl get secrets
```

- The output is similar to:

```bash
NAME                  TYPE                                  DATA      AGE
db-user-pass          Opaque                                2         51s
```

You can view a description of the secret:

```bash
kubectl describe secrets/db-user-pass
```

Note: The commands kubectl get and kubectl describe avoid showing the contents of a secret by default. This is to protect the secret from being exposed accidentally to an onlooker, or from being stored in a terminal log.

The output is similar to:
```bash
Name:            db-user-pass
Namespace:       default
Labels:          <none>
Annotations:     <none>

Type:            Opaque

Data
====
password.txt:    12 bytes
username.txt:    5 bytes
```

## Create and use ConfigMaps with `kubectl create configmap` command

There are three ways to create ConfigMaps using the `kubectl create configmap` command. Here are the options.

1. Use the contents of an entire directory with `kubectl create configmap my-config --from-file=./my/dir/path/`
   
2. Use the contents of a file or specific set of files with `kubectl create configmap my-config --from-file=./my/file.txt`
   
3. Use literal key-value pairs defined on the command line with `kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2`

### Literal key-value pairs

We will start with the third option. We have just one parameter. Greet with "Halo" in Spanish.

```bash
kubectl create configmap demo-config --from-literal=greeting=Hola
```

- Explain the important parts in `ConfigMap` file contents.
```bash
kubectl get configmap/demo-config -o yaml
```

```yaml

apiVersion: v1
data:
  greeting: Halo
kind: ConfigMap
metadata:
  creationTimestamp: "2021-10-06T13:01:20Z"
  name: demo-config
  namespace: default
  resourceVersion: "39879"
  uid: 9673e114-3bbe-43e5-9e88-b3478ccc0794
```

- Delete the ConfigMap.

```bash
kubectl get cm
NAME          DATA   AGE
demo-config   1      15m

kubectl delete cm demo-config 
```

### From a config file

```bash
echo "greeting: Hei" > config
```

Note that, the comman notation used in key-value pairs is to use `key= value` notation, but this is not an obligatory. The notation actualy depends on the applicaton implementation that will parse and use these files.

- Let's create our configmap from `config` file.

```bash
kubectl create configmap demo-config --from-file=./config
```

- Check the content of the `configmap/demo-config`.

```json
kubectl get  configmap/demo-config -o json
{
    "apiVersion": "v1",
    "data": {
        "config": "greeting: Hei\n"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2021-10-06T13:04:14Z",
        "name": "demo-config",
        "namespace": "default",
        "resourceVersion": "40173",
        "uid": "8bbeed1d-d516-4db8-b50e-c0fdb7f4f0c2"
    }
}
```

- Delete the ConfigMap.

```bash
kubectl get cm
NAME          DATA   AGE
demo-config   1      15m

kubectl delete cm demo-config 
```
