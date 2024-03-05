import os
import subprocess

sub_modules = [
    {"ref": "git@github.com:tommanis1/kb-indexer-cloud-backend.git", "dir":"backend"}
	, {"ref":"https://github.com/QCDIS/kb-indexer.git",  "dir": "kb-indexer"}
]

# TODO touch .gitignore if not exists
open('.gitignore', 'a').close()

for module in sub_modules:
    #TODO run git clone module["ref"] module["dir"]
    subprocess.run(["git", "clone", module["ref"], module["dir"]], check=True)
    # TODO add module["dir"] to gitignore if not already in .gitignore 
    with open('.gitignore', 'r+') as gitignore:
        if module["dir"] not in gitignore.read():
            gitignore.write(f"{module['dir']}\n")
