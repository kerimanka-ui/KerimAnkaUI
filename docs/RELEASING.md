# Publishing a version

1. Build a reviewed complete-suite ZIP with the nine addon folders at its root.
2. Include Forever TOCs (16001) and Classic Era `_Vanilla.toc` loaders (11509).
3. Verify source, assets, versions, licenses and separate client settings.
4. Publish the reviewed source and a matching GitHub release/tag; verify the downloaded ZIP.
5. The configured GitHub push webhook notifies CurseForge. Automatic packaging is set to tagged commits only.
6. Verify the CurseForge build log, generated ZIP, release type and game-version labels before calling publication complete.

## CurseForge package layout

`.pkgmeta` moves all nine addon folders to the ZIP root and excludes repository tools and documentation. The root `KerimAnkaUI-Suite.toc` declares Forever 1.60.1 and Classic Era 1.15.9 for package discovery; this repository-only file is excluded from the installable ZIP. Keep it synchronized with supported client versions.

The webhook credential belongs only in the private GitHub webhook configuration, never in source, release files or logs. SSL verification remains enabled and only push events are subscribed.

The packaging test `v0.35.0-cf-beta2` succeeded: nine addon folders, 544 files and both game-version labels. The downloaded content matched 0.35.0 after text line-ending normalization. A successful Beta test is not a stable CurseForge release. Do not move an existing tag to republish it; use a new release tag or upload a reviewed stable ZIP with the correct metadata.

## Completed 0.35.0 transport

The temporary `.release-payload/0.35.0` transport chunks, materialization script, version marker and one-time publication workflow were removed after the readable source and complete GitHub release were verified. They are not needed for normal builds or CurseForge packaging. They remain recoverable from Git history.

`tools/package_release.py` and the reviewed `release/0.35.0.json` manifest remain available to reproduce the complete 0.35.0 ZIP.

Preserve user WTF/SavedVariables. Never include game records, credentials or local test artifacts. UI-scale adaptation is deferred. Classic additions must not be claimed as already ported to Forever.
