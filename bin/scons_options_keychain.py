#!/usr/bin/env python3
import os
import importlib.machinery
import importlib.util
key = None
try:
    path = os.environ.get('SCONS_OPTIONS')
    loader = importlib.machinery.SourceFileLoader('mymodule', path)
    spec = importlib.util.spec_from_loader('mymodule', loader)
    mymodule = importlib.util.module_from_spec(spec)
    loader.exec_module(mymodule)
    key = mymodule.sign_keychain
except: pass
if key: print(key)
