nameOverride:
fullnameOverride:

images:
  manager:
    repository: imply/manager
    tag: "2020.12"
  agent:
    repository: imply/agent
    tag: 2020-10-07
  pullPolicy: IfNotPresent

deployments:
  manager: true
  agents: true

  zookeeper: true
  mysql: false
  minio: false

security: {}
  # To enable authentication used between the services, provide the name of a secret containing an auth token.
  # This will also enable Druid user based authentication.
  # eg. kubectl create secret generic imply-auth-token --from-literal="auth-token=$(openssl rand -base64 32)"
  # auth:
  #   secretName: imply-auth-token
  # To enable TLS, create a kubectl secret with the CA key and certificate
  # that will be used to generate certificates.
  # eg. kubectl create secret tls imply-ca --key path/to/ca.key --cert path/to/ca.crt
  # tls:
  #   secretName: imply-ca

agents:
  managerHost: "{{ include \"imply.manager.internalService.fullname\" . }}"
  clusterName: smallprod
  # Allows the termination grace period to be overwritten to comply with stringent K8s environment requirements.
  # Note that this value is set to 86400 seconds (24 hours) by default intentionally to allow running ingestion
  # tasks to finish and segment re-balancing to occur before the pod is removed. If you want to set this value
  # lower, please make sure that you manually pause or abort any ongoing data ingestion tasks and check the
  # segmentation replication state in Druid Console before changing the agent image, otherwise, it could lead
  # to partial results when querying the cluster.
  terminationGracePeriodSeconds: 86400

manager:
  labels: {node-type: manager}
  secretName: imply-secrets
  licenseKey: | # <if not using K8s Secrets, insert license key below this line, indented 4 spaces>

  metadataStore:
    type: mysql
    host: "${host}"
    port: 3306
    user: ${user}
    password: ${password}
    database: imply-manager
    # tlsCert: |
    #   -----BEGIN CERTIFICATE-----
    #   ...
    #   -----END CERTIFICATE-----
  resources:
    requests:
      cpu: 300m
      memory: 500M
    limits:
      cpu: 2
      memory: 4G
  service:
    enabled: true
    type: LoadBalancer
    port: "{{ ternary 80 443 (empty .Values.security.tls) }}"
    # nodePort:
    # loadBalancerIP:
    protocol: TCP
    annotations: {}
      # service.beta.kubernetes.io/aws-load-balancer-ssl-cert:
      # service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      # service.beta.kubernetes.io/aws-load-balancer-internal: "true"
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector:
    nodetype: masterandzk
  tolerations: []
  affinity: {}
  annotations: {}

druid:
  # By default values under druid are only used as the defaults for new clusters.
  # If you are running a single cluster and would like changes here to cause your
  # cluster to be updated with the new values, set the update field to rolling or hard.
  # Possible values:
  # disabled - changes will not be synced
  # rolling - if the change can be performed with no cluster downtime it will be applied
  # hard - cluster will be restarted to apply the change
  # Note that if another update is currently in progress the changes will not be applied.
  # Log output of the update can be found in the manager pod.
  update: disabled
  metadataStore:
    type: mysql
    host: "${host}"
    port: 3306
    user: ${user}
    password: ${password}
    # tlsCert: |
    #   -----BEGIN CERTIFICATE-----
    #   ...
    #   -----END CERTIFICATE-----
  zk:
    connectString: "{{ .Release.Name }}-zookeeper:2181"
    basePath: imply
  deepStorage:
    type: s3
    path: s3://${s3path}
    user: ${s3user}
    password: ${s3password}

  commonRuntimeProperties: []
  coordinatorRuntimeProperties:
    - jvm.config.xms=-Xms18g
    - jvm.config.xmx=-Xmx18g
  overlordRuntimeProperties:
    - jvm.config.xms=-Xms10g
    - jvm.config.xmx=-Xmx10g
  historicalRuntimeProperties:
    - jvm.config.xms=-Xms12g
    - jvm.config.xmx=-Xmx12g
    - jvm.config.dm=-XX:MaxDirectMemorySize=80g
    - druid.server.maxSize=3662000000000
    - druid.segmentCache.locations=[{"path"\:"/mnt/var/druid/segment-cache","maxSize"\:1803100000000}]
    - druid.port=8083
    - druid.server.tier=_default_tier
    - druid.processing.numThreads=15
    - druid.service=druid/historical
    - druid.processing.buffer.sizeBytes=700000000
    - druid.historical.cache.populateCache=true
    - druid.historical.cache.useCache=true
    - druid.server.http.numThreads=60
    - druid.processing.numMergeBuffers=4
    - druid.cache.sizeInBytes=1000000000
    - druid.s3.enablePathStyleAccess=true
    - druid.monitoring.monitors=["org.apache.druid.java.util.metrics.JvmMonitor","org.apache.druid.server.metrics.HistoricalMetricsMonitor"]
  historicalTier1RuntimeProperties: []
  historicalTier2RuntimeProperties: []
  historicalTier3RuntimeProperties: []
  middleManagerRuntimeProperties:
    - jvm.config.xms=-Xms256m
    - jvm.config.xmx=-Xmx256m
    - druid.indexer.task.restoreTasksOnRestart=true
    - druid.port=8091
    - druid.service=druid/middleManager
    - druid.worker.capacity=3
    - druid.indexer.runner.javaOpts=-server -Xmx5g -XX:+IgnoreUnrecognizedVMOptions -XX:MaxDirectMemorySize=10g -Duser.timezone=UTC -XX:+PrintGC -XX:+PrintGCDateStamps -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/tmp/druid-peon.hprof -Dfile.encoding=UTF-8 -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
    - druid.indexer.fork.property.druid.processing.numThreads=2
    - druid.indexer.fork.property.druid.server.http.numThreads=50
    - druid.indexer.fork.property.druid.processing.numMergeBuffers=2
    - druid.indexer.fork.property.druid.processing.buffer.sizeBytes=300000000
    - druid.indexer.task.baseTaskDir=/mnt/var/druid/task
    - druid.s3.enablePathStyleAccess=true
    - druid.indexer.task.gracefulShutdownTimeout=PT120S
    - druid.worker.capacity=6
  middleManagerTier1RuntimeProperties: []
  middleManagerTier2RuntimeProperties: []
  middleManagerTier3RuntimeProperties: []
  brokerRuntimeProperties:
    - jvm.config.xms=-Xms6g
    - jvm.config.xmx=-Xmx6g
    - jvm.config.dm=-XX:MaxDirectMemorySize=9g
    - druid.request.logging.setContextMDC=true
    - druid.sql.enable=true
    - druid.port=8082
    - druid.request.logging.type=slf4j
    - druid.processing.numThreads=1
    - druid.service=druid/broker
    - druid.sql.planner.metadataSegmentCacheEnable=true
    - druid.server.http.numThreads=40
    - druid.broker.http.numConnections=20
    - druid.processing.numMergeBuffers=12
    - druid.processing.buffer.sizeBytes=500000000
    - druid.request.logging.setMDC=true
    - druid.s3.enablePathStyleAccess=true
    - druid.monitoring.monitors=["org.apache.druid.java.util.metrics.JvmMonitor","org.apache.druid.server.metrics.QueryCountStatsMonitor"]
    - druid.sql.avatica.enable=true
    - druid.broker.http.maxQueuedBytes=50000000
    - druid.sql.http.enable=true
  routerRuntimeProperties:
    - jvm.config.xms=-Xms256m
    - jvm.config.xmx=-Xmx1024m
    - druid.port=8888
    - druid.router.tierToBrokerMap={"_default_tier"\:"druid/broker"}
    - druid.service=druid/router
    - druid.router.managementProxy.enabled=true
    - druid.router.defaultRule=_default_tier
    - druid.router.defaultBrokerServiceName=druid/broker
    - druid.router.coordinatorServiceName=druid/coordinator
    - druid.s3.enablePathStyleAccess=true
    - druid.router.http.readTimeout=PT8M
  pivotRuntimeProperties: []

master:
  replicaCount: ${master_count}
  resources:
    requests:
      cpu: 200m
      memory: 500M
    limits:
      cpu: 2
      memory: 8G
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector:
    nodetype: masterandzk
  tolerations: []
  affinity: {}
  annotations: {}
  labels: {node-type: master}

query:
  replicaCount: ${query_count}
  resources:
    requests:
      cpu: 400m
      memory: 1200M
    limits:
      cpu: 4
      memory: 16G
  service:
    type: LoadBalancer
    routerPort: 8888  # Leave blank to not expose the router through the Service
    pivotPort: 9095   # Leave blank to not expose Pivot through the Service
    # routerNodePort:
    # pivotNodePort:
    # loadBalancerIP:
    protocol: TCP
    annotations: {}
      # service.beta.kubernetes.io/aws-load-balancer-ssl-cert:
      # service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    labels: {node-type: query}
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector:
    nodetype: query
  tolerations: []
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nodetype
            operator: In
            values:
            - query
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - imply-query
        topologyKey: "kubernetes.io/hostname"
  annotations: {}
  labels: {}

dataTier1:
  replicaCount: ${data_count}
  resources:
    requests:
      cpu: 400m
      memory: 1300M
    limits:
      cpu: 16
      memory: 122G
  persistence:
    # If persistence is disabled, extraVolumes or extraVolumeClaimTemplates should
    # be configured with the names:
    # - var - for the segment cache
    # - tmp - for the temp directory
    enabled: true
  segmentCacheVolume:
    storageClassName: io1-data
    resources:
      requests:
        storage: 1500Gi
    selector: {}
  tmpVolume:
    storageClassName: io1-data
    resources:
      requests:
        storage: 300Gi
    selector: {}
  extraVolumeClaimTemplates: {}
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector: {}
  tolerations: []
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nodetype
            operator: In
            values:
            - data
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - imply-data
        topologyKey: "kubernetes.io/hostname"
  annotations: {}
  labels: {node-type: data}

dataTier2:
  replicaCount: 0
  resources:
    requests:
      cpu: 400m
      memory: 1300M
    # limits:
    #   cpu:
    #   memory:
  persistence:
    # If persistence is disabled, extraVolumes or extraVolumeClaimTemplates should
    # be configured with the names:
    # - var - for the segment cache
    # - tmp - for the temp directory
    enabled: true
  segmentCacheVolume:
    storageClassName:
    resources:
      requests:
        storage: 20Gi
    selector: {}
  tmpVolume:
    storageClassName:
    resources:
      requests:
        storage: 10Gi
    selector: {}
  extraVolumeClaimTemplates: {}
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector: {}
  tolerations: []
  affinity: {}
  annotations: {}
  labels: {}

dataTier3:
  replicaCount: 0
  resources:
    requests:
      cpu: 400m
      memory: 1300M
    # limits:
    #   cpu:
    #   memory:
  persistence:
    # If persistence is disabled, extraVolumes or extraVolumeClaimTemplates should
    # be configured with the names:
    # - var - for the segment cache
    # - tmp - for the temp directory
    enabled: true
  segmentCacheVolume:
    storageClassName:
    resources:
      requests:
        storage: 20Gi
    selector: {}
  tmpVolume:
    storageClassName:
    resources:
      requests:
        storage: 10Gi
    selector: {}
  extraVolumeClaimTemplates: {}
  extraEnv: []
  extraVolumes: []
  extraVolumeMounts: []
  nodeSelector: {}
  tolerations: []
  affinity: {}
  annotations: {}
  labels: {}

ingress: {}

# ------------------------------------------------------------------------------
# Zookeeper
# ------------------------------------------------------------------------------
zookeeper:
  replicaCount: ${master_count}
  persistence:
    enabled: true
    size: 20Gi
  env:
    ZK_HEAP_SIZE: "1024M"
    ZK_PURGE_INTERVAL: 1
    ZOO_AUTOPURGE_PURGEINTERVAL: 1
  nodeSelector:
    nodetype: masterandzk

# ------------------------------------------------------------------------------
# MySQL
# ------------------------------------------------------------------------------
mysql:
  persistence:
    enabled: true
  mysqlRootPassword: imply

# ------------------------------------------------------------------------------
# MinIO
# ------------------------------------------------------------------------------
minio:
  persistence:
    enabled: true
    size: 10Gi
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
  defaultBucket:
    enabled: true
    name: imply
  accessKey: imply
  secretKey: implypassword
  mcImage:
    repository: gcr.io/pure-episode-234323/mlalapet/minio/mc
    tag: RELEASE.2020-03-06T23-29-45Z
    pullPolicy: IfNotPresent
