import csv
import json
import logging
import os
import requests
from shutil import rmtree
from urllib.parse import quote, unquote
import new_deps_api

__DEPSDEVAPIDEPENDENCIESURL = "https://deps.dev/_/s/{ecosystem}/p/{package}/v/{version}/dependencies"
__DEPSDEVAPIDEPENDENTSURL = "https://deps.dev/_/s/{ecosystem}/p/{package}/v/{version}/dependents"
__DEPSDEVAPIVERSIONSURL = "https://deps.dev/_/s/{ecosystem}/p/{package}/versions"
__DEPSDEVADVISORYURL = "https://deps.dev/_/advisory/{source}/{source_id}"
__SEVERITY_DICT = {
    "UNKNOWN": 1,
    "NONE": 1,
    "LOW": 3,
    "MEDIUM": 5,
    "HIGH": 7,
    "CRITICAL": 10,
}

count = 0
should_start = False

def get_osv_data_in_sorted_dict(ecosystem):
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

def get_all_versions(ecosystem):
    mydict = get_osv_data_in_sorted_dict(ecosystem=ecosystem)

    for pkg_name, version in mydict.items():
        logging.debug(f"collecting all versions data: {pkg_name}")
        # new_deps_api.get_all_versions_from_depsdev(ecosystem=ecosystem, package=pkg_name)
        get_all_versions_from_depsdev(ecosystem=ecosystem, package_name=pkg_name)

def get_all_versions_from_depsdev(ecosystem, package_name):
    logging.debug(f"func: get_all_versions_from_depsdev, pkg: {package_name} -> start")

    quoted_package_name = quote(package_name, safe='')
    url = __DEPSDEVAPIVERSIONSURL.format(ecosystem=ecosystem, package=quoted_package_name)

    versions_file = get_file(ecosystem=ecosystem,
                            package_name=quoted_package_name,
                            version="",
                            extension="versions.json")
    # Reducing the number of http call
    if os.path.exists(versions_file):
        logging.debug(f"Versions file already exists.")
        with open(versions_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            logging.debug(f"the data: {data}")
        return

    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        with open(versions_file, 'w', encoding='utf-8') as f:
            data = json.loads(resp.content)
            json.dump(data, f, ensure_ascii=False, indent=4)
    else:
        logging.debug(f"{package_name}")
        logging.debug(f"return code: {resp.status_code}")
        None
    logging.debug(f"func: get_all_versions_from_depsdev, pkg: {package_name} -> end")

def get_file(ecosystem, package_name, version, extension):
    # Assumes everything is quoted
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)
    if os.path.exists(ecosystem_dir) == False:
        os.mkdir(ecosystem_dir)

    package_dir = os.path.join(ecosystem_dir, package_name)
    if os.path.exists(package_dir) == False:
        os.mkdir(package_dir)
    dependency_info_file = os.path.join(package_dir, version + extension)
    
    return dependency_info_file

def get_dependents(ecosystem):
    # Reading version info files to get all version number for each package.
    mydict = get_osv_data_in_sorted_dict(ecosystem=ecosystem)

    # Iterating through the dictionary.
    for package_name, version_obsolete in mydict.items():
        get_dependents_for_package(ecosystem=ecosystem, package_name=package_name)


def get_dependents_for_package(ecosystem, package_name):
    quoted_package_name = quote(package_name, safe='')
    versions_file = get_file(ecosystem=ecosystem,
                            package_name=quoted_package_name,
                            version="",
                            extension="versions.json")
    
    logging.debug(f"func: get_dependents_for_package, pkg: {package_name} -> start")

    logging.debug(f"versions_file: {versions_file}")

    global count
    count = 0
    with open(versions_file, 'r', encoding="utf-8") as f:
        data = json.load(f)
        for version_obj in data["versions"]:
            # TODO: Only doing the HTTP request when it is necessary. But if there is not rate limit, we can probably just remove it.
            # if "dependentCount" in version_obj and version_obj["dependentCount"] > 0:
            get_dependents_from_depsdev(ecosystem=ecosystem, package_name=package_name, version=version_obj["version"])

            if "isDefault" in version_obj and version_obj["isDefault"] == True:
                new_deps_api.get_version_metadata_from_depsdev(ecosystem=ecosystem, package=package_name, version=version_obj["version"])

            count += 1
    
    logging.debug(f"count: {count}")
    logging.debug(f"func: get_dependents_for_package, pkg: {package_name} -> end")

def get_dependents_from_depsdev(ecosystem, package_name, version):
    logging.debug(f"func: get_dependents_from_depsdev, pkg: {package_name}, version: {version} -> start")

    quoted_package_name = quote(package_name, safe='')

    # # Placeholder
    # global should_start
    # if package_name == "%40chainsafe%2Flibp2p-noise" and version == "6.4.0-alpha.25":
    #     should_start = True
    # if should_start == False:
    #     return
    
    url = __DEPSDEVAPIDEPENDENTSURL.format(ecosystem=ecosystem, package=quoted_package_name, version=version)
    logging.debug(f"url: {url}")

    dependents_info_file = get_file(ecosystem=ecosystem, package_name=quoted_package_name,
                                    version=version, extension="-dependents.json")

    # For our case, we don't need this
    # new_deps_api.get_dependencies_from_depsdev(ecosystem=ecosystem, package_name=package_name,
    #                                   version=version)
    # get_all_versions_from_depsdev(ecosystem=ecosystem, package_name=package_name)
    
    # New placeholder
    if os.path.exists(dependents_info_file):
        logging.debug(f"Gathering dependencies.")
        logging.debug(f"Dependency extraction complete. \n\n\n")
        return

    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        with open(dependents_info_file, 'w', encoding='utf-8') as f:
            data = json.loads(resp.content)
            json.dump(data, f, ensure_ascii=False, indent=4)
            logging.debug(f"wrote dependents: {quoted_package_name} -> {version}")
    else:
        logging.debug(f"{quoted_package_name} -> {version}")
        logging.debug(f"return code: {resp.status_code}")
        None
    
    logging.debug(f"func: get_dependents_from_depsdev, pkg: {package_name}, version: {version} -> end")
    logging.debug(f"func: get_dependents_from_depsdev, pkg: {quoted_package_name}, version: {version} -> end")
    logging.debug("\n\n\n")

def get_all_versions_of_dependents(ecosystem):
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    dependents_list = []

    for (root,dirs,files) in os.walk(ecosystem_dir, topdown=True):
        for file in files:
            if file.endswith("dependents.json"):
                dependents_file = os.path.join(ecosystem_dir, root, file)
                # logging.debug(f"dependents_file for getting all versions: {root}/{file} -> start")
                with open(dependents_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if data["directCount"] > 0:
                        for dependent in data["directSample"]:
                            system = dependent["package"]["system"]
                            package_name = dependent["package"]["name"]
                            dependents_list.append(package_name)
                            
                # logging.debug(f"dependents_file for getting all versions: {root}/{file} -> end")

    dependents_list = sorted(set(dependents_list))
    logging.debug(f"number of unique dependents: {len(dependents_list)}")
    count = 0
    for package_name in dependents_list:
        count += 1
        logging.debug(f"getting all dependents for: {package_name}, count: {count}")
        get_all_versions_from_depsdev(ecosystem=ecosystem,
                                    package_name=package_name)


def get_vulns_from_depsdev(ecosystem, package_name, version):
    result = []

    package_name = quote(package_name, safe='')
    url = __DEPSDEVAPIDEPENDENCIESURL.format(ecosystem=ecosystem, package=package_name, version=version)

    resp = requests.get(url, timeout=6)
    if resp.status_code == 200:
        data = json.loads(resp.content)
        if "dependencies" in data.keys():
            for pack in data['dependencies']:
                if len(pack['advisories']) > 0:
                    for advisory in pack['advisories']:
                        vul = {"vuln_id": advisory["sourceID"], "title": advisory["title"],
                               "severity": __SEVERITY_DICT[advisory["severity"]],
                               "description": advisory["description"]}

                        if "CVEs" in advisory and advisory["CVEs"]:
                            cves = [cve for cve in advisory["CVEs"]]
                            vul["cves"] = json.dumps(cves)
                        vul["reference"] = advisory["sourceURL"]
                        # 获取全部影响版本
                        source = advisory["source"]
                        affected_versions = __get_affected_versions(package_name, source, vul["vuln_id"])
                        vul["affected_versions"] = affected_versions

                        result.append(vul)
    return result


def __get_affected_versions(package_name, source, source_id):
    result = []

    url = __DEPSDEVADVISORYURL.format(source=source, source_id=source_id)
    resp = requests.get(url)
    if resp.status_code == 200:
        data = json.loads(resp.content)

        for pkg in data["packages"]:
            if pkg["package"]["name"] != package_name:
                continue

            if len(pkg["versionsAffected"]) > 0:
                for version in pkg["versionsAffected"]:
                    result.append(version["version"])
    return result