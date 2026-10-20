import sys
import unittest
from pathlib import Path

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import verify_release as v

class TestOfflineValidation(unittest.TestCase):
    def test_sha256(self):
        self.assertEqual(v.hash_bytes(b'abc'),'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')
    def test_safe_member(self):
        for name in ['AutoScript/config.ini','AutoScript/autoABC/autoabc_disc','CHECK_READONLY.sh']:
            v.assert_safe_member(name)
    def test_path_traversal_rejected(self):
        for name in ['../evil','/tmp/evil','x/../../bad','x\\bad','__MACOSX/foo','x/._state','x/.DS_Store']:
            with self.subTest(name=name), self.assertRaises(ValueError):
                v.assert_safe_member(name)
    def test_hash_pins_present(self):
        self.assertEqual(len(v.EXPECTED['install']['hash']),64)
        self.assertEqual(v.EXPECTED['install']['files'],53)
        self.assertEqual(v.EXPECTED['uninstall']['files'],5)

if __name__=='__main__': unittest.main()
