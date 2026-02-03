# Sales Data pipeline

Project structure

```
data_kata/
  ├── src/
  │   ├── sources/
  │   │   ├── relational_db/
  │   │   ├── filesystem/
  │   │   └── webservice/
  │   ├── ingestion/
  │   ├── processing/
  │   │   ├── streaming/
  │   │   └── batch/
  │   ├── storage/
  │   │   └── migrations/
  │   └── api/
  ├── infra/
  │   ├── terraform/
  │   │   ├── modules/
  │   │   │   ├── kafka/
  │   │   │   ├── flink/
  │   │   │   ├── spark/
  │   │   │   ├── postgres/
  │   │   │   └── monitoring/
  │   │   └── environments/
  │   │       ├── local/
  │   │       └── prod/
  │   └── k8s/
  │       ├── base/
  │       └── overlays/local/
  ├── docker/
  │   ├── ingestion/
  │   ├── streaming/
  │   ├── batch/
  │   └── api/
  ├── schemas/
  ├── orchestration/
  ├── scripts/
  ├── tests/
  ├── docs/
  │   └── LOCAL_SETUP.md
  └── README.md
```

### Must have:
- 3 different data sources (relational db, file system and WS)
- Top sales per city pipeline (real time aggregation)
- top salesman in whole contry (batch aggregation)

### High-Level Architecture:
```
Data Sources → Ingestion Layer → Processing Layer → Storage Layer → API Layer
```

1. Ingestion Layer
    - Apache Kafka as the central event streaming platform

2. Processing Layer
    - Apache Flink or Kafka Streams for Real-time Aggregation
    - Apache Spark for Batch Aggregation

3. Storage Layer
    - PostgreSQL for relational storage
    - Optional: Data Lake (S3/GCS/Azure Blob) for raw data archival

4. API Layer
    - Any rest api 


### Monitoring & Observability options:

- Prometheus + Grafana for metrics
- ELK Stack (Elasticsearch, Logstash, Kibana) for logs
- Jaeger or Zipkin for distributed tracing

### Self-Hosted on Kubernetes:

- Ingestion: Kafka on K8s (Strimzi operator)
- Processing: Spark on K8s, Flink on K8s
- Storage: PostgreSQL on K8s or managed service
- API: Containerized Spring Boot
- Orchestration: Airflow on K8s

### Key Design Considerations:

- Idempotency - ensure pipelines can safely re-process data
- Schema evolution - use Schema Registry to handle changes
- Error handling - dead letter queues for failed messages
- Scalability - horizontal scaling at each layer
- Data quality - validation at ingestion and processing
- Security - encryption at rest/transit, authentication, authorization



### Data lineage

Data lineage is the documentation and visualization of data's complete journey through your systems - from its origin, through all transformations and movements, to its final destination.


#### Open Source Tools for Data Lineage

- Apache Atlas
- OpenLineage (standard for lineage metadata)
- Marquez
- Amundsen (includes lineage)