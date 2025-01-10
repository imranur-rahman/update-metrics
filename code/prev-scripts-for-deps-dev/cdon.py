import csv
import datetime
import json
import logging
import numpy as np
import os
import sys

import utils
import deps

os.remove("./logcdon.log") if os.path.exists("./logcdon.log") else None
logging.basicConfig(filename='logcdon.log', encoding='utf-8', level=logging.DEBUG)

NORMALISATION_DELTA = datetime.timedelta(days=365)

def calculate_cdon_data_points(ecosystem) -> dict:
    # CDO/N data point container
    cdon_data_points = { }

    # Open the combined csv for writing
    combined_writer = utils.write_csv_header_append_mode(filename="combined",
                                        header_list=[
                                            "Vul_id",
                                            "Parent",
                                            "P_Vr",
                                            "P_Vr_R (X)",
                                            "Dependency",
                                            "D_Vr",
                                            "D_Vr_R (Y)",
                                            "TTU (X - Y)",
                                            "CDO",
                                            "D_Vulnerable_Vr",
                                            "D_V_Vr_R",
                                            "D_Fixed_Vr",
                                            "D_F_Vr_R (Z)",
                                            "TTR (X - Z)",
                                            "repo_url"      
                                        ])

    # Open the csv file for writing
    csv_writer = utils.write_csv_header(filename="data_cdon",
                                        header_list=[
                                            "vul_id",
                                            "package_name",
                                            "vul_introduced",
                                            "vul_fixed",
                                            "fix_version_release_time",
                                            "dependent_package_name",
                                            "dependent_package_version",
                                            "dependent_package_release_time",
                                            "CDO/N",
                                            "repo_url"
                                        ])

    # From the osv dataset gather <pkg_name, vul_introduced, vul_fixed> (basically from csv)
    vul_data_list = utils.get_osv_data_in_dict(ecosystem=ecosystem)
    # Need to print the data to check

    # Find the <package_name, version> to <createdAt> mapping
    time_mapping, latest_verison_time_mapping, earliest_version_time_mapping, version_sequence =\
                  utils.get_name_version_to_release_time_mapping(ecosystem=ecosystem)

    count = 0
    for vul_data_point in vul_data_list:
        vul_id = vul_data_point["vul_id"]
        package_name = vul_data_point["package_name"]
        vul_introduced = vul_data_point["vul_introduced"]
        vul_fixed = vul_data_point["vul_fixed"]
        repo_url = vul_data_point["repo_url"]
        logging.debug(f"vul_info: \n vul_id: {vul_id}, package_name: {package_name}, \
                      \nvul_introduced: {vul_introduced}, vul_fixed: {vul_fixed}, \
                      \nrepo_url: {repo_url}")
        
        # For each <pkg_name> find when this <vul_fixed> version was released -> (T1)
        if package_name not in time_mapping:
            logging.debug(f"versions.json is not found probably for {package_name}")
            # deps.get_all_versions_from_depsdev(ecosystem=ecosystem, package_name=package_name)
            # deps.get_dependents_for_package(ecosystem=ecosystem, package_name=package_name)
            # TODO: We are going to fix this case later, continue for now.
            continue
        if package_name in time_mapping:
            fixed_version_release_time = utils.get_time(
                                    package_name=package_name,
                                    version=vul_fixed,
                                    time_mapping=time_mapping,
                                    latest_verison_time_mapping=latest_verison_time_mapping,
                                    earliest_version_time_mapping=earliest_version_time_mapping)
            logging.debug(f"time_mapping[{package_name}][{vul_fixed}]: {fixed_version_release_time}")
            try:
                fixed_version_release_datetime = datetime.datetime.fromtimestamp(fixed_version_release_time)
                logging.debug(f"time_mapping[{package_name}][{vul_fixed}]: {fixed_version_release_datetime}")
            except OSError:
                logging.warning(f"timestamp is wrong for this package, going to next package!")
                # TODO: Figure out why this timestamp is wrong.
                continue
        # if package_name in time_mapping and vul_fixed in time_mapping[package_name]:
        #     fixed_version_release_time = time_mapping[package_name][vul_fixed]
        #     logging.debug(f"time_mapping[{package_name}][{vul_fixed}]: {fixed_version_release_time}")
        # elif package_name in time_mapping:
        #     logging.debug(f"vul_fixed in not available, here's what is available:")
        #     logging.debug(f"{time_mapping[package_name]}")
        
        # For <pkg_name> of version [vul_introduced, vul_fixed), gather the list of dependent packages
        # and versions that has at least any of the vulnerable version of <pkg_name> in it's dependency
        vul_dependent_list = utils.get_vul_dependents_list_updated(ecosystem=ecosystem,
                                                 time_mapping=time_mapping,
                                                 package_name=package_name,
                                                 version_start=vul_introduced,
                                                 version_end=vul_fixed,
                                                 ascending_order=True,
                                                 latest_version_time_mapping=latest_verison_time_mapping,
                                                 earliest_version_time_mapping=earliest_version_time_mapping,
                                                 version_sequence=version_sequence)
        logging.debug(f"vul_dependent_list, size: {len(vul_dependent_list)}\n{vul_dependent_list}")

        # For <pkg_name> of version [vul_fixed, ), look at the dependent packages and versions
        # which will definitely have a fixed version of <pkg_name> in it's dependency
        fixed_dependent_list = utils.get_fixed_dependents_list_updated(ecosystem=ecosystem,
                                                 time_mapping=time_mapping,
                                                 package_name=package_name,
                                                 version_start=vul_fixed,
                                                 version_end="",
                                                 ascending_order=False,
                                                 latest_version_time_mapping=latest_verison_time_mapping,
                                                 earliest_version_time_mapping=earliest_version_time_mapping,
                                                 version_sequence=version_sequence)
        logging.debug(f"fixed_dependent_list, size: {len(fixed_dependent_list)}\n{fixed_dependent_list}")

        # Find the packages that are in the vul_dependent_list but NOT in fixed_dependent_list
        appropriate_dependent_list = { }
        for dependent_package_name in vul_dependent_list.keys():
            if dependent_package_name not in fixed_dependent_list:
                appropriate_dependent_list[dependent_package_name] = vul_dependent_list[dependent_package_name]
        logging.debug(f"appropriate_dependent_list, size: {len(appropriate_dependent_list)}\
                      \n{appropriate_dependent_list}")

        # Find the time of release of this specific <dependent_pkg, vul_version> -> (T2)
        for dependent_package_name in appropriate_dependent_list.keys():
            appropriate_version = appropriate_dependent_list[dependent_package_name]
            if dependent_package_name in time_mapping and\
                appropriate_version in time_mapping[dependent_package_name]:
                
                appropriate_version_release_time = utils.get_time(
                    package_name=dependent_package_name,
                    version=appropriate_version,
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              version: {appropriate_version}\
                              \nappropriate_version_release_time: {appropriate_version_release_time}")
                appropriate_version_release_datetime = datetime.datetime.fromtimestamp(
                    appropriate_version_release_time
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              version: {appropriate_version}\
                              \nappropriate_version_release_datetime: {appropriate_version_release_datetime}")

                # FIXME: Do we really need this version release time???

                # Add (T2 - T1) as a TTU data point for <dependent_pkg>.
                # data_point = appropriate_version_release_time - fixed_version_release_time
                # logging.debug(f"Found one CDO/N data point {dependent_package_name} -> {data_point}")

                if fixed_version_release_time > appropriate_version_release_time:
                    data_point_datetime = datetime.datetime.today()\
                                            - fixed_version_release_datetime
                else:
                    data_point_datetime = datetime.datetime.today()\
                                            - appropriate_version_release_datetime
                # Normalisation
                logging.debug(f"data point datetime in days: {data_point_datetime.days}")
                # logging.debug(f"NORMALISATION_DELTA days: {NORMALISATION_DELTA.days}")
                # if data_point_datetime.days > NORMALISATION_DELTA.days:
                #     data_point_datetime = NORMALISATION_DELTA
                logging.debug(f"Found one CDO/N data point datetime {dependent_package_name} -> {data_point_datetime}")

                if dependent_package_name not in cdon_data_points:
                    cdon_data_points[dependent_package_name] = [ ]
                cdon_data_points[dependent_package_name].append(data_point_datetime.days)

                if dependent_package_name == "sequelize-models":
                    csv_writer.writerow({
                        "vul_id": vul_id,
                        "package_name": package_name,
                        "vul_introduced": vul_introduced,
                        "vul_fixed": vul_fixed,
                        "fix_version_release_time": fixed_version_release_datetime.date(),
                        "dependent_package_name": dependent_package_name,
                        "dependent_package_version": appropriate_version,
                        "dependent_package_release_time": appropriate_version_release_datetime.date(),
                        "CDO/N": data_point_datetime.days,
                        "repo_url": repo_url
                    })

                    vulnerable_range = "[{}, {})".format(vul_introduced, vul_fixed)
                    fixed_range = "[{}, )".format(vul_fixed)
                    combined_writer.writerow({
                        "Vul_id": vul_id,
                        "Parent": dependent_package_name,
                        "P_Vr": appropriate_version,
                        "P_Vr_R (X)": appropriate_version_release_datetime.date(),
                        "Dependency": package_name,
                        "D_Vr": fixed_range,
                        "D_Vr_R (Y)": fixed_version_release_datetime.date(),
                        "CDO": data_point_datetime.days,
                        "D_Vulnerable_Vr": vulnerable_range,
                        "D_Fixed_Vr": vul_fixed,
                        "D_F_Vr_R (Z)": fixed_version_release_datetime.date(),
                        "repo_url": repo_url
                    })

        logging.debug("\n\n\n")
        count += 1
        # if count > 1:
        #     break
    return cdon_data_points

def calculate_cdon(ecosystem, cdon_data_points):
    cdon = { }
    out_array = []
    for package_name in cdon_data_points.keys():
        logging.debug(f"CDO/N list for {package_name}: {cdon_data_points[package_name]}")
        _sum = sum(cdon_data_points[package_name])
        cdon[package_name] = _sum
        logging.debug(f"CDO/N of {package_name} : {_sum}")
        out_array.append(_sum)
    np.array(out_array).tofile('data_cdon.dat')
    logging.debug(f"Total number of packages: {len(cdon_data_points)}")

def main(ecosystem):
    cdon_data_points = calculate_cdon_data_points(ecosystem=ecosystem)
    calculate_cdon(ecosystem=ecosystem, cdon_data_points=cdon_data_points)

if __name__ == "__main__":
    main("npm")