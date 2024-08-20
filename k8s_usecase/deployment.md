2 Different ways :

1. Adhoc way : using commands

    - To test Kubernetes installation, let’s try to deploy nginx based application and try to access it.
    $ kubectl create deployment nginx-app --image=nginx --replicas=2

    kubectl create deployment c3ops-app1 --image=kesavkummari/websitekk:3.0.0 --replicas=2
docker pull kesavkummari/websitekk:3.0.0
docker pull kesavkummari/c3opstomcat:0.3.6

    - Check the status of nginx-app deployment
    $ kubectl get deployment nginx-app

kubectl get deployment c3ops-app1

    - Expose the deployment as NodePort,
    $ kubectl expose deployment nginx-app --type=NodePort --port=80

kubectl expose deployment c3ops-app1 --type=NodePort --port=80

    - Run following commands to view service status

    $ kubectl get svc nginx-app

    kubectl get svc c3ops-app1
    
    $ kubectl describe svc nginx-app

kubectl describe svc c3ops-app1

    - Use following command to access nginx based application,

    $ curl http://<woker-node-ip-addres>:31246


2. Using Yaml file 

STEP-1 :  Create deployment.yml

File Name : deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80


STEP-2 : Create Service and Deploy:

File Name : nginx-service.yaml

---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: default
  labels:
    app: nginx
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  externalTrafficPolicy: Local
  ports:
    - name: http 
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer


$ kubectl create service nodeport nginx --tcp=80:80

$ kubectl apply -f deployment.yml

$ kubect get pods
$ kubect get svc 

STEP-3 : Update the deployment with new version

File Name : deployment-update.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16.1 # Update the version of nginx from 1.14.2 to 1.16.1
        ports:
        - containerPort: 80


$ kubectl apply -f deployment-update.yaml

STEP-4 : Scale the deployment

File Name : deployment-scale.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 4 # Update the replicas from 2 to 4
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80


$ kubectl apply -f  deployment-scale.yaml

STEP-5 : Deleting a deployment

$ kubectl delete deployment nginx-deployment



####

kubectl cluster-info

kubectl get nodes

# Get commands with basic output
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the current namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML
