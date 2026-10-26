from pathlib import Path
import sys,json,hashlib,zipfile
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'release/0.35.0.json').read_text())
out=Path(sys.argv[1] if len(sys.argv)>1 else 'dist');out.mkdir(parents=True,exist_ok=True)
version=manifest['version'];assert version=='0.35.0'
paths={entry['path']for entry in manifest['files']}
modules={path.split('/')[0]for path in paths};assert len(modules)==9
for entry in manifest['files']:
 p=root/entry['path'];assert p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest()==entry['sha256'],entry['path']
actual={p.relative_to(root).as_posix()for mod in modules for p in(root/mod).rglob('*')if p.is_file()}
assert actual==paths,'Unreviewed or missing addon files'
archive=out/f'KerimAnkaUI-{version}-complete-suite.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
 for name in sorted(paths):
  info=zipfile.ZipInfo(name,date_time=(2026,10,26,0,0,0));info.create_system=3;info.external_attr=0o100644<<16;info.compress_type=zipfile.ZIP_DEFLATED
  z.writestr(info,(root/name).read_bytes(),compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
checksum=hashlib.sha256(archive.read_bytes()).hexdigest()
(out/f'KerimAnkaUI-{version}-SHA256SUMS.txt').write_text(checksum+'  '+archive.name+'\n')
print(json.dumps({'archive':str(archive),'sha256':checksum,'files':len(paths)}))
