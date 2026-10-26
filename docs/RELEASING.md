# Publishing a version

1. Build one reviewed complete-suite ZIP with the nine addon folders at its root.
2. Include both normal Forever TOCs (16001) and Classic Era `_Vanilla.toc` loaders (11509).
3. Verify TOC/XML/assets, Lua syntax, version metadata, licenses and client isolation.
4. Commit source and documentation, tag the same commit, then upload the ZIP and SHA256SUMS to a draft GitHub release.
5. Publish and verify the downloaded asset hash before reporting completion.
6. Submit that same package to CurseForge with the matching client/game-version metadata.
   No automatic CurseForge publishing workflow is configured; GitHub alone is not a file upload there.

Preserve user WTF/SavedVariables. Never include game records, credentials or local test artifacts.
UI-scale adaptation is not part of 0.35.0. Classic additions must not be claimed as already ported to Forever.

For 0.35.0, `.github/workflows/release-0.35.0.yml` validates the reviewed file
manifest, builds the ZIP and publishes the tagged GitHub release when its version
marker is pushed to main. It does not publish to CurseForge.

The version-scoped bootstrap sends only changed files as verified transport
chunks. Its workflow checks the manifest, commits the normal readable source
and binary assets, then builds and publishes the complete suite. Unchanged
artwork is reused from Git; this is not a patch-only download.
