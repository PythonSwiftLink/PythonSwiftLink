
def get_package_swift() -> str:
    text = ""
    with open("Package.swift", "r") as rf:
        text = rf.read()
    return text

with open("Package.swift", "w") as f:
    old = "PythonSwiftLink/PythonCore"
    new = "KivySwiftLink/PythonCore"
    package_text = get_package_swift().replace(old, new)
    f.write(package_text)
    

