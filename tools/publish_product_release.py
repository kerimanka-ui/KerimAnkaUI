"""Publish already-reviewed GitHub assets. No CurseForge API calls."""
from pathlib import Path
import argparse,hashlib,json,os,re,subprocess,tempfile
from check_product_release import check

def gh(*args,optional=False):
    result=subprocess.run(['gh',*args],text=True,capture_output=True)
    if result.returncode and not optional:raise RuntimeError(result.stderr.strip())
    return result

def publish(root,output,tag):
    reviewed=check(root,output,tag);version=tag[1:]
    if os.environ.get('GH_REPO')!='kerimanka-ui/KerimAnkaUI':raise ValueError('Unexpected GitHub repository')
    targets={name:value for name,value in reviewed['archiveHashes'].items()}
    sums=f'KerimAnka-{version}-SHA256SUMS.txt'
    targets[sums]=hashlib.sha256((output/sums).read_bytes()).hexdigest()
    result=gh('release','view',tag,'--json','isDraft,assets',optional=True)
    if result.returncode:
        gh('release','create',tag,'--verify-tag','--draft','--title',reviewed.get('title',f'KerimAnka UI {version}'),
           '--notes-file',str(root/f'release/{version}-notes.md'))
        result=gh('release','view',tag,'--json','isDraft,assets')
    info=json.loads(result.stdout);assets={entry['name']for entry in info['assets']}
    if assets-set(targets):raise ValueError('Existing release has unreviewed assets; refusing to replace anything')
    with tempfile.TemporaryDirectory(prefix='.verify-',dir=output.resolve())as temporary:
        if Path(temporary).resolve().parent!=output.resolve():raise ValueError('Unexpected verification directory')
        for name,expected in targets.items():
            if name not in assets:
                if not info['isDraft']:raise ValueError('Published release is incomplete; refusing to change it')
                gh('release','upload',tag,str(output/name))
            gh('release','download',tag,'--pattern',name,'--dir',temporary)
            if hashlib.sha256((Path(temporary)/name).read_bytes()).hexdigest()!=expected:
                raise ValueError('Downloaded release asset hash mismatch: '+name)
    if info['isDraft']:gh('release','edit',tag,'--draft=false','--latest')
    print('Published and download-verified: https://github.com/kerimanka-ui/KerimAnkaUI/releases/tag/'+tag)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--tag',required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();publish(Path(__file__).resolve().parents[1],a.output.resolve(),a.tag)
