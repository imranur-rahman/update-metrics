import csv
import datetime
import json
import logging
import os
import sys
from statistics import mean

import utils
import deps

os.remove("./logmttr.log") if os.path.exists("./logmttr.log") else None
logging.basicConfig(filename='logmttr.log', encoding='utf-8', level=logging.DEBUG)

def calculate_ttr_data_points(ecosystem) -> dict:
    # TTR data point container
    ttr_data_points = { }

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
    csv_writer = utils.write_csv_header(filename="data_ttr",
                                        header_list=[
                                            "vul_id",
                                            "package_name",
                                            "vul_introduced",
                                            "vul_fixed",
                                            "fix_version_release_time",
                                            "dependent_package_name",
                                            "dependent_package_vul_version",
                                            "dependent_package_vul_version_release_time",
                                            "dependent_package_fixed_version",
                                            "dependent_package_fixed_version_release_time",
                                            "TTR",
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

        # Find the intersection of above two lists and keep the fixed and vulnerable version
        appropriate_dependent_fixed_version_list = { }
        appropriate_dependent_vul_version_list = { }
        for dependent_package_name in vul_dependent_list.keys():
            if dependent_package_name in fixed_dependent_list:
                appropriate_dependent_fixed_version_list[dependent_package_name] = fixed_dependent_list[dependent_package_name]
                appropriate_dependent_vul_version_list[dependent_package_name] = vul_dependent_list[dependent_package_name]
        logging.debug(f"appropriate_dependent_list, size: {len(appropriate_dependent_fixed_version_list)}\
                      \n{appropriate_dependent_fixed_version_list}")

        # Find the time of release of this specific <dependent_pkg, fixed_version> -> (T2)
        for dependent_package_name in appropriate_dependent_fixed_version_list.keys():
            appropriate_fixed_version = appropriate_dependent_fixed_version_list[dependent_package_name]
            appropriate_vul_version = appropriate_dependent_vul_version_list[dependent_package_name]
            if dependent_package_name in time_mapping and\
                appropriate_fixed_version in time_mapping[dependent_package_name]:
                
                appropriate_fixed_version_release_time = utils.get_time(
                    package_name=dependent_package_name,
                    version=appropriate_fixed_version,
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              fixed_version: {appropriate_fixed_version}\
                              \nappropriate_fixed_version_release_time: {appropriate_fixed_version_release_time}")
                appropriate_fixed_version_release_datetime = datetime.datetime.fromtimestamp(
                    appropriate_fixed_version_release_time
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              fixed_version: {appropriate_fixed_version}\
                              \nappropriate_fixed_version_release_datetime: {appropriate_fixed_version_release_datetime}")

                data_point = appropriate_fixed_version_release_time - fixed_version_release_time
                # Add (T2 - T1) as a TTR data point for <dependent_pkg>.
                logging.debug(f"Found one TTR data point {dependent_package_name} -> {data_point}")

                data_point_datetime = appropriate_fixed_version_release_datetime\
                                        - fixed_version_release_datetime
                logging.debug(f"Found one TTR data point datetime {dependent_package_name} -> {data_point_datetime}")

                # FIXME: How to handle negative TTR data points? Is it enough to just ignore them?
                if dependent_package_name not in ttr_data_points.keys():
                    ttr_data_points[dependent_package_name] = [ ]
                ttr_data_points[dependent_package_name].append(data_point_datetime.days)

                # Find the vulnerable version of this appropriate dependent package (for CSV only)
                appropriate_vul_version_release_time = utils.get_time(
                    package_name=dependent_package_name,
                    version=appropriate_vul_version,
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              vul_version: {appropriate_vul_version}\
                              \nappropriate_vul_version_release_time: {appropriate_vul_version_release_time}")
                appropriate_vul_version_release_datetime = datetime.datetime.fromtimestamp(
                    appropriate_vul_version_release_time
                )
                logging.debug(f"appropriate_package_name: {dependent_package_name}\
                              vul_version: {appropriate_vul_version}\
                              \nappropriate_vul_version_release_datetime: {appropriate_vul_version_release_datetime}")
                logging.debug(f"\n")

                if dependent_package_name == "sequelize-models":
                    csv_writer.writerow({
                        "vul_id": vul_id,
                        "package_name": package_name,
                        "vul_introduced": vul_introduced,
                        "vul_fixed": vul_fixed,
                        "fix_version_release_time": fixed_version_release_datetime.date(),
                        "dependent_package_name": dependent_package_name,
                        "dependent_package_vul_version": appropriate_vul_version,
                        "dependent_package_vul_version_release_time": appropriate_vul_version_release_datetime.date(),
                        "dependent_package_fixed_version": appropriate_fixed_version,
                        "dependent_package_fixed_version_release_time": appropriate_fixed_version_release_datetime.date(),
                        "TTR": data_point_datetime.days,
                        "repo_url": repo_url
                    })

                    vulnerable_range = "[{}, {})".format(vul_introduced, vul_fixed)
                    fixed_range = "[{}, )".format(vul_fixed)
                    combined_writer.writerow({
                        "Vul_id": vul_id,
                        "Parent": dependent_package_name,
                        "P_Vr": appropriate_fixed_version,
                        "P_Vr_R (X)": appropriate_fixed_version_release_datetime.date(),
                        "Dependency": package_name,
                        "D_Vr": fixed_range,
                        "D_Vr_R (Y)": fixed_version_release_datetime.date(),
                        "D_Vulnerable_Vr": vulnerable_range,
                        "D_Fixed_Vr": vul_fixed,
                        "D_F_Vr_R (Z)": fixed_version_release_datetime.date(),
                        "TTR (X - Z)": data_point_datetime.days,
                        "repo_url": repo_url
                    })

        logging.debug("\n\n\n")
        count += 1
        # if count > 1:
        #     break
    return ttr_data_points

def calculate_mttr(ecosystem, ttr_data_points):
    mttr = { }
    for package_name in ttr_data_points.keys():
        _mean = mean(ttr_data_points[package_name])
        mttr[package_name] = _mean
        logging.debug(f"TTR data points for {package_name}: {ttr_data_points[package_name]}")
        logging.debug(f"MTTR of {package_name} : {_mean}")
    logging.debug(f"Total number of packages: {len(ttr_data_points)}")

def main(ecosystem):
    ttr_data_points = calculate_ttr_data_points(ecosystem=ecosystem)
    calculate_mttr(ecosystem=ecosystem, ttr_data_points=ttr_data_points)

if __name__ == "__main__":
    main("npm")