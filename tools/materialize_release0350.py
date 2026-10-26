from pathlib import Path
import json,hashlib,base64,zipfile,io,sys,subprocess
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'release/publish-0.35.0.json').read_text())
assert manifest['version']=='0.35.0'
if '--stage' in sys.argv:
 subprocess.run(['git','add','--',*[e['path']for e in manifest['files']]],cwd=root,check=True)
 sys.exit(0)
encoded=''.join((root/name).read_text().strip()for name in manifest['parts'])
payload=base64.b64decode(encoded,validate=True)
assert hashlib.sha256(payload).hexdigest()==manifest['payloadSha256'],'Payload hash mismatch'
expected={e['path']:e['sha256']for e in manifest['files']}
with zipfile.ZipFile(io.BytesIO(payload))as z:
 assert set(z.namelist())==set(expected),'Unexpected payload paths'
 checked=[]
 for name in z.namelist():
  rel=Path(name)
  assert not rel.is_absolute() and '..'not in rel.parts and '.git'not in rel.parts
  assert name.startswith(('KerimAnkaUI/','KerimAnkaUI_','docs/','release/','tools/','.github/ISSUE_TEMPLATE/'))or name in {'README.md','CHANGELOG.md','CONTRIBUTING.md','LICENSE','.gitignore','.github/FUNDING.yml'}
  b=z.read(name);assert hashlib.sha256(b).hexdigest()==expected[name],name
  checked.append((root/rel,b))
 for path,b in checked:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b)
print('Verified and materialized',len(expected),'reviewed changed files')
