---
name: gcp-product-cost-report
description: Produce Sendocorp GCP product cost tables from Cloud Billing Export using gcloud and bq. Use when asked for monthly or date-range GCP costs for products such as odamaki, monaca, textube, uirou, shared DBs, Cloud Run, GKE, Cloud SQL, AlloyDB, or the asterisk-prod VM, especially when the desired output is a table of item name, product name, and cost.
---

# GCP Product Cost Report

## Overview

Use this skill to reproduce the product-cost report built from the `sendoapp-437702` Cloud Billing Export. Treat Billing Export as the source of truth for cost and use `gcloud` only to confirm resource labels/settings when attribution is ambiguous.

Default table:

| item_name | product_name | cost |
|---|---|---:|
| Cloud SQL `odamaki-db` | odamaki | ... |
| GKE `odamaki-eque-prod` | odamaki | ... |
| Cloud Run Odamaki系 | odamaki | ... |
| 共有DB `sendoapp-psgl` | odamaki参考 | ... |
| Cloud Run `monaca` | monaca | ... |
| Cloud Run `textube` | textube | ... |
| 共有DB AlloyDB | monaca / textube / 他共有 | ... |
| VPC connector `uirou-api-conn` | uirou | ... |
| Cloud Run `uirou-api-prod` 本体候補 | uirou | ... |
| VM `asterisk-prod` 相当 | uirou | ... |

## Workflow

1. Confirm the requested period. If the user says "this month" or "暫定", use the current month through the latest exported Billing Export row. Use JST month boundaries unless the user specifies otherwise.
2. Confirm the export range:

```bash
bq query --project_id=sendoapp-437702 --use_legacy_sql=false '
SELECT
  MIN(DATE(usage_start_time, "Asia/Tokyo")) AS first_day_jst,
  MAX(DATE(usage_start_time, "Asia/Tokyo")) AS last_day_jst,
  COUNT(*) AS row_count
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH'
```

3. Run the product bucket query below after replacing `YYYY-MM-01`.
4. Run the shared DB query below.
5. Run the uirou/VM ambiguity checks when uirou is in scope.
6. Return a concise table. Clearly mark shared costs and candidates so they are not double-counted.

## Product Bucket Query

This query returns the directly attributed buckets:

```bash
bq query --project_id=sendoapp-437702 --use_legacy_sql=false '
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM UNNEST(labels) l
      WHERE l.key="k8s-label/app" AND l.value="odamaki-eque-prod"
    ) THEN "GKE `odamaki-eque-prod`|odamaki"
    WHEN EXISTS(
      SELECT 1 FROM UNNEST(labels) l
      WHERE l.key="gcb-trigger-id" AND l.value IN (
        "03d427e1-7613-4e99-9542-59a60234c751",
        "4fe59ba4-527a-4bbb-a15f-2b4b619f2ddb",
        "1575d88e-b512-4d20-99f6-a617c45eb64f",
        "86d5c9b7-c29c-4b41-99cf-5d0d37f529f2",
        "d04c5999-62b1-4819-8b29-51b56f96632d",
        "c6b5348c-3ac6-41aa-b07f-856a6b2f2411",
        "28713840-553d-464d-a745-fab2c949f301",
        "3b13ae8b-abb0-4b05-96c1-055ec3673f28",
        "30547744-c68c-4078-9463-b3ae743cfac3"
      )
    ) THEN "Cloud Run Odamaki系|odamaki"
    WHEN service.description="Cloud SQL" AND location.region="asia-northeast1"
      THEN "Cloud SQL `odamaki-db`|odamaki"
    WHEN EXISTS(
      SELECT 1 FROM UNNEST(labels) l
      WHERE l.key="gcb-trigger-id" AND l.value="6f0af9d8-4312-4fc3-a97e-6ffd39285aaa"
    ) THEN "Cloud Run `monaca`|monaca"
    WHEN EXISTS(
      SELECT 1 FROM UNNEST(labels) l
      WHERE l.key="gcb-trigger-id" AND l.value="550d1fbd-85c6-42a1-a734-5b80b1c6c478"
    ) THEN "Cloud Run `textube`|textube"
    WHEN EXISTS(
      SELECT 1 FROM UNNEST(labels) l
      WHERE l.key="serverless-vpc-access" AND l.value="uirou-api-conn"
    ) THEN "VPC connector `uirou-api-conn`|uirou"
    ELSE NULL
  END AS item_product,
  ROUND(SUM(cost)+SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits)c),0)),2) AS cost
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE project.id="sendoapp-437702"
  AND DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH
GROUP BY item_product
HAVING item_product IS NOT NULL
ORDER BY item_product'
```

Split `item_product` on `|` into `item_name` and `product_name`.

## Shared DB Query

Shared DB costs are references, not direct product costs. Do not add AlloyDB separately to both monaca and textube totals.

```bash
bq query --project_id=sendoapp-437702 --use_legacy_sql=false '
SELECT "共有DB AlloyDB|monaca / textube / 他共有" AS item_product,
       ROUND(SUM(cost)+SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits)c),0)),2) AS cost
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE project.id="sendoapp-437702"
  AND service.description="AlloyDB"
  AND DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH
UNION ALL
SELECT "共有DB `sendoapp-psgl`|odamaki参考" AS item_product,
       ROUND(SUM(cost)+SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits)c),0)),2) AS cost
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE project.id="sendoapp-437702"
  AND service.description="Cloud SQL"
  AND location.region="us-central1"
  AND DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH'
```

## Uirou Ambiguity Checks

`uirou-api-prod` is unlabeled in Billing Export. Attribute it as a candidate, not a hard fact, unless labels have been fixed.

Confirm Cloud Run settings:

```bash
gcloud run services describe uirou-api-prod \
  --project=sendoapp-437702 \
  --region=asia-northeast1 \
  --format='yaml(metadata.name,metadata.labels,spec.template.metadata.annotations,spec.template.spec.containers[0].resources.limits)'
```

Known signal: `uirou-api-prod` uses `minScale=1`, `run.googleapis.com/cpu-throttling=false`, CPU `4`, memory `4Gi`, and VPC connector `uirou-api-conn`. Therefore no-label `Services CPU/Memory (Instance-based billing)` in asia-northeast1 is the high-confidence Cloud Run body candidate.

Query the candidate:

```bash
bq query --project_id=sendoapp-437702 --use_legacy_sql=false '
SELECT "Cloud Run `uirou-api-prod` 本体候補|uirou" AS item_product,
       ROUND(SUM(cost)+SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits)c),0)),2) AS cost
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE project.id="sendoapp-437702"
  AND service.description="Cloud Run"
  AND ARRAY_LENGTH(labels)=0
  AND sku.description IN (
    "Services CPU (Instance-based billing) in in asia-northeast1",
    "Services Memory (Instance-based billing) in asia-northeast1"
  )
  AND DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH'
```

For `asterisk-prod`, first confirm the current VM:

```bash
gcloud compute instances describe asterisk-prod \
  --project=sendoapp-437702 \
  --zone=asia-northeast1-b \
  --format='yaml(name,creationTimestamp,machineType,status,labels)'
```

Then query Terraform-provisioned VM costs as the current proxy:

```bash
bq query --project_id=sendoapp-437702 --use_legacy_sql=false '
SELECT "VM `asterisk-prod` 相当|uirou" AS item_product,
       ROUND(SUM(cost)+SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits)c),0)),2) AS cost
FROM `sendoapp-437702.sendoapp_daily_cost_normal.gcp_billing_export_v1_01CA71_0AF972_B68890`
WHERE project.id="sendoapp-437702"
  AND service.description="Compute Engine"
  AND EXISTS(
    SELECT 1 FROM UNNEST(labels) l
    WHERE l.key="goog-terraform-provisioned" AND l.value="true"
  )
  AND DATE(usage_start_time, "Asia/Tokyo") >= DATE("YYYY-MM-01")
  AND DATE(usage_start_time, "Asia/Tokyo") < DATE("YYYY-MM-01") + INTERVAL 1 MONTH'
```

Mention that Billing Export usually does not expose the VM name directly. If other Terraform-provisioned VMs exist in the same period, report the amount as a proxy or candidate.

## Output Rules

- Use JPY and net cost: `SUM(cost) + SUM(credits.amount)`.
- State the available export date range for provisional month reports.
- Do not include tax unless the user asks for invoice totals.
- Mark shared DB rows as `参考` or shared in the product name.
- Mark `uirou-api-prod` and `asterisk-prod` as candidates/proxies when attribution depends on unlabeled Billing Export rows.
- Prefer a single Markdown table with columns: `項目名`, `プロダクト名`, `費用`.
