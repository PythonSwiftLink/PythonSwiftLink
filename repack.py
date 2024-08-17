package_path = "PythonSwiftLink/Package.swift"
def get_package_swift() -> str:
    text = ""
    with open(package_path, "r") as rf:
        text = rf.read()
    return text


with open(package_path, "w") as f:
    old = "PythonSwiftLink/PythonCore"
    new = "KivySwiftLink/PythonCore"
    package_text = get_package_swift().replace(old, new)
    f.write(package_text)
    

