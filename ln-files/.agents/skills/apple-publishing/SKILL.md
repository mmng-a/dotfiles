---
name: apple-publishing
description: Manage Apple publishing work with App Store Connect or the asc CLI. Use for store metadata, localization, release notes, subscription or in-app-purchase display names, metadata ASO audits, and macOS Developer ID notarization.
---

# Apple Publishing

Choose one procedure before making changes. Read only its `SKILL.md` under `references/`; that document retains its scripts, assets, and detailed workflow.

- Store metadata pull, validation, or apply: `references/asc-metadata-sync/SKILL.md`
- Store listing translation or locale synchronization: `references/asc-localize-metadata/SKILL.md`
- What's New or release notes: `references/asc-whats-new-writer/SKILL.md`; use `references/ios-app-store-release-notes/SKILL.md` when the input is a Git range.
- Subscription or IAP display-name localization: `references/asc-subscription-localization/SKILL.md`
- Keyword gap audit from checked-out metadata: `references/asc-aso-audit/SKILL.md`
- macOS archive, export, or Developer ID notarization: `references/asc-notarization/SKILL.md`

Keep the canonical metadata source distinct from generated suggestions. Confirm the exact App Store Connect target before applying any remote change.
