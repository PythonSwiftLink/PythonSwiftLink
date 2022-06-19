//
//  GeneratePythonCert.swift
//  KivySwiftLink
//


import Foundation


let cert_script = """
# install_certifi.py
#
# sample script to install or update a set of default Root Certificates
# for the ssl module.  Uses the certificates provided by the certifi package:
#       https://pypi.python.org/pypi/certifi

import os
import os.path
import ssl
import stat
import subprocess
import sys

STAT_0o775 = ( stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR
             | stat.S_IRGRP | stat.S_IWGRP | stat.S_IXGRP
             | stat.S_IROTH |                stat.S_IXOTH )


def main():
    openssl_dir, openssl_cafile = os.path.split(
        ssl.get_default_verify_paths().openssl_cafile)

    print(" -- pip install --upgrade certifi")
    subprocess.check_call([sys.executable,
        "-E", "-s", "-m", "pip", "install", "--upgrade", "certifi"])

    import certifi

    # change working directory to the default SSL directory
    os.chdir(openssl_dir)
    relpath_to_certifi_cafile = os.path.relpath(certifi.where())
    print(" -- removing any existing file or link")
    try:
        os.remove(openssl_cafile)
    except FileNotFoundError:
        pass
    print(" -- creating symlink to certifi certificate bundle")
    os.symlink(relpath_to_certifi_cafile, openssl_cafile)
    print(" -- setting permissions")
    os.chmod(openssl_cafile, STAT_0o775)
    print(" -- update complete")

if __name__ == '__main__':
    main()
"""

@discardableResult
func InstallPythonCert(target_folder: InternalPythons) -> Int32 {
    let task = Process()
    let targs = ["-c", cert_script]
    let paths = KSLPaths.shared
    switch target_folder {
    case .host:
        //task.launchPath = HOSTPYTHON.appendingPathComponent("bin/python3.10").path
        task.executableURL = paths.HOSTPYTHON_APP_EXE
        print("Installing cert on: \(paths.HOSTPYTHON_APP_EXE.path)")
    case .venv:
        //task.launchPath = VENVPYTHON.appendingPathComponent("bin/python3.9").path
        task.executableURL = paths.VENVPYTHON_APP_EXE
        print("Installing cert on: \(paths.VENVPYTHON_APP_EXE.path)")
    }
    
    task.arguments = targs

    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
