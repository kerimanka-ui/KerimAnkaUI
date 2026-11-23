"""Protect game-approved byte hashes from Git and packaging transformations."""
from pathlib import Path
import hashlib,importlib.util,json,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('approved_products',ROOT/'tools/package_products.py')
products=importlib.util.module_from_spec(spec);spec.loader.exec_module(products)
class ApprovedPayloadTests(unittest.TestCase):
 def test_exact_quest_and_mail_payloads(self):
  pins=json.loads((ROOT/'packaging/products.json').read_text())['exactByteFiles']
  self.assertEqual(pins['KerimAnkaUI_QuestJournal/KerimAnkaUI_QuestJournal.lua'],'984bcc08267487824d592c9299bd69127f08394184b563bd5995eaefe88b3ca5')
  for rel,h in pins.items():
   self.assertEqual(hashlib.sha256((ROOT/rel).read_bytes()).hexdigest(),h)
   self.assertIn(rel+' -text !eol',(ROOT/'.gitattributes').read_text())
 def test_raw_bytes_survive_collection_and_tampering_is_rejected(self):
  data=b'local supported = true\r\nreturn supported\n'
  rel='KerimAnkaUI/Approved.lua';pins={rel:hashlib.sha256(data).hexdigest()}
  with tempfile.TemporaryDirectory() as temp:
   root=Path(temp);(root/'KerimAnkaUI').mkdir()
   (root/'KerimAnkaUI/KerimAnkaUI.toc').write_text('## Version: 0.40.6\n')
   (root/rel).write_bytes(data)
   self.assertEqual(products.collect(root,['KerimAnkaUI'],pins)[rel],data)
   (root/rel).write_bytes(data.replace(b'\r\n',b'\n'))
   with self.assertRaisesRegex(ValueError,'Pinned game-approved file changed'):
    products.collect(root,['KerimAnkaUI'],pins)
 def test_private_boot_links_are_absent(self):
  toc=(ROOT/'KerimAnkaUI/KerimAnkaUI.toc').read_text()
  self.assertNotIn('PrivateCaptureStart',toc);self.assertNotIn('!KerimAnkaCaptureBoot',toc)
  self.assertFalse((ROOT/'KerimAnkaUI/PrivateCaptureStart.lua').exists())
  pkg=(ROOT/'.pkgmeta').read_text()
  for name in ['KerimAnkaUI_QuestCallLab','KerimAnkaPrivateDiagnostics','!KerimAnkaCaptureBoot']:self.assertIn(name,pkg)
if __name__=='__main__':unittest.main()
