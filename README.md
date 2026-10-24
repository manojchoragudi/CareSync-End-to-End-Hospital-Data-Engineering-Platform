# 🏥 CareSync — End-to-End Hospital Data Engineering Platform

## Overview

**CareSync** is an end-to-end hospital data engineering solution built using **Azure Data Factory, Azure Data Lake Storage Gen2, Azure Databricks, PySpark, PostgreSQL, Azure SQL Database, and Azure Logic Apps**.

The project implements a metadata-driven ETL/ELT architecture to ingest hospital data from multiple source systems, process it through **Bronze, Silver, and Gold layers**, maintain audit and watermark information, and generate automated pipeline execution notifications.

The solution supports both **initial/full loads and incremental loads**, making the pipeline scalable and reusable across multiple hospital datasets and source systems.

---

## Features

* 🔄 Metadata-driven ETL/ELT pipelines
* 📥 Ingestion from multiple source systems
* 🐘 PostgreSQL source integration
* 📄 ADLS Gen2 CSV source integration
* 🥉 Bronze layer for raw/landing data
* 🥈 Silver layer for cleansed and transformed data
* 🥇 Gold layer for analytics-ready datasets
* ⚡ Incremental processing using watermark-based loading
* 🔁 Dynamic table processing using ADF Lookup + ForEach
* 🚀 Parallel ingestion of multiple tables
* 📝 Centralized pipeline audit logging
* 📊 Record count tracking
* 🔔 Automated success/failure email notifications
* 🔐 Azure Key Vault integration
* 📓 Databricks notebooks for transformation
* 📋 Source-to-target mapping documentation
* 🗓️ Calendar/date dimension preparation
* 🧩 Parameterized and reusable ADF pipelines

---

## Architecture

```text
                    ┌─────────────────────┐
                    │   Source Systems    │
                    ├─────────────────────┤
                    │ PostgreSQL          │
                    │ ADLS CSV Files      │
                    └──────────┬──────────┘
                               │
                               ▼
                 ┌──────────────────────────┐
                 │    Azure Data Factory    │
                 │   Metadata-Driven ETL    │
                 └────────────┬─────────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │        BRONZE            │
                 │  Raw / Landing Data      │
                 │      ADLS Gen2           │
                 └────────────┬─────────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │      AZURE DATABRICKS    │
                 │       PySpark / SQL      │
                 └────────────┬─────────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │         SILVER           │
                 │ Cleansed / Transformed   │
                 │        Data Layer        │
                 └────────────┬─────────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │          GOLD            │
                 │ Analytics-Ready Data     │
                 │      Databricks          │
                 └────────────┬─────────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │ Reporting / Analytics    │
                 └──────────────────────────┘


        ┌──────────────────────────────────────┐
        │ Azure SQL Control & Audit Database   │
        │                                      │
        │ • table_config                       │
        │ • watermark                          │
        │ • audit_log                          │
        └──────────────────────────────────────┘
                         │
                         ▼
                 Pipeline Monitoring
                         │
                         ▼
                 Azure Logic Apps
                         │
                         ▼
                   Email Notification
```
[![Architecture diagram of manojchoragudi/hospital_adf_repo](https://gitdiagram.com/manojchoragudi/hospital_adf_repo/diagram.png)](https://gitdiagram.com/manojchoragudi/hospital_adf_repo?utm_source=readme&utm_medium=picture)

---

## Tech Stack

| Technology                       | Purpose                                       |
| -------------------------------- | --------------------------------------------- |
| **Azure Data Factory**           | Pipeline orchestration and data ingestion     |
| **Azure Data Lake Storage Gen2** | Data lake storage                             |
| **Azure Databricks**             | Data transformation and processing            |
| **PySpark**                      | Distributed data processing                   |
| **PostgreSQL**                   | Source database                               |
| **Azure SQL Database**           | Metadata, control and audit management        |
| **Azure Key Vault**              | Secret and credential management              |
| **Azure Logic Apps**             | Pipeline completion notifications             |
| **Parquet**                      | Intermediate/storage format                   |
| **SQL**                          | Source queries, metadata and audit operations |
| **Jupyter/Databricks Notebooks** | Data transformation workflows                 |
| **Git/GitHub**                   | Source control and project management         |

---

## Prerequisites

Before deploying the project, ensure you have:

* An active Azure subscription
* Azure Data Factory
* Azure Data Lake Storage Gen2
* Azure Databricks workspace
* Azure SQL Database
* PostgreSQL source database
* Azure Key Vault
* Azure Logic App
* Appropriate Azure RBAC permissions
* Git/GitHub for source control

### Required Knowledge

* Azure Data Factory
* ADLS Gen2
* Databricks
* PySpark
* SQL
* ETL/ELT concepts
* Azure authentication and security

---

## Installation

### 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd hospital_adf_repo
```

### 2. Import the ADF resources

The repository contains exported Azure Data Factory resources including:

* Pipelines
* Datasets
* Linked services
* Factory configuration

Import these resources into your Azure Data Factory environment.

### 3. Configure Databricks

Upload the notebooks from the repository to the Databricks workspace.

The main notebooks include:

```text
landing-to-bronze.ipynb
Bronze -to-silver.ipynb
Prepare Calendar table.ipynb
```

Gold transformation notebooks are located under:

```text
Gold/
```

### 4. Configure the source database

Execute the PostgreSQL scripts under:

```text
Source/01_Postgres/
```

These scripts create and populate the required source tables and incremental test data.

### 5. Configure Azure SQL control tables

Configure the metadata/control tables used by ADF, including:

```text
ctrl.table_config
ctrl.watermark
ctrl.audit_log
```

---

## Configuration

The solution is metadata-driven. Pipeline behavior is controlled through configuration stored in the Azure SQL control database.

Important metadata includes:

* Source system
* Source table name
* Bronze table name
* Silver table name
* Gold table name
* Load type
* Watermark column
* Merge keys
* Source file format
* Active/inactive status

### Source Systems

The current project supports:

```text
neon_postgres
adls_csv
```

### Environment

The ADF factory contains an environment parameter:

```text
DEV
```

Update environment-specific values before deploying to another environment.

### Security

Connection credentials should be stored securely using:

* Azure Key Vault
* Managed Identity
* Azure RBAC

Do not commit passwords, access keys, SAS tokens, or other secrets to GitHub.

---

## Usage

The main orchestration pipeline is:

```text
PL_MASTER
```

It coordinates the complete data processing workflow.

### Step 1 — Source to Silver

The master pipeline starts source ingestion for:

```text
PostgreSQL
ADLS CSV
```

The reusable pipeline:

```text
PL_SOURCE_TO_SILVER_MAIN
```

reads active tables from the metadata configuration and dynamically processes them.

### Step 2 — Dynamic Table Processing

ADF uses:

```text
Lookup
   ↓
ForEach
   ↓
PL_SOURCE_TO_SILVER_INNER
```

The ForEach activity processes multiple tables in parallel.

### Step 3 — Landing to Bronze

Databricks processes the incoming data into the Bronze layer.

### Step 4 — Bronze to Silver

The Bronze data is transformed using PySpark/Databricks notebooks and written into the Silver layer.

### Step 5 — Silver to Gold

The pipeline:

```text
PL_SILVER_TO_GOLD
```

reads the Gold table configuration and dynamically executes the corresponding Databricks notebooks.

Gold notebooks include:

```text
NB_hospital_daily_summary
NB_lab_test_trends
NB_patient_360
```

### Step 6 — Monitoring and Notification

After processing, the:

```text
PL_SEND_EMAIL
```

pipeline reads the audit information and sends an execution status notification through Azure Logic Apps.

---

## Project Structure

```text
hospital_adf_repo/
│
├── README.md
│
├── factory/
│   └── adf-hospital-caresync.json
│
├── pipeline/
│   ├── PL_MASTER.json
│   ├── PL_SOURCE_TO_SILVER_MAIN.json
│   ├── PL_SOURCE_TO_SILVER_INNER.json
│   ├── PL_SILVER_TO_GOLD.json
│   ├── PL_SEND_EMAIL.json
│   └── test.json
│
├── dataset/
│   ├── CSV_source_Binary.json
│   ├── ds_azuresql.json
│   ├── ds_sink_parquet.json
│   └── ds_source_postgres.json
│
├── linkedService/
│   ├── LS_ADLS.json
│   ├── LS_AzureDatabricks.json
│   ├── LS_AzureKeyVault.json
│   ├── LS_AzureSqlDatabase.json
│   ├── LS_PostgreSql.json
│   └── RestService1.json
│
├── Source/
│   ├── 01_Postgres/
│   │   ├── create_source_tables.sql
│   │   ├── run_incremental_load.sql
│   │   └── run_incremental_load_round_2.sql
│   │
│   ├── 02_Adls_csv/
│   │   ├── Initial_load/
│   │   └── incremental/
│   │
│   └── sttm_silver_to_gold.xlsx
│
├── Gold/
│   ├── NB_hospital_daily_summary.ipynb
│   ├── NB_lab_test_trends.ipynb
│   ├── NB_patient_360.ipynb
│   └── sttm_silver_to_gold.xlsx
│
├── landing-to-bronze.ipynb
├── Bronze -to-silver.ipynb
├── Prepare Calendar table.ipynb
├── silver_check.ipynb
│
├── Metadata Table/
│   └── Queries
│
└── publish_config.json
```

---

## Data Flow / Workflow

### Full End-to-End Workflow

```text
PostgreSQL ───────────────┐
                          │
                          ▼
                    Azure Data Factory
                          │
                          ▼
                     Metadata Lookup
                          │
                          ▼
                    Dynamic ForEach
                          │
                          ▼
                    Landing → Bronze
                          │
                          ▼
                    Bronze → Silver
                          │
                          ▼
                    Silver → Gold
                          │
                          ▼
                 Audit & Record Counts
                          │
                          ▼
                  Email Notification
```

### Incremental Load Workflow

For incremental tables, the pipeline:

1. Reads the table configuration.
2. Reads the existing watermark.
3. Uses the configured watermark column to identify new/changed records.
4. Ingests only records beyond the previous watermark.
5. Processes the data through Bronze and Silver.
6. Updates the watermark after successful processing.
7. Records execution status and record counts in the audit table.

Conceptually:

```text
Previous Watermark
        ↓
Read New/Changed Records
        ↓
      Bronze
        ↓
      Silver
        ↓
Update Watermark
        ↓
      Audit Log
```

### Audit Workflow

The pipeline records:

```text
IN_PROGRESS
     ↓
SUCCESS
     or
FAILED
```

The audit information includes pipeline run information, table information, timestamps, processing stage, status, and records written.

---

## Deployment

A typical deployment process is:

### Development

```text
Develop
  ↓
Test
  ↓
Validate Pipeline
  ↓
Git Commit
```

### Deployment

```text
Git Repository
      ↓
ADF Deployment
      ↓
Databricks Notebook Deployment
      ↓
Environment Configuration
      ↓
Pipeline Execution
```

Before production deployment, update:

* Linked services
* Key Vault references
* Storage account
* Databricks workspace
* Azure SQL connection
* PostgreSQL connection
* Environment parameters
* Logic App endpoint

Secrets and credentials should never be stored directly in source control.

---

## API Endpoints (if applicable)

This project does not expose a traditional REST API.

However, the pipeline uses an **Azure Logic Apps HTTP trigger** as part of the notification workflow.

Azure Data Factory sends a `POST` request containing pipeline execution status information to the Logic App, which then handles email notification.

The Logic App endpoint is environment-specific and should be configured securely rather than committed as a public value.

---

## Contributing

Contributions are welcome.

### Recommended workflow

1. Fork the repository.
2. Create a feature branch.

```bash
git checkout -b feature/<feature-name>
```

3. Make your changes.
4. Test the ADF pipeline and Databricks notebooks.
5. Commit your changes.

```bash
git add .
git commit -m "Add <feature>"
```

6. Push the branch.

```bash
git push origin feature/<feature-name>
```

7. Create a Pull Request.

### Contribution Guidelines

* Follow consistent naming conventions.
* Keep pipelines metadata-driven where possible.
* Do not commit credentials or secrets.
* Test incremental and full-load scenarios.
* Update documentation when pipeline behavior changes.
* Validate Databricks transformations before deployment.

---

## Troubleshooting

### 1. Pipeline cannot connect to PostgreSQL

Check:

* PostgreSQL server availability
* Linked service configuration
* Network/firewall rules
* Credentials
* Integration Runtime connectivity

---

### 2. ADLS ingestion fails

Check:

* Storage account permissions
* ADLS Gen2 filesystem/container
* Folder paths
* Linked service configuration
* Managed Identity/RBAC permissions

---

### 3. Databricks notebook fails

Check:

* Databricks linked service
* Workspace availability
* Notebook path
* Cluster/job configuration
* Notebook parameters
* Input/output paths

---

### 4. Incremental load returns no records

Check:

* `ctrl.watermark`
* Configured watermark column
* Current source data
* Previous watermark value
* Table `load_type`
* Source query generated by the pipeline

---

### 5. Audit status remains `IN_PROGRESS`

Check:

* The corresponding child pipeline execution
* Databricks notebook status
* ADF activity dependencies
* Azure SQL connectivity
* `ctrl.audit_log`

---

### 6. Email notification is not received

Check:

* Azure Logic App workflow
* HTTP trigger
* Logic App URL configuration
* Email recipient
* `PL_SEND_EMAIL`
* Overall audit status

---

## License

This project is provided for **educational, portfolio, and demonstration purposes**.

If you intend to use this project commercially, review and define an appropriate open-source license and ensure that all source datasets and third-party components permit such use.

---

## 👨‍💻 Author

**Manoj Kumar Choragudi**

Azure Data Engineering | Data Engineering | SQL | PySpark | Databricks | Azure Data Factory

### Core Skills Demonstrated

```text
Azure Data Factory
Azure Data Lake Storage Gen2
Azure Databricks
PySpark
SQL
PostgreSQL
Azure SQL Database
Delta/Lakehouse Architecture
Metadata-Driven ETL
Incremental Data Processing
Data Quality & Auditing
Pipeline Orchestration
Azure Logic Apps
Azure Key Vault
```

