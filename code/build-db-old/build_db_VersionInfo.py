import os
import csv
import datetime
import logging
import mysql.connector
import pymysql
import pandas as pd
from sqlalchemy import create_engine

os.remove("./build_db_VersionInfo.log") if os.path.exists("./build_db_VersionInfo.log") else None
logging.basicConfig(filename='build_db_VersionInfo.log', encoding='utf-8', level=logging.INFO)

def db_init():
    sqlConnection = open_db_connection()
    create_tables(sqlConnection)
    return sqlConnection

def open_db_connection():
    try:
        sqlConnection = mysql.connector.connect(host='localhost',
                                                database='secmet-test',
                                                user='root',
                                                password=input("Enter your password: "))
        cursor = sqlConnection.cursor()
        logging.info(f"open_db_connection()")
        logging.info(f"Database created and Successfully Connected to SQL")

        sqlite_select_Query = "select version();"
        cursor.execute(sqlite_select_Query)
        record = cursor.fetchall()
        logging.info(f"SQL Database Version is: {record}")
        cursor.close()

    except mysql.connector.Error as error:
        logging.error(f"open_db_connection()")
        logging.error(f"Error while connecting to SQL {error}")
    finally:
        # if sqlConnection:
        #     sqlConnection.close()
        #     print("The SQLite connection is closed")
        return sqlConnection
    
def create_tables(sqlConnection):
    try:
        sql_drop_table_query = '''DROP TABLE IF EXISTS VersionInfo;'''
        sqlite_create_table_query1 = '''
            CREATE TABLE VersionInfo (
                PackageId int not null primary key auto_increment,
                SystemName varchar(255) not null,
                PackageName varchar(255) not null,
                Version varchar(255) not null,
                ReleaseDate varchar(255) not null
            );
        '''

        cursor = sqlConnection.cursor()
        logging.info(f"create_tables()")
        cursor.execute(sql_drop_table_query)
        sqlConnection.commit()
        logging.info(f"Table dropped")
        cursor.execute(sqlite_create_table_query1)
        # cursor.execute(sqlite_create_table_query2)
        sqlConnection.commit()
        logging.info(f"SQL table created")

        cursor.close()

    except mysql.connector.Error as error:
        logging.error(f"create_tables()")
        logging.error(f"Error while creating a sqlite table {error}")
    finally:
        # if sqlConnection:
        #     sqlConnection.close()
        #     print("sqlite connection is closed")
        None

def insert_into_VersionInfo(sqlConnection, SystemName, PackageName, Version, ReleaseDate):
    try:
        sqlite_update_table_query = '''
            INSERT INTO VersionInfo(SystemName, PackageName, Version, ReleaseDate)
            VALUES(%s, %s, %s, %s);
        '''

        cursor = sqlConnection.cursor()
        logging.debug(f"insert_into_VersionInfo()")
        cursor.execute(sqlite_update_table_query, (SystemName, PackageName, Version, ReleaseDate))
        # Frequent commit slows down 
        # sqlConnection.commit()
        logging.debug(f"SQLite table updated")

        cursor.close()

    except mysql.connector.Error as error:
        logging.error(f"insert_into_VersionInfo()")
        logging.error(f"Error while updating a sqlite table {error}")
    finally:
        # if sqlConnection:
        #     sqlConnection.close()
        #     print("sqlite connection is closed")
        None

def db_close(sqlConnection):
    try:
        sqlConnection.commit()
        logging.info(f"SQL commited")
    except mysql.connector.Error as error:
        logging.error(f"update_relations_table()")
        logging.error(f"Error while updating Relations table {error}")
    finally:
        if sqlConnection:
            sqlConnection.close()
            print("sqlite connection is closed")

def get_package_versions(ecosystem, sqlConnection) -> dict:
    # Dictionary of dictonaries
    # The output contains a dictionary which contains multiple dictonaries
    # (one for each package). The dictonary for each package contains <version, releaseTime>
    # as <key, value> pair.
    
    # package_versions = { }
    package_versions_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "package-versions")

    for (root,dirs,files) in os.walk(package_versions_dir, topdown=True):
        for file in files:
            if file.endswith(".csv"):
                file_path = os.path.join(package_versions_dir, root, file)
                logging.info(f"file_path: {file_path}")
                with open(file_path, 'r') as f:
                    csvreader = csv.reader(f, delimiter=';')
                    for i, line in enumerate(csvreader):
                        # System;Name;Version;UpstreamPublishedAt
                        if i == 0:
                            continue
                        # logging.info(f"line{i}: {line}")
                        if line[0] == '' or line[1] == '' or line[2] == '' or line[3] == '':
                            continue

                        system_name = line[0]
                        package = line[1]
                        version = line[2]
                        # Removing last 4 characters from line[3]
                        release_datetime = datetime.datetime.strptime(line[3][:-4], '%Y-%m-%d %H:%M:%S')
                        # if package not in package_versions:
                        #     package_versions[package] = { }
                        # # Should not happen
                        # if version in package_versions[package]:
                        #     logging.error(f"something bad happened.")
                        # logging.debug(f"{package}@{version} = {release_date}")
                        # package_versions[package][version] = release_datetime
                        insert_into_VersionInfo(sqlConnection, system_name, package, version,
                                                release_datetime.strftime('%Y-%m-%d %H:%M:%S'))


def main(ecosystem):
    # Maybe delete the database if exists
    sqlConnection = db_init()
    get_package_versions(ecosystem, sqlConnection)
    print("versioninfo completed")
    db_close(sqlConnection)
    # get_parent_child_relation_graph(ecosystem, sqlConnection)

if __name__ == "__main__":
    main("npm")