from osv import OSV
import new_deps_api
import os
import utils
import logging

os.remove("./pop.log") if os.path.exists("./logmttu.log") else None
logging.basicConfig(filename='pop.log', encoding='utf-8', level=logging.DEBUG)

def main():
    mydict = find_source_repo()
    # for key in mydict.keys():
    #     print (f"{key} -> {mydict[key]}")
    

def find_source_repo():
    return utils.get_package_to_source_url("npm")

if __name__ == "__main__":
    main()