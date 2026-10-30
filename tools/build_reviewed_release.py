from pathlib import Path
import argparse,json,re
from package_products import build
p=argparse.ArgumentParser();p.add_argument('--tag',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
if not re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+',a.tag):raise ValueError('Invalid tag')
root=Path(__file__).resolve().parents[1];meta=json.loads((root/'release'/(a.tag[1:]+'.json')).read_text())
if meta['version']!=a.tag[1:]:raise ValueError('Version mismatch')
for product in meta['productMembers']:
 if product not in ('suite','bags'):raise ValueError('Unsupported product')
 build(root,a.output.resolve(),product,True)
