
def get_package_swift() -> str:
    text = ""
    with open("Package.swift", "r") as rf:
        text = rf.read()
    return text

with open("Package.swift", "r") as f:
    old = "PythonSwiftLink/PythonCore"
    new = "KivySwiftLink/PythonCore"
    package_text = get_package_swift().replace()
    f.write(package_text)
    

