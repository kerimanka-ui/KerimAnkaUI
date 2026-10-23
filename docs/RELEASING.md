# Publishing a version

1. Verify the target-client behavior and update version metadata and CHANGELOG.md.
2. Build the installable ZIP with exactly the nine addon folders at its root.
   Keep repository-only files, screenshots, local game data and credentials out.
3. Check every ZIP entry against the reviewed source, license notices and TOCs.
4. Commit the reviewed source and documentation. Tag that exact commit with the
   release version, for example v0.34.16.
5. Create a GitHub release as a draft, attach the checked complete-suite ZIP and
   SHA256SUMS.txt, and add user-facing notes and compatibility limitations.
6. Publish the completed release and mark it latest when appropriate. Verify the
   download as an unauthenticated visitor after the repository is public.
7. Upload the same checked ZIP to CurseForge with its matching game version and
   release notes. Its source link alone does not upload an installable package.

GitHub Packages is not used for this addon. Releases contains the installable
downloads. Wiki documentation and automated distribution can be added later;
there is no automatic CurseForge publishing configuration in this repository.
Never put service tokens, game SavedVariables or local installation paths here.
