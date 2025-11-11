##### To initialized the repo
```
uv init .
```

##### To add a new package, e.g. pytest
```
uv add pytest
```

##### To list all the install package
uv pip list

```
❯ uv pip list
Package           Version
----------------- -------
exceptiongroup    1.3.0
iniconfig         2.1.0
packaging         25.0
pluggy            1.6.0
pygments          2.19.2
pytest            8.4.2
tomli             2.2.1
typing-extensions 4.15.0
```

##### To activate the new installed pacage
```
source .venv/bin/activate
```
##### Generate a requirements.txt file with exact versions of installed packages (like pip freeze but faster).
```
uv pip freeze > requirements.txt
```

##### Create a new virtual environment
```
uv venv myenv
```

##### Activate the environment (Linux/macOS):
```
source myenv/bin/activate 
```

##### Uninstall a package
```
uv pip uninstall numpy
```

##### Upgrade a single package
```
uv pip install --upgrade requests
```

##### Upgrade all packages in the environment
```
uv pip upgrade --all
```
##### Change to use internal PyPI mirror
```
uv pip install akshare --index-url https://mirrors.aliyun.com/pypi/simple/
```
