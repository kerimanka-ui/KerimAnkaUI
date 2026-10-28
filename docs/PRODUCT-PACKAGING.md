# Product packaging

One source repository produces two distinct installable products:

- Suite: the existing nine KerimAnkaUI addon directories, including the integrated bag feature.
- Independent Classic Era Bags: only the generated KerimAnkaUI_Bags directory, with its own fonts/media/settings.

Do not commit generated independent addon directories at repository root. The
generator in tools/bags uses the suite's Classic Era sources and small private
host/panel adapters. Build tools and independent addon roots are excluded from
the suite through .pkgmeta as well as explicit archive-root checks.

Run `python -m unittest discover -s tests -p test_product_boundaries.py -v`
and `python tools/package_products.py --release --output dist` before releasing.
Both archives are reopened and verified. Reports list every member and hash.

The product-release workflow rebuilds tagged source and verifies hashes against
the reviewed release/<version>.json before publishing separate GitHub assets.
Normal changes only produce preview artifacts. Neither workflow uploads to
CurseForge: the existing suite webhook remains the single suite-upload path.
The independent CurseForge product has no assigned ID yet and initially needs
its own project/file submission. Never fall back to the suite project ID.

At this stage a release tag builds both products. Automatic selection of changed
products and per-product CurseForge uploads are follow-up work, not implemented
by this release. Keep Classic Era and Forever code/settings separate.
