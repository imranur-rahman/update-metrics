import csv
import json
import logging
import os
import requests
from urllib.parse import quote
import deps

__DEPSDEVAPIVERSIONINFO__ = "https://api.deps.dev/v3alpha/systems/{ecosystem}/packages/{package}/versions/{version}"
__DEPSDEVAPIDEPENDENCIESINFO__ = "https://api.deps.dev/v3alpha/systems/{ecosystem}/packages/{package}/versions/{version}:dependencies"
__DEPSDEVAPIALLVERSIONINFO__ = "https://api.deps.dev/v3alpha/systems/{ecosystem}/packages/{package}"

def get_all_versions_from_depsdev(ecosystem, package):
    logging.debug(f"func: get_all_versions, package: {package} -> start")
    quoted_package = quote(package, safe='')
    url = __DEPSDEVAPIALLVERSIONINFO__.format(ecosystem=ecosystem,
                                package=quoted_package)
    logging.debug(f"url: {url}")

    versions_file = deps.get_file(ecosystem=ecosystem,
                                  package_name=quoted_package,
                                  version="",
                                  extension="versions.json")
    logging.debug(f"versions_file: {versions_file}")

    # Reducing the number of http call
    if os.path.exists(versions_file):
        logging.debug(f"Versions file already exists.\n\n\n")
        return

    # Make the request.
    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        data = json.loads(resp.content)

        with open(versions_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
            logging.debug(f"wrote all versions: {package}")
    
    logging.debug(f"func: get_all_versions, package: {package} -> end")

def get_version_metadata_from_depsdev(ecosystem, package, version):
    logging.debug(f"func: get_version_metadata, package: {package}, version: {version} -> start")
    quoted_package = quote(package, safe='')
    url = __DEPSDEVAPIVERSIONINFO__.format(ecosystem=ecosystem,
                                package=quoted_package,
                                version=version)
    logging.debug(f"url: {url}")

    # # Directories.
    # deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    # ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    # package = quote(package, safe='')
    # package_dir = os.path.join(ecosystem_dir, package)
    # metadata_file = os.path.join(package_dir, package + "-metadata.json")
    metadata_file = deps.get_file(ecosystem=ecosystem,
                                  package_name=quoted_package,
                                  version=version,
                                  extension="-metadata.json")
    logging.debug(f"metadata_file: {metadata_file}")

    # Reducing the number of http call
    if os.path.exists(metadata_file):
        logging.debug(f"Metadata already exists.\n\n\n")
        return

    # Make the request.
    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        data = json.loads(resp.content)

        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
            logging.debug(f"wrote metadata: {package} -> {version}")

    logging.debug(f"func: get_version_metadata, package: {package}, version: {version} -> end")

def read_csv(ecosystem):
    mydict = { }
    with open(f'{ecosystem}.csv', mode='r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            pkg_name = row["pkg_name"]
            vul_introduced = row["vul_introduced"]
            vul_fixed = row["vul_fixed"]
            mydict[str(pkg_name)] = str(vul_fixed)
    
    mydict = dict(sorted(mydict.items(), key=lambda x:x[0]))
    
    return mydict

def get_dependencies_from_depsdev(ecosystem, package_name, version):
    logging.debug(f"func: get_dependencies_from_depsdev, pkg: {package_name}, version: {version} -> start")

    quoted_package_name = quote(package_name, safe='')
    logging.debug(f"func: get_dependencies_from_depsdev, pkg: {quoted_package_name}, version: {version} -> start")
    url = __DEPSDEVAPIDEPENDENCIESINFO__.format(ecosystem=ecosystem, package=quoted_package_name, version=version)
    logging.debug(f"url: {url}")

    dependencies_info_file = deps.get_file(ecosystem=ecosystem, package_name=quoted_package_name,
                                      version=version, extension="-dependencies.json")
    
    get_all_versions_from_depsdev(ecosystem=ecosystem, package=package_name)
    
    if os.path.exists(dependencies_info_file):
        logging.debug(f"Already gathered this packages dependencies!")
        return
    
    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        with open(dependencies_info_file, 'w', encoding='utf-8') as f:
            data = json.loads(resp.content)
            json.dump(data, f, ensure_ascii=False, indent=4)
            logging.debug(f"wrote dependencies: {package_name} -> {version}")
            print(f"Wrote dependencies: {package_name} -> {version}")
    else:
        logging.debug(f"{package_name} -> {version}")
        logging.debug(f"return code: {resp.status_code}")
        None

    logging.debug(f"func: get_dependencies_from_depsdev, pkg: {package_name}, version: {version} -> end")
    logging.debug(f"func: get_dependencies_from_depsdev, pkg: {quoted_package_name}, version: {version} -> end")

def func(ecosystem, mydict):
    loop_cnt = 0
    for pkg_name, version in mydict.items():
        print (pkg_name, '->', version)
        get_version_metadata_from_depsdev(ecosystem=ecosystem, package=pkg_name, version=version)
        # loop_cnt += 1
        # if (loop_cnt > 5):
        #     break

def main(ecosystem):
    mydict = read_csv(ecosystem=ecosystem)
    func(ecosystem=ecosystem, mydict=mydict)

if __name__ == "__main__":
    main("npm")