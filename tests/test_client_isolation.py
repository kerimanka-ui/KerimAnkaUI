"""Verify the assembled package's two real client load graphs and frozen Era payload."""
from pathlib import Path
import hashlib,json,re,unittest,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
M=json.loads((ROOT/'packaging/client-isolation.json').read_text())
def digest(path):
 data=path.read_bytes()
 if path.suffix.lower()in{'.lua','.toc','.xml','.md','.txt'}or path.name=='LICENSE':data=data.removeprefix(b'\xef\xbb\xbf').replace(b'\r\n',b'\n')
 return hashlib.sha256(data).hexdigest()
def graph(classic):
 seen=set()
 def read(rel):
  if rel in seen:return
  p=ROOT/rel
  if not p.is_file():raise AssertionError('Missing client load target: '+rel)
  seen.add(rel)
  if p.suffix=='.toc':
   lines=[s.strip()for s in p.read_text(encoding='utf-8-sig').splitlines()if s.strip()and not s.startswith('#')]
  elif p.suffix=='.xml':lines=[n.attrib['file']for n in ET.fromstring(p.read_text()).iter()if 'file'in n.attrib and '$'not in n.attrib['file']]
  else:lines=[]
  for line in lines:
   child=(Path(rel).parent/line.replace('\\','/')).as_posix()
   if '..'in Path(child).parts:raise AssertionError('Unsafe load target')
   read(child)
 for mod in json.loads((ROOT/'packaging/products.json').read_text())['products']['suite']['roots']:
  read(mod+'/'+mod+('_Vanilla.toc'if classic else'.toc'))
 return seen
class ClientIsolationTests(unittest.TestCase):
 def test_classic_exact_load_graph_and_frozen_hashes(self):
  self.assertEqual(graph(True),set(M['classicClosure']))
  for rel in M['classicClosure']:
   self.assertIn(rel,M['preservedClassicAndMedia'] if rel!='KerimAnkaUI_Chat/Bootstrap.lua' else {rel:None})
  for rel,expected in M['preservedClassicAndMedia'].items():self.assertEqual(digest(ROOT/rel),expected,rel)
 def test_forever_graph_never_loads_classic_era(self):
  paths=graph(False);self.assertEqual(paths,set(M['foreverClosure']))
  self.assertFalse(any('/ClassicEra/'in p or p.endswith('_Vanilla.toc')for p in paths))
  for rel,expected in M['foreverFiles'].items():self.assertEqual(digest(ROOT/rel),expected,rel)
 def test_shared_loaded_code_is_identical(self):
  shared=graph(True)&graph(False);self.assertEqual(shared,set(M['sharedLoadFiles']))
  self.assertEqual(shared,{'KerimAnkaUI_Chat/Bootstrap.lua'})
  previous=json.loads((ROOT/'release/0.37.0.json').read_text())['productMembers']['suite']
  expected={e['path']:e['sha256']for e in previous}
  for rel in shared:self.assertEqual(digest(ROOT/rel),expected[rel])
 def test_client_toc_interfaces_versions_and_storage_are_separate(self):
  roots=json.loads((ROOT/'packaging/products.json').read_text())['products']['suite']['roots']
  for mod in roots:
   for suffix,interface,version in [('',16001,M['version']),('_Vanilla',11509,'0.37.0')]:
    text=(ROOT/mod/(mod+suffix+'.toc')).read_text()
    self.assertRegex(text,r'(?m)^## Interface: '+str(interface)+r'\s*$')
    self.assertRegex(text,r'(?m)^## Version: '+re.escape(version)+r'\s*$')
  forever=(ROOT/'KerimAnkaUI/KerimAnkaUI.toc').read_text();classic=(ROOT/'KerimAnkaUI/KerimAnkaUI_Vanilla.toc').read_text()
  self.assertIn('## SavedVariables: KerimAnkaUIDB',forever)
  self.assertIn('## SavedVariables: KAClassic_KerimAnkaUIDB',classic)
 def test_forever_only_publication_metadata(self):
  meta=(ROOT/'KerimAnkaUI-Suite.toc').read_text()
  self.assertIn('## Interface: 16001',meta);self.assertNotIn('11509',meta)
  config=json.loads((ROOT/'packaging/products.json').read_text())
  self.assertEqual(config['versionFile'],'KerimAnkaUI/KerimAnkaUI.toc')
  release=json.loads((ROOT/'release'/(M['version']+'.json')).read_text())
  self.assertEqual(set(release['productMembers']),{'suite'})
  self.assertEqual(release['gameVersions'],['1.60.1'])
if __name__=='__main__':unittest.main()
