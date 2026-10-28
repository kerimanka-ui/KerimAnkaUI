from pathlib import Path
import argparse,hashlib,json,re

def check(root, output, tag):
    if not re.fullmatch(r'v\d+\.\d+\.\d+',tag):raise ValueError('Unexpected release tag')
    version=tag[1:]
    reviewed=json.loads((root/f'release/{version}.json').read_text())
    if reviewed['version']!=version or not reviewed.get('archiveHashes'):
        raise ValueError('Release metadata/hashes not reviewed')
    actual_hashes={}
    for name in reviewed['archiveHashes']:
        if Path(name).name!=name:raise ValueError('Unexpected archive name')
        actual_hashes[name]=hashlib.sha256((output/name).read_bytes()).hexdigest()
    for product in ('suite','bags'):
        report=json.loads((output/f'{product}-package-report.json').read_text())
        if report['version']!=version:raise ValueError('Product version mismatch')
        if report['archive']not in reviewed['archiveHashes']:raise ValueError('Unexpected product archive')
        # ZIP compression can differ across OS/zlib versions. Compare all file
        # paths and content hashes, then publish the rebuilt archive's checksum.
        if report['members']!=reviewed['productMembers'][product]:
            raise ValueError('Rebuilt product payload differs from reviewed files: '+product)
        if report['sha256']!=actual_hashes[report['archive']]:raise ValueError('Archive report hash mismatch')
    sums=''.join(value+'  '+name+'\n'for name,value in sorted(actual_hashes.items()))
    (output/f'KerimAnka-{version}-SHA256SUMS.txt').write_text(sums,encoding='utf-8')
    print('Reviewed suite and independent file manifests match; ZIP checksums generated.')
    return dict(reviewed,archiveHashes=actual_hashes)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--tag',required=True);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();check(Path(__file__).resolve().parents[1],args.output.resolve(),args.tag)
