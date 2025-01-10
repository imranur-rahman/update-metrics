import csv
import os
import json
import logging
import semver
import sys

def get_osv_data_in_dict(ecosystem: str) -> list:
    mylist = []
    with open(f'{ecosystem}.csv', mode='r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            # pkg_name = row["pkg_name"]
            # vul_introduced = row["vul_introduced"]
            # vul_fixed = row["vul_fixed"]
            # TODO: different versions of a package can have vulnerabilities
            # In other words, there can be multiples in the dictionary
            # vul_introduced_dict[str(pkg_name)] = str(vul_introduced)
            # vul_fixed_dict[str(pkg_name)] = str(vul_fixed)
            dict = {'vul_id': row["vul_id"],
                    'package_name': row["pkg_name"],
                    'vul_introduced': row["vul_introduced"],
                    'vul_fixed': row["vul_fixed"],
                    'repo_url': row["repo_url"]}
            mylist.append(dict)

    # Don't need to sort actually
    # vul_introduced_dict = dict(sorted(vul_introduced_dict.items(), key=lambda x:x[0]))
    # vul_fixed_dict = dict(sorted(vul_fixed_dict.items(), key=lambda x:x[0]))

    return mylist

def get_name_version_to_release_time_mapping(ecosystem: str): # tuple(dict, dict, dict)
    mydict = {}
    latest_version_time = {}
    earliest_version_time = {}
    version_sequence = {}
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    for (root,dirs,files) in os.walk(ecosystem_dir, topdown=True):
        for file in files:
            if file.endswith("versions.json"):
                versions_file_path = os.path.join(ecosystem_dir, root, file)
                # logging.debug(f"versions_file_path: {versions_file_path}")

                with open(versions_file_path, 'r', encoding="utf-8") as f:
                    data = json.load(f)
                    package_name = data["package"]["name"]
                    temp_dict = {}
                    latest_version_time[package_name] = -sys.maxsize - 1
                    earliest_version_time[package_name] = sys.maxsize - 1 # range [) TODO: sure?
                    versions = [] # version sequence for this "package_name"
                    for version_obj in data["versions"]:
                        # logging.debug(f"version_obj: {version_obj}")
                        if "version" in version_obj:
                            version = version_obj["version"]
                            versions.append(version)
                        if "version" in version_obj and "createdAt" in version_obj:
                            version = version_obj["version"]
                            creation_time = version_obj["createdAt"]
                            temp_dict[version] = creation_time # it should be int

                            # if "isDefault" in version_obj and version_obj["isDefault"] == True:
                            #     latest_version_time[package_name] = version_obj["createdAt"]
                            if creation_time > latest_version_time[package_name]:
                                latest_version_time[package_name] = creation_time
                            if creation_time < earliest_version_time[package_name]:
                                earliest_version_time[package_name] = creation_time
                    
                    mydict[package_name] = temp_dict
                    version_sequence[package_name] = versions
    
    return mydict, latest_version_time, earliest_version_time, version_sequence

def get_package_to_source_url(ecosystem: str): # tuple(dict, dict, dict)
    mydict = {}
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    for (root,dirs,files) in os.walk(ecosystem_dir, topdown=True):
        for file in files:
            if file.endswith("metadata.json"):
                metadata_file_path = os.path.join(ecosystem_dir, root, file)
                logging.debug(f"metadata_file_path: {metadata_file_path}")

                with open(metadata_file_path, 'r', encoding="utf-8") as f:
                    data = json.load(f)
                    
                    package_name = data["versionKey"]["name"]
                    for link in data["links"]:
                        label = link["label"]
                        url = link["url"]
                        #logging.debug(f"{label} -> {url}")
                        if label == "SOURCE_REPO":
                            logging.debug(f"{package_name} -> {url}")
                            sub = url.find("github.com")
                            url = url[sub:]
                            url = url.rstrip(".git")
                            logging.debug(f"{package_name} (updated) -> {url}")
                            mydict[package_name] = url
                    
    return mydict

def get_file(ecosystem, package_name, version, extension):
    # Assumes everything is quoted
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)
    # if os.path.exists(ecosystem_dir) == False:
    #     os.mkdir(ecosystem_dir)

    package_dir = os.path.join(ecosystem_dir, package_name)
    # if os.path.exists(package_dir) == False:
    #     os.mkdir(package_dir)
    file = os.path.join(package_dir, version + extension)
    
    return file

def get_dependents_list_for_a_version(ecosystem: str, time_mapping: dict, package_name: str,
                                    version: str, latest_version_time_mapping: dict) -> dict:
    dependents_file = get_file(ecosystem=ecosystem, package_name=package_name,
                               version=version, extension="-dependents.json")
    if os.path.exists(dependents_file) == False:
        logging.debug(f"dependents file not found for package: {package_name}, version: {version}")
        return { }
    ret_dict = { }
    with open(dependents_file, 'r', encoding='utf=8') as f:
        data = json.load(f)
        if "directCount" in data and data["directCount"] > 0 and "directSample" in data:
            for dependent in data["directSample"]:
                # #ret_list.append({"package_name": dependent["package"]["name"],
                #                  "version": dependent["version"]})
                ret_dict[dependent["package"]["name"]] = dependent["version"]
    logging.debug(f"dependents list for {package_name}:{version} -> {ret_dict}")
    return ret_dict

def get_time(package_name: str, version: str, time_mapping: dict,
             latest_verison_time_mapping: dict, earliest_version_time_mapping: dict) -> int:
    if version == "0":
        return earliest_version_time_mapping[package_name]
    elif version == "":
        return latest_verison_time_mapping[package_name] + 1 # Sure???
    elif package_name not in time_mapping.keys():
        # We do not have the mapping for this <package_name>
        return 0
    elif version not in time_mapping[package_name]:
        # Assumes the "version" is earlier whatever we have in the "versions.json" file
        return earliest_version_time_mapping[package_name]
    else:
        return time_mapping[package_name][version]

# The range is [version_start, version_end)
def get_dependents_list(ecosystem: str, time_mapping: dict, package_name: str,
                        version_start: str, version_end: str, ascending_order: bool,
                        latest_version_time_mapping: dict, earliest_version_time_mapping: dict) -> dict:
    # Find the appropriate time ranges
    logging.debug(f"get_dependents_list:\n")
    logging.debug(f"package_name: {package_name}, version_start: {version_start}, version_end: {version_end}")

    time_range_start = get_time(package_name=package_name,
                                version=version_start,
                                time_mapping=time_mapping,
                                latest_verison_time_mapping=latest_version_time_mapping,
                                earliest_version_time_mapping=earliest_version_time_mapping)
    
    time_range_end =  get_time(package_name=package_name,
                                version=version_end,
                                time_mapping=time_mapping,
                                latest_verison_time_mapping=latest_version_time_mapping,
                                earliest_version_time_mapping=earliest_version_time_mapping)
    logging.debug(f"time_range_start: {time_range_start}, time_range_end: {time_range_end}")

    # Read the dependents for <package_name>
    # TODO: This part can be optimized with checking entry in the "version_sequence"
    versions_file = get_file(ecosystem=ecosystem, package_name=package_name,
                             version="", extension="versions.json")
    if os.path.exists(versions_file) == False:
        # Error, the file should be here.
        logging.debug(f"Error: the versions file should be present.")
        return { }
    
    dependent_dict = { }
    # Find all versions of vulnerable <package_name> and their dependents
    with open(versions_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        # Doing this to make sure we are updating the list appropriately
        for version_obj in data["versions"] if ascending_order == False else reversed(data["versions"]):
            if "dependentCount" in version_obj and version_obj["dependentCount"] > 0\
                and "createdAt" in version_obj and version_obj["createdAt"] >= time_range_start\
                and version_obj["createdAt"] < time_range_end:

                temp_dict = get_dependents_list_for_a_version(
                                ecosystem=ecosystem,
                                time_mapping=time_mapping,
                                package_name=package_name,
                                version=version_obj["version"],
                                latest_version_time_mapping=latest_version_time_mapping)
                
                dependent_dict.update(temp_dict)
    logging.debug(f"final dependent list for {package_name}:[{version_start}, {version_end} -> ")
    logging.debug(f"{dependent_dict}")
    return dependent_dict

def get_vul_dependents_list_updated(ecosystem: str, time_mapping: dict, package_name: str,
                        version_start: str, version_end: str, ascending_order: bool,
                        latest_version_time_mapping: dict, earliest_version_time_mapping: dict,
                        version_sequence: dict) -> dict:
    # Find the appropriate time ranges
    logging.debug(f"get_dependents_list:\n")
    logging.debug(f"package_name: {package_name}, version_start: {version_start}, version_end: {version_end}")

    logging.debug(f"all versions: {version_sequence[package_name]}")

    # Read the dependents for <package_name>
    # TODO: This part can be optimized with checking entry in the "version_sequence"
    versions_file = get_file(ecosystem=ecosystem, package_name=package_name,
                             version="", extension="versions.json")
    if os.path.exists(versions_file) == False:
        # Error, the file should be here.
        logging.debug(f"Error: the versions file should be present.")
        return { }
    
    dependent_dict = { }

    # Sanitization
    if version_start == "0" and ascending_order == True:
        # The first version of this package is last in the list.
        version_start = version_sequence[package_name][-1]
    try:
        semver.parse(version_start)
        semver.parse(version_end)
    except ValueError:
        logging.error(f"Could not parse version_start: {version_start} or version_end: {version_end}")
        return { }
    
    # Find all versions of vulnerable <package_name> and their dependents
    with open(versions_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

        # Doing this to make sure we are updating the list appropriately
        in_version_range = False
        for version_obj in reversed(data["versions"]):
            try:
                semver.parse(version_obj["version"])
            except ValueError:
                this_version = version_obj["version"]
                logging.error(f"Could not parse version: {this_version}")
                continue
            if semver.compare(version_obj["version"], version_start) >= 0:
                in_version_range = True
            if semver.compare(version_obj["version"], version_end) >= 0:
                in_version_range = False
                break
            if in_version_range and "dependentCount" in version_obj and version_obj["dependentCount"]:

                temp_dict = get_dependents_list_for_a_version(
                                ecosystem=ecosystem,
                                time_mapping=time_mapping,
                                package_name=package_name,
                                version=version_obj["version"],
                                latest_version_time_mapping=latest_version_time_mapping)
                
                dependent_dict.update(temp_dict)
    logging.debug(f"final dependent list for {package_name}:[{version_start}, {version_end} -> ")
    logging.debug(f"{dependent_dict}")
    return dependent_dict

def get_fixed_dependents_list_updated(ecosystem: str, time_mapping: dict, package_name: str,
                        version_start: str, version_end: str, ascending_order: bool,
                        latest_version_time_mapping: dict, earliest_version_time_mapping: dict,
                        version_sequence: dict) -> dict:
    # Find the appropriate time ranges
    logging.debug(f"get_dependents_list:\n")
    logging.debug(f"package_name: {package_name}, version_start: {version_start}, version_end: {version_end}")

    logging.debug(f"all versions: {version_sequence[package_name]}")

    # Read the dependents for <package_name>
    # TODO: This part can be optimized with checking entry in the "version_sequence"
    versions_file = get_file(ecosystem=ecosystem, package_name=package_name,
                             version="", extension="versions.json")
    if os.path.exists(versions_file) == False:
        # Error, the file should be here.
        logging.debug(f"Error: the versions file should be present.")
        return { }
    
    dependent_dict = { }

    # Sanitization
    try:
        semver.parse(version_start)
    except ValueError:
        logging.error(f"Could not parse version_start: {version_start}")
        return { }
    
    # Find all versions of vulnerable <package_name> and their dependents
    with open(versions_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
        # Doing this to make sure we are updating the list appropriately
        in_version_range = True
        # Not reversing the list this time, because we need the first occurence when a dependent
        # moved to the fixed version a package
        for version_obj in data["versions"]:
            try:
                semver.parse(version_obj["version"])
            except ValueError:
                this_version = version_obj["version"]
                logging.error(f"Could not parse version: {this_version}")
                continue
            # Added the dependent version till "version_start", exit now
            if semver.compare(version_obj["version"], version_start) < 0:
                in_version_range = False
            if in_version_range and "dependentCount" in version_obj and version_obj["dependentCount"]:

                temp_dict = get_dependents_list_for_a_version(
                                ecosystem=ecosystem,
                                time_mapping=time_mapping,
                                package_name=package_name,
                                version=version_obj["version"],
                                latest_version_time_mapping=latest_version_time_mapping)
                
                dependent_dict.update(temp_dict)
            
    logging.debug(f"final dependent list for {package_name}:[{version_start}, {version_end} -> ")
    logging.debug(f"{dependent_dict}")
    return dependent_dict

def get_child_parent_relation_graph(ecosystem) -> dict:
    # The "relations" dict contains (child_package_name, parent_package_name) as keys and
    #       a list of (child_package_version, parent_package_version) as value.
    relations = { }
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    for (root,dirs,files) in os.walk(ecosystem_dir, topdown=True):
        for file in files:
            if file.endswith("dependents.json"):
                versions_file_path = os.path.join(ecosystem_dir, root, file)
                # logging.debug(f"versions_file_path: {versions_file_path}")

                with open(versions_file_path, 'r', encoding="utf-8") as f:
                    data = json.load(f)
                    child_package_name = data["package"]["name"]
                    child_package_version = data["version"]

                    for direct_dependents in data["directSample"]:
                        parent_package_name = direct_dependents["package"]["name"]
                        parent_package_version = direct_dependents["version"]

                        if (child_package_name, parent_package_name) not in relations.keys():
                            relations[(child_package_name, parent_package_name)] = [ ]
                        
                        relations[(child_package_name, parent_package_name)].append(
                            (child_package_version, parent_package_version)
                        )
    return relations

def write_csv_header(filename, header_list):
    csv_file = open(f"{filename}.csv", "w")
    csv_header = header_list
    csv_writer = csv.DictWriter(csv_file, fieldnames=csv_header)
    csv_writer.writeheader()
    return csv_writer

def write_csv_header_append_mode(filename, header_list):
    file_exists = False
    if os.path.exists(f"{filename}.csv"):
        file_exists = True
    csv_file = open(f"{filename}.csv", "a")
    csv_header = header_list
    csv_writer = csv.DictWriter(csv_file, fieldnames=csv_header)
    if file_exists == False:
        csv_writer.writeheader()
    return csv_writer