import hashlib
import unittest

from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import sync_release_sources as source


class TestReleaseValidation(unittest.TestCase):
    def test_sha256_reference(self):
        self.assertEqual(source.sha(b"abc"), hashlib.sha256(b"abc").hexdigest())
        self.assertEqual(source.sha(b"abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")

    def test_pinned_release_assets(self):
        self.assertEqual(len(source.ASSETS), 3)
        self.assertEqual(
            {x[0] for x in source.ASSETS.values()},
            {"autoABC-1.1.0-CHECKONLY.zip", "autoABC-1.1.0-install.zip", "autoABC-1.1.0-uninstall.zip"},
        )
        for filename, digest in source.ASSETS.values():
            self.assertTrue(filename.endswith(".zip"))
            self.assertEqual(len(digest), 64)
            bytes.fromhex(digest)

    def test_guard_rejects_false(self):
        with self.assertRaises(ValueError):
            source.check(False, "deliberate test mismatch")

    def test_release_config_marker(self):
        self.assertIn("CHECKONLY", source.ASSETS)
        self.assertIn("install", source.ASSETS)
        self.assertIn("uninstall", source.ASSETS)


if __name__ == "__main__":
    unittest.main()
