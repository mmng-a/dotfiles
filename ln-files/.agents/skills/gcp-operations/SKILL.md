---
name: gcp-operations
description: Handle Sendocorp GCP operational work. Use for date-range Cloud Billing cost reports, product cost allocation, Cloud SQL PostgreSQL access, Prisma migrations, and targeted production-like database verification.
---

# GCP Operations

Read the procedure matching the requested operation before accessing Google Cloud.

- Billing export queries and product cost reports: `references/gcp-product-cost-report/SKILL.md`
- Cloud SQL Auth Proxy, Prisma migrations, and targeted SQL checks: `references/cloud-sql-prisma-migration/SKILL.md`

For cost reporting, stop and report an authentication failure rather than substituting estimates. For database work, confirm the target environment and migration scope before any write.
