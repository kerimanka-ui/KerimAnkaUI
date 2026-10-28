"""Build reviewable product archives. This command never uploads anything."""
from pathlib import Path, PurePosixPath
import argparse, hashlib, json, re, subprocess, sys, tempfile, zipfile

SUITE_ROOTS = frozenset({
    'KerimAnkaUI', 'KerimAnkaUI_AspectAlert', 'KerimAnkaUI_BarBackdrop',
    'KerimAnkaUI_ClassArt', 'KerimAnkaUI_DetailsSkin', 'KerimAnkaUI_HunterRange',
    'KerimAnkaUI_QuestJournal', 'KerimAnkaUI_Threat', 'KerimAnkaUI_UnitFrames',
})
BAG_ROOT = 'KerimAnkaUI_Bags'

def validate_members(product, names):
    allowed = SUITE_ROOTS if product == 'suite' else {BAG_ROOT}
    seen = set()
    roots = set()
    for name in names:
        p = PurePosixPath(name)
        if not p.parts or p.is_absolute() or '..' in p.parts or '\\' in name or ':' in name:
            raise ValueError('Unsafe archive member: ' + name)
        if name.casefold() in seen:
            raise ValueError('Duplicate archive member: ' + name)
        seen.add(name.casefold())
        roots.add(p.parts[0])
        if p.parts[0] not in allowed:
            raise ValueError('Wrong product root: ' + name)
        if product == 'suite' and BAG_ROOT.casefold() in (v.casefold() for v in p.parts):
            raise ValueError('Independent bags leaked into suite: ' + name)
        if len(p.parts) > 2 and p.name.lower().endswith('.toc'):
            raise ValueError('Nested installable addon: ' + name)
    if roots != set(allowed):
        raise ValueError('Missing product roots: ' + str(set(allowed) - roots))

def canonical_content(name, data):
    # Old Git blobs may retain CRLF even after adding eol=lf attributes.
    # Normalize text at the package boundary; never alter binary media.
    p = Path(name)
    if p.suffix.lower() in {'.lua', '.toc', '.xml', '.md', '.txt', '.json', '.py', '.yml', '.yaml', '.sh'} or p.name in {'LICENSE', 'LICENCE', '.pkgmeta', '.gitignore', '.gitattributes'}:
        return data.removeprefix(b'\xef\xbb\xbf').replace(b'\r\n', b'\n')
    return data

def collect(root, roots):
    entries = {}
    for folder in roots:
        if folder not in SUITE_ROOTS | {BAG_ROOT}:
            raise ValueError('Unreviewed addon root: ' + folder)
        source = root / folder
        if source.is_symlink() or not source.is_dir():
            raise ValueError('Missing or linked addon root: ' + folder)
        if not list(source.glob('*.toc')):
            raise ValueError('Addon has no TOC: ' + folder)
        for p in source.rglob('*'):
            if p.is_symlink():
                raise ValueError('Linked source: ' + str(p))
            if p.is_file():
                rel = p.relative_to(root).as_posix()
                if any(v.startswith('.') for v in p.relative_to(source).parts):
                    raise ValueError('Unexpected hidden file: ' + rel)
                entries[rel] = canonical_content(rel, p.read_bytes())
    return entries

def validate_bags(entries):
    own = BAG_ROOT + '/'
    for name, data in entries.items():
        if name.endswith('.lua'):
            if b'AddOns\\\\KerimAnkaUI\\\\' in data:
                raise ValueError('Independent media still requires suite: ' + name)
    for filename in ('KerimAnkaUI_Bags.toc', 'KerimAnkaUI_Bags_Vanilla.toc'):
        text = entries[own + filename].decode('utf-8-sig')
        if '## Group: KerimAnkaUI_Bags' not in text or '## Category: Bags & Inventory' not in text:
            raise ValueError('Independent grouping metadata missing')
        if re.search(r'^## (?:Dependencies|RequiredDeps):', text, re.M):
            raise ValueError('Independent product has a mandatory dependency')
        for line in text.splitlines():
            if line.strip() and not line.startswith('#'):
                target = own + line.strip().replace('\\', '/')
                if target not in entries:
                    raise ValueError('Missing independent TOC file: ' + target)

def build(root, output, product, release=False):
    config = json.loads((root / 'packaging/products.json').read_text())
    spec = config['products'][product]
    version = re.search(r'^## Version: ([0-9]+\.[0-9]+\.[0-9]+)\s*$',
                        (root / config['versionFile']).read_text(encoding='utf-8-sig'), re.M)
    if not version:
        raise ValueError('Invalid shared release version')
    version = version.group(1)
    expected = SUITE_ROOTS if product == 'suite' else {BAG_ROOT}
    if set(spec['roots']) != set(expected):
        raise ValueError('Product manifest changed its reviewed root boundary')
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.build-', dir=output.resolve()) as temp:
        if Path(temp).resolve().parent != output.resolve():
            raise ValueError('Temporary build directory escaped output')
        source = root
        if product == 'bags':
            source = Path(temp)
            subprocess.run([sys.executable, str(root / spec['generator']),
                            '--source', str(root), '--output', str(source / BAG_ROOT)], check=True)
        entries = collect(source, spec['roots'])
        validate_members(product, entries)
        if product == 'bags':
            validate_bags(entries)
        output.mkdir(parents=True, exist_ok=True)
        suffix = ('-complete-suite' if product == 'suite' else '') if release else '-preview'
        target = output / (spec['archiveName'] + '-' + version + suffix + '.zip')
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, data in sorted(entries.items()):
                info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                archive.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
        # Reopen and inspect the real ZIP, not just the proposed input list.
        with zipfile.ZipFile(target) as archive:
            validate_members(product, archive.namelist())
            for name, data in entries.items():
                if archive.read(name) != data:
                    raise ValueError('Archive verification failed: ' + name)
        report = {
            'product': product, 'version': version, 'archive': target.name,
            'curseforgeProjectId': spec['curseforgeProjectId'], 'uploaded': False,
            'roots': sorted(expected), 'files': len(entries),
            'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
            'members': [{'path': name, 'sha256': hashlib.sha256(data).hexdigest()}
                        for name, data in sorted(entries.items())],
        }
        (output / (product + '-package-report.json')).write_text(json.dumps(report, indent=2) + '\n')
        return {k: v for k, v in report.items() if k != 'members'}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--release', action='store_true')
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--product', choices=['suite', 'bags', 'all'], default='all')
    args = parser.parse_args()
    for product in (['suite', 'bags'] if args.product == 'all' else [args.product]):
        print(json.dumps(build(args.root.resolve(), args.output.resolve(), product, args.release)))
