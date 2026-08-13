---
name: cloud-sql-prisma-migration
description: Apply, verify, or explain Prisma migrations and targeted SQL checks against Google Cloud SQL for PostgreSQL using Cloud SQL Auth Proxy. Use when Codex needs to update STG or production-like Cloud SQL databases, extract DATABASE_URL from Cloud Run, run npx prisma migrate deploy/status, or distinguish this Cloud SQL workflow from AlloyDB connectivity.
---

# Cloud SQL Prisma Migration

## Overview

Use this skill for Cloud SQL PostgreSQL database maintenance from a local Codex session. The standard pattern is: discover the deployed DB connection string, start Cloud SQL Auth Proxy, rewrite the connection host to a local port, run non-interactive verification or Prisma migration commands, then stop the proxy.

This skill is for Cloud SQL. For AlloyDB, use AlloyDB Auth Proxy or a VPC-native execution path; Cloud SQL Auth Proxy does not connect to AlloyDB.

## Workflow

1. Confirm target environment and side effect.
   - Verify whether the target is STG, production, or another environment.
   - Do not run migrations or data-changing SQL unless the user asked for that target.
   - Prefer `npx prisma migrate deploy` for STG/production-like databases. Do not use `migrate dev` against real shared environments.

2. Get the deployed database URL when it is stored on Cloud Run.

```sh
gcloud run services describe SERVICE_NAME \
  --project PROJECT_ID \
  --region REGION \
  --format=json
```

Read the service environment and locate `DATABASE_URL`. Avoid printing secrets in final output.

3. Start Cloud SQL Auth Proxy on a local port.

```sh
cloud-sql-proxy --gcloud-auth --port LOCAL_PORT PROJECT_ID:REGION:INSTANCE_NAME
```

If the proxy binary is stored outside `PATH`, use its absolute path. Keep the process running while migration or SQL commands execute.

4. Rewrite the connection URL for local proxy access.

Convert:

```text
postgresql://USER:PASSWORD@ORIGINAL_HOST:5432/DB_NAME
```

to:

```text
postgresql://USER:PASSWORD@127.0.0.1:LOCAL_PORT/DB_NAME
```

Preserve user, password, database name, and required query parameters unless the proxy path requires a deliberate change.

5. Run targeted pre-checks only when the migration requires them.

Do not invent a universal pre-check. For example, before adding a unique index, check duplicates for the target key. For ordinary migrations, go directly to deploy after confirming target and connectivity.

6. Apply and verify Prisma migrations.

```sh
DATABASE_URL="postgresql://USER:PASSWORD@127.0.0.1:LOCAL_PORT/DB_NAME" \
  npx prisma migrate deploy

DATABASE_URL="postgresql://USER:PASSWORD@127.0.0.1:LOCAL_PORT/DB_NAME" \
  npx prisma migrate status
```

When a migration creates a known index, column, or table, verify it with a focused `psql -Atc` query if useful.

7. Stop Cloud SQL Auth Proxy after verification.

## Command Pattern

Use a small script or one-liner to avoid exposing secrets in logs. The important pattern is to parse the Cloud Run JSON, extract `DATABASE_URL`, replace host and port with the local proxy address, and pass it only through the command environment.

Example shape:

```sh
node -e 'const cp=require("child_process");
const svc=JSON.parse(cp.execFileSync("gcloud",[
  "run","services","describe","SERVICE_NAME",
  "--project","PROJECT_ID","--region","REGION","--format=json"
],{encoding:"utf8"}));
const raw=svc.spec.template.spec.containers[0].env.find(e=>e.name==="DATABASE_URL")?.value;
if(!raw) throw new Error("DATABASE_URL not found");
const u=new URL(raw);
const tcp=`postgresql://${u.username}:${u.password}@127.0.0.1:LOCAL_PORT${u.pathname}${u.search}`;
cp.execFileSync("npx",["prisma","migrate","deploy"],{stdio:"inherit",env:{...process.env,DATABASE_URL:tcp}});
cp.execFileSync("npx",["prisma","migrate","status"],{stdio:"inherit",env:{...process.env,DATABASE_URL:tcp}});
'
```

## Failure Handling

- If `gcloud` auth is expired, stop and ask the user to reauthenticate. Do not keep trying unrelated fallbacks.
- If the proxy cannot connect, confirm the instance name, project, region, IAM access, and whether the database is Cloud SQL or AlloyDB.
- If the target is AlloyDB, switch to AlloyDB Auth Proxy or run from a VPC-visible host such as a bastion VM, Cloud Run Job, or Cloud Build step.
- If `migrate dev` suggests reset or drift handling on a shared environment, do not proceed. Use `migrate deploy` for real environments.
- If output contains credentials, do not repeat them in the user-facing report.
