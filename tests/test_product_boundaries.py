from pathlib import Path
import importlib.util, json, tempfile, unittest, zipfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('products', ROOT / 'tools/package_products.py')
products = importlib.util.module_from_spec(spec)
spec.loader.exec_module(products)

class ProductBoundaryTests(unittest.TestCase):
    def suite_members(self):
        return [name + '/' + name + '.toc' for name in products.SUITE_ROOTS]

    def test_suite_rejects_independent_root(self):
        with self.assertRaises(ValueError):
            products.validate_members('suite', self.suite_members() + ['KerimAnkaUI_Bags/Bootstrap.lua'])

    def test_suite_rejects_nested_independent(self):
        with self.assertRaises(ValueError):
            products.validate_members('suite', self.suite_members() + ['KerimAnkaUI/ClassicEra/KerimAnkaUI_Bags/Bootstrap.lua'])

    def test_bags_rejects_suite_root(self):
        with self.assertRaises(ValueError):
            products.validate_members('bags', ['KerimAnkaUI_Bags/Bootstrap.lua', 'KerimAnkaUI/Core.lua'])

    def test_traversal_and_duplicate_rejected(self):
        for bad in ['../secret', '/secret', 'KerimAnkaUI/../secret', 'C:/secret', 'KerimAnkaUI\\bad']:
            with self.assertRaises(ValueError):
                products.validate_members('suite', self.suite_members() + [bad])
        with self.assertRaises(ValueError):
            products.validate_members('bags', ['KerimAnkaUI_Bags/A.lua', 'KerimAnkaUI_Bags/a.lua'])

    def test_unrelated_root_cannot_enter_actual_suite_zip(self):
        temporary_root = ROOT / 'dist'
        temporary_root.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=temporary_root.resolve()) as temp:
            self.assertEqual(Path(temp).resolve().parent, temporary_root.resolve())
            root = Path(temp) / 'source'; root.mkdir()
            (root / 'packaging').mkdir()
            (root / 'packaging/products.json').write_text((ROOT / 'packaging/products.json').read_text())
            for name in products.SUITE_ROOTS:
                folder = root / name; folder.mkdir()
                (folder / (name + '.toc')).write_text('## Version: 0.35.0\n')
            (root / 'KerimAnkaUI/KerimAnkaUI_Vanilla.toc').write_text('## Version: 0.35.0\n')
            unrelated = root / 'KerimAnkaUI_Bags'; unrelated.mkdir()
            (unrelated / 'MUST_NOT_SHIP.txt').write_text('Independent root trap')
            report = products.build(root, Path(temp) / 'out', 'suite')
            with zipfile.ZipFile(Path(temp) / 'out' / report['archive']) as archive:
                self.assertEqual(set(n.split('/')[0] for n in archive.namelist()), set(products.SUITE_ROOTS))
                self.assertFalse(any('MUST_NOT_SHIP' in n for n in archive.namelist()))
            self.assertFalse(report['uploaded'])

    def test_native_packager_exclusions(self):
        meta = (ROOT / '.pkgmeta').read_text()
        for path in ['KerimAnkaUI_Bags', 'tools', 'packaging', 'tests', 'dist', 'outputs', 'work']:
            self.assertIn('  - ' + path + '\n', meta)
        self.assertNotIn('KerimAnkaUI-Suite/KerimAnkaUI_Bags:', meta)

    def test_product_destinations_are_distinct(self):
        config = json.loads((ROOT / 'packaging/products.json').read_text())['products']
        self.assertEqual(config['suite']['curseforgeProjectId'], 1761131)
        self.assertIsNone(config['bags']['curseforgeProjectId'])
        self.assertTrue(set(config['suite']['roots']).isdisjoint(config['bags']['roots']))

if __name__ == '__main__':
    unittest.main()
