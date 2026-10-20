#!/usr/bin/env python3
"""Offline verification of the TWO README-free autoABC 1.0.0 release archives.

Does not execute any OPPO code or alter either input ZIP.
Not a proof of hardware compatibility or source-to-binary reproducibility.
"""
from __future__ import annotations
import hashlib
import pathlib
import sys
import zipfile

EXPECTED = {
 'install': {'hash': '2f57b16aa8b779265c5fe9561cf2a9c1b535837fad2c7fd5cb07109264cafe44', 'files': 52, 'manifest': 50},
 'uninstall': {'hash': 'aa15f85d37eac272fbffad3d27800c1efc220657cda794876e25b827836c7862', 'files': 4, 'manifest': 3},
}

def hash_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)

def assert_safe_member(name: str) -> None:
    p = pathlib.PurePosixPath(name)
    require(not name.startswith('/'), 'absolute ZIP path: '+name)
    require('\\' not in name, 'backslash ZIP path: '+name)
    require(all(x not in ('', '.', '..') for x in p.parts), 'unsafe ZIP path: '+name)
    require(not name.startswith('__MACOSX/') and not any(x.startswith('._') or x=='.DS_Store' for x in p.parts), 'macOS metadata in ZIP: '+name)

def verify_manifest(z: zipfile.ZipFile, file_name: str, count: int) -> None:
    pairs=[]
    for line in z.read(file_name).decode('ascii').splitlines():
        if not line.strip():
            continue
        require(len(line)>66 and line[64:66]=='  ', 'bad hash manifest line in '+file_name)
        expected,name=line[:64],line[66:]
        require(len(expected)==64 and all(x in '0123456789abcdef' for x in expected), 'bad SHA256: '+name)
        require(name in z.namelist(), 'manifest target missing: '+name)
        require(hash_bytes(z.read(name))==expected, 'manifest file mismatch: '+name)
        pairs.append(name)
    require(len(pairs)==count, f'{file_name}: expected {count} manifest entries, got {len(pairs)}')
    require(len(set(pairs))==len(pairs), 'duplicate manifest paths')
    print(f'  {file_name}: {count}/{count} SHA256 OK')

def verify_one(p: pathlib.Path, kind: str, repo: pathlib.Path|None=None) -> None:
    expected=EXPECTED[kind]
    require(p.is_file(), 'file not found: '+str(p))
    data=p.read_bytes()
    require(hash_bytes(data)==expected['hash'], 'outer ZIP SHA256 is not the nominated final '+kind+' archive')
    with zipfile.ZipFile(p) as z:
        names=z.namelist()
        require(len(names)==expected['files'], 'unexpected ZIP entry count')
        require('README.md' not in names, 'unexpected README bundled into release archive')
        require(len(names)==len(set(names)), 'duplicate ZIP entry names')
        for i in z.infolist():
            assert_safe_member(i.filename)
            # Reject symlinks (ZIP mode bits) in user-facing release archives.
            mode=(i.external_attr>>16)&0o170000
            require(mode!=0o120000, 'symlink in ZIP: '+i.filename)
        require(z.testzip() is None, 'ZIP CRC failure')
        print(f'  {kind} archive SHA256, ZIP count {len(names)} and CRC OK')
        verify_manifest(z,'SHA256SUMS_RELEASE',expected['manifest'])
        manifest_names={line[66:] for line in z.read('SHA256SUMS_RELEASE').decode('ascii').splitlines()}
        unpinned={'SHA256SUMS_RELEASE'} | ({'AutoScript/config.ini'} if kind=='install' else set())
        require(manifest_names==set(names)-unpinned, 'release manifest does not cover all non-editable archive members')
        tss=z.read('AutoScript/AutoScript.TSS')
        require(tss.startswith(b'#MTKAT'), 'missing MTKAT script marker')
        require(b'\r\n' in tss and tss.replace(b'\r\n',b'').find(b'\n')==-1, 'AutoScript.TSS has non-CRLF line endings')
        if kind=='install':
            nested='AutoScript/autoABC/SHA256SUMS'
            require(hash_bytes(z.read(nested))=='bdf2606dcfa93eefd181f0cc7a2310322352825f95f33980c970cadcd9873d7b','nested manifest identity mismatch')
            # Inner names are relative to installed base, unlike ZIP root names.
            source=z.read(nested).decode('ascii').splitlines()
            require(len(source)==44, 'expected 44 pinned runtime files')
            for line in source:
                h,name=line[:64],line[66:]
                require(line[64:66]=='  ', 'bad nested manifest line')
                target='AutoScript/autoABC/'+name
                require(target in names and hash_bytes(z.read(target))==h, 'bad nested hash: '+target)
            runtime_files=[n for n in names if n.startswith('AutoScript/autoABC/') and n!='AutoScript/autoABC/SHA256SUMS']
            require(len(runtime_files)==44, 'expected 44 files under runtime prefix excluding manifest')
            require(z.read('AutoScript/config.ini')==b'ISO_BDMV=1\n','unexpected installer default config')
            require('AutoScript/config.ini' not in z.read('SHA256SUMS_RELEASE').decode('ascii'),'user-editable config incorrectly pinned')
            require(b'CACHE=' not in z.read('AutoScript/config.ini'), 'unexpected cache option')
            print('  44 runtime manifest entries OK; editable ISO_BDMV=1 config OK')
            if repo:
                mapping={
                  'AutoScript/autoABC-install.sh':'installer/install/autoABC-install.sh',
                  'AutoScript/AutoScript.TSS':'installer/install/AutoScript.TSS',
                  'AutoScript/config.ini':'installer/install/config.ini',
                  'CHECK_READONLY.sh':'installer/read-only/CHECK_READONLY.sh',
                  'UNINSTALL.sh':'installer/read-only/UNINSTALL.sh',
                }
                for name in names:
                    if name.startswith('AutoScript/autoABC/') and name.rsplit('/',1)[-1] not in ('autoabc_detect','autoabc_hdmv','autoabc_bdj','autoabc_folder','SHA256SUMS') and not name.startswith('AutoScript/autoABC/hook/'):
                        mapping[name]='src/runtime/'+name.rsplit('/',1)[-1]
                for zip_member,repo_file in mapping.items():
                    if not (repo/repo_file).is_file(): continue
                    require((repo/repo_file).read_bytes()==z.read(zip_member), 'public source snapshot mismatch: '+repo_file)
                print('  source shell references match sealed ZIP')
        else:
            require('AutoScript/autoABC-uninstall.sh' in names,'uninstaller boot script missing')
            require('AutoScript/autoABC-uninstall.id' in names,'uninstaller release id missing')
            require('AutoScript/config.ini' not in names,'unexpected config in uninstaller')
            if repo:
                for zp,rp in [('AutoScript/autoABC-uninstall.sh','installer/uninstall/autoABC-uninstall.sh'),('AutoScript/AutoScript.TSS','installer/uninstall/AutoScript.TSS')]:
                    require((repo/rp).read_bytes()==z.read(zp), 'uninstall source mismatch: '+rp)
                print('  uninstall source snapshots match sealed ZIP')

def main() -> int:
    if len(sys.argv)!=3:
        print('Usage: python3 tools/verify_release.py INSTALL_ZIP UNINSTALL_ZIP',file=sys.stderr)
        return 2
    repo=pathlib.Path(__file__).resolve().parent.parent
    try:
        for kind,arg in zip(('install','uninstall'),sys.argv[1:]):
            print('autoABC 1.0.0:',kind)
            verify_one(pathlib.Path(arg),kind,repo)
    except (ValueError, OSError, zipfile.BadZipFile, KeyError, UnicodeError) as exc:
        print('VERIFICATION FAILED:',exc,file=sys.stderr)
        return 1
    print('OFFLINE_VERIFICATION=PASS (NOT a live hardware acceptance test)')
    return 0

if __name__=='__main__':
    sys.exit(main())
