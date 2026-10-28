# Releasing KerimAnka products

1. Keep the nine suite addon roots in the repository. Never commit a generated independent addon root.
2. Update the reviewed release version consistently in all suite TOCs and the two core version labels. The independent package derives its version from the suite Vanilla TOC.
3. Run the product-boundary tests and build both packages from repository sources.
4. Tag the reviewed commit as v<version>. The product-release workflow publishes the suite and independent archives as distinct GitHub release assets.
5. The existing CurseForge webhook handles only the suite through .pkgmeta. The GitHub workflow never uploads to CurseForge, avoiding duplicate suite uploads.
6. Until the independent CurseForge project ID and upload integration are configured, upload only the independent Bags ZIP manually to its new project. Do not mark the suite as a required dependency.
7. Verify installed files through CurseForge and record project/file IDs. GitHub success is not proof of CurseForge approval.

No Base64 transport payload or one-time source-materialization workflow is needed.
Preserve user WTF/SavedVariables and keep Classic Era and Forever implementations separate.
The .pkgmeta excludes all build tools, tests, output and independent addon roots.
