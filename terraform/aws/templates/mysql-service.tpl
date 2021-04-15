# mysql-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mysql-service
  name: mysql-service
spec:
  externalName: ${db_host}
  selector:
    app: mysql-service
  type: ExternalName
status:
  loadBalancer: {}
