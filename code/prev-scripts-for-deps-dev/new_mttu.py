import os
import csv
import datetime
import logging
import sqlite3

import build_db

os.remove("./new_logmttu.log") if os.path.exists("./new_logmttu.log") else None
logging.basicConfig(filename='new_logmttu.log', encoding='utf-8', level=logging.WARNING)


def calculate_ttu_data_points(ecosystem) -> dict:
    # TTU data point container
    ttu_data_points = { }

    package_versions = get_package_versions(ecosystem)
    # Can we run it once and keep it in a binary format?
    relations = get_parent_child_relation_graph(ecosystem)

    for (parent_package_name, child_package_name) in relations.keys():
        logging.debug(f"key: ({parent_package_name}, {child_package_name}): \
                      value: {relations[(parent_package_name, child_package_name)]}")
        
        # Sort the list of <parent_package_version, child_package_version> with Semver
        relations[(parent_package_name, child_package_name)].sort(
            key = lambda x: package_versions[parent_package_name][x[0]]
            # x[0] parent_package_version
        )
        logging.debug(f"key: ({parent_package_name}, {child_package_name}): \
                      sorted value: {relations[(parent_package_name, child_package_name)]}")
        
        # Calculate the updates
        iteration = 0
        for (parent_package_version, child_package_version) in \
            relations[(parent_package_name, child_package_name)]:
            iteration += 1

            parent_package_release_datetime = \
                package_versions[parent_package_name][parent_package_version]
            
            logging.debug(f"parent_package_name: {parent_package_name}, version: {parent_package_version}\
                          release datetime: {parent_package_release_datetime}")
            
            child_package_release_datetime = \
                package_versions[child_package_name][child_package_version]
            
            logging.debug(f"child_package_name: {child_package_name}, version: {child_package_version}\
                          release datetime: {child_package_release_datetime}")
            
            ttu_data_point_datetime = parent_package_release_datetime - child_package_release_datetime
            logging.debug(f"Found TTU data point: {parent_package_name} -> {ttu_data_point_datetime}")

            if iteration == 1:
                None
            else:
                # FIXME: How to handle negative TTU data points?
                if parent_package_name not in ttu_data_points.keys():
                    ttu_data_points[parent_package_name] = [ ]
                ttu_data_points[parent_package_name].append(ttu_data_point_datetime.days)
    
    return ttu_data_points

def main(ecosystem):
    # Maybe delete the database if exists
    sqliteConnection = db_init()
    get_package_versions(ecosystem, sqliteConnection)
    print("versioninfo completed")
    get_parent_child_relation_graph(ecosystem, sqliteConnection)
    # calculate_ttu_data_points(ecosystem)

if __name__ == "__main__":
    main("npm")