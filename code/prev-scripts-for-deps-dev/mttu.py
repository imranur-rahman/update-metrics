import csv
import datetime
import json
import logging
import os
import sys
from statistics import median

import utils
import deps

os.remove("./logmttu.log") if os.path.exists("./logmttu.log") else None
logging.basicConfig(filename='logmttu.log', encoding='utf-8', level=logging.DEBUG)

def calculate_ttu_data_points(ecosystem) -> dict:
    # TTU data point container
    ttu_data_points = { }

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
    csv_writer = utils.write_csv_header(filename="data_ttu",
                                        header_list=[
                                            "child_package_name",
                                            "child_package_version",
                                            "child_package_release_time",
                                            "parent_package_name",
                                            "parent_package_version",
                                            "parent_package_release_time",
                                            "TTU"
                                        ])

    # Find the <package_name, version> to <createdAt> mapping
    time_mapping, latest_verison_time_mapping, earliest_version_time_mapping, version_sequence =\
                  utils.get_name_version_to_release_time_mapping(ecosystem=ecosystem)

    # Find the <child, parent> relations with version numbers
    relations = utils.get_child_parent_relation_graph(ecosystem=ecosystem)

    for (child_package_name, parent_package_name) in relations.keys():
        logging.debug(f"key: ({child_package_name}, {parent_package_name}): \
                      value: {relations[(child_package_name, parent_package_name)]}")
        # Sort the list of <child_package_version, parent_package_version>
        # TODO: What should be the correct way to sort this? Or should we even sort this?
        relations[(child_package_name, parent_package_name)].sort(
            key = lambda x: utils.get_time(
                    package_name=child_package_name,
                    version=x[0], # child_version_name
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
            )
        )
        logging.debug(f"key: ({child_package_name}, {parent_package_name}): \
                      sorted value: {relations[(child_package_name, parent_package_name)]}")
        
        # Calculate the updates
        iteration = 0
        for (child_package_version, parent_package_version) in \
            relations[(child_package_name, parent_package_name)]:
            iteration += 1
            # if iteration == 1:
            #     # First iteration, no update to calculate
            #     continue

            child_package_release_time = utils.get_time(
                    package_name=child_package_name,
                    version=child_package_version,
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
            )
            logging.debug(f"child_package_name: {child_package_name}, version: {child_package_version}\
                          release time: {child_package_release_time}")
            try:
                child_package_release_datetime = datetime.datetime.fromtimestamp(
                    child_package_release_time
                )
            except OSError:
                logging.warning(f"timestamp is wrong for this package, going to next package!")
                # FIXME: Figure out why this timestamp is wrong.
                continue
            logging.debug(f"child_package_name: {child_package_name}, version: {child_package_version}\
                          release datetime: {child_package_release_datetime}")
            
            parent_package_release_time = utils.get_time(
                    package_name=parent_package_name,
                    version=parent_package_version,
                    time_mapping=time_mapping,
                    latest_verison_time_mapping=latest_verison_time_mapping,
                    earliest_version_time_mapping=earliest_version_time_mapping
            )
            logging.debug(f"parent_package_name: {parent_package_name}, version: {parent_package_version}\
                          release time: {parent_package_release_time}")
            try:
                parent_package_release_datetime = datetime.datetime.fromtimestamp(
                    parent_package_release_time
                )
            except OSError:
                logging.warning(f"timestamp is wrong for this package, going to next package!")
                # FIXME: Figure out why this timestamp is wrong.
                continue
            logging.debug(f"parent_package_name: {parent_package_name}, version: {parent_package_version}\
                          release datetime: {parent_package_release_datetime}")
            
            ttu_data_point_datetime = parent_package_release_datetime - child_package_release_datetime
            logging.debug(f"Found TTU data point: {parent_package_name} -> {ttu_data_point_datetime}")

            if iteration == 1:
                ttu_data_point_datetime_for_csv = ""
            else:
                # FIXME: How to handle negative TTU data points? Is it enough to just ignore them?
                if parent_package_name not in ttu_data_points.keys():
                    ttu_data_points[parent_package_name] = [ ]
                ttu_data_points[parent_package_name].append(ttu_data_point_datetime.days)
                ttu_data_point_datetime_for_csv = ttu_data_point_datetime.days

            if parent_package_name == "sequelize-models":
                csv_writer.writerow({
                    "child_package_name": child_package_name,
                    "child_package_version": child_package_version,
                    "child_package_release_time": child_package_release_datetime.date(),
                    "parent_package_name": parent_package_name,
                    "parent_package_version": parent_package_version,
                    "parent_package_release_time": parent_package_release_datetime.date(),
                    "TTU": ttu_data_point_datetime_for_csv
                })

                combined_writer.writerow({
                    "Parent": parent_package_name,
                    "P_Vr": parent_package_version,
                    "P_Vr_R (X)": parent_package_release_datetime.date(),
                    "Dependency": child_package_name,
                    "D_Vr": child_package_version,
                    "D_Vr_R (Y)": child_package_release_datetime.date(),
                    "TTU (X - Y)": ttu_data_point_datetime_for_csv
                })
            
    return ttu_data_points

def calculate_mttu(ecosystem, ttu_data_points):
    mttu = { }
    for package_name in ttu_data_points.keys():
        _mean = median(ttu_data_points[package_name]) # median() sorts internally
        mttu[package_name] = _mean
        logging.debug(f"TTU data points for {package_name}: {ttu_data_points[package_name]}")
        logging.debug(f"MTTU of {package_name} : {_mean}")
    logging.debug(f"Total number of packages: {len(ttu_data_points)}")

def main(ecosystem):
    ttu_data_points = calculate_ttu_data_points(ecosystem=ecosystem)
    calculate_mttu(ecosystem=ecosystem, ttu_data_points=ttu_data_points)

if __name__ == "__main__":
    main("npm")