import os
import csv
import datetime
import logging
import mysql.connector

os.remove("./build_db_relations.log") if os.path.exists("./build_db_relations.log") else None
logging.basicConfig(filename='build_db_relations.log', encoding='utf-8', level=logging.DEBUG)

def db_init():
    sqlConnection = open_db_connection()
    # Don't have to create table always
    # create_tables(sqlConnection)
    return sqlConnection

def open_db_connection():
    try:
        sqlConnection = mysql.connector.connect(host='localhost',
                                                database='secmet-test',
                                                user='root',
                                                password=input("Enter your password: "))
        sqlConnection.autocommit(True)
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
        sql_drop_table_query = '''DROP TABLE IF EXISTS Relations;'''
        sqlite_create_table_query1 = '''
            CREATE TABLE Relations(
                RelationId int not null primary key auto_increment,
                SystemName varchar(255) not null,
                FromPackageName varchar(255) not null,
                FromVersion varchar(255) not null,
                ToPackageName varchar(255) not null,
                ToVersion varchar(255) not null
                -- probably have to add some constraints like if 1->2 you cannot add 2->1.
            );
        '''

        cursor = sqlConnection.cursor()
        logging.info(f"create_tables()")
        # Should not always drop table since we cannot run the whole script at once.
        # cursor.execute(sql_drop_table_query)
        # sqlConnection.commit()
        # logging.info(f"Table dropped")
        cursor.execute(sqlite_create_table_query1)
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

# def get_PackageId_from_VersionInfo(sqlConnection, SystemName, PackageName, Version):
#     try:
#         sqlite_check_row_query = '''
#             SELECT PackageId
#             From VersionInfo
#             WHERE SystemName=%s AND PackageName=%s AND Version=%s;
#         '''

#         cursor = sqlConnection.cursor()
#         logging.debug(f"get_PackageId_from_VersionInfo()")
#         cursor.execute(sqlite_check_row_query, (SystemName, PackageName, Version))
#         check_result = cursor.fetchone()
#         # ret = None
#         if check_result is None:
#             # The record could not be found in the database
#             logging.error(f"If the <PackageName, Version> is not already in the database then it is a big problem")
#             ret = None
#         else:
#             # The record is already in the database
#             ret = check_result[0]
#         # sqlConnection.commit()
#         logging.debug(f"SQL get info from VersionInfo table")

#         cursor.close()

#     except mysql.connector.Error as error:
#         logging.error(f"get_PackageId_from_VersionInfo()")
#         logging.error(f"Error while getting packageid from a sqlite table {error}")
#     finally:
#         # if sqlConnection:
#         #     sqlConnection.close()
#         #     print("sqlite connection is closed")
#         return ret

def insert_relations_table(sqlConnection, SystemName, FromPackageName, FromVersion,
                            ToPackageName, ToVersion):
    try:
        sqlite_check_row_query = '''
            SELECT *
            From Relations
            WHERE SystemName=%s AND FromPackageName=%s AND FromVersion=%s
            AND ToPackageName=%s AND ToVersion=%s;
        '''

        cursor = sqlConnection.cursor()
        logging.debug(f"insert_relations_table()")
        cursor.execute(sqlite_check_row_query, (SystemName, FromPackageName, FromVersion,
                                                ToPackageName, ToVersion))
        check_result = cursor.fetchone()
        if check_result is None:
            # The record could not be found in the database
            logging.debug(f"The {SystemName}: <{FromPackageName}, {FromVersion}>  -> <{ToPackageName}, {ToVersion}> is not already in the database")
            update_query = '''
                INSERT INTO Relations(SystemName, FromPackageName, FromVersion, ToPackageName, ToVersion)
                Values(%s, %s, %s, %s, %s);
            '''
            cursor.execute(update_query, (SystemName, FromPackageName, FromVersion,
                                            ToPackageName, ToVersion))
        else:
            # The record is already in the database
            logging.debug(f"This <parent, child> pair is already in the database")
            logging.debug(f"this result: {check_result}")
            logging.debug(f"this insert try: {SystemName}, {FromPackageName}, {FromVersion}, {ToPackageName}, {ToVersion}")
            None
        # Frequent commit slows everything
        sqlConnection.commit()
        logging.debug(f"SQLite relations table updated")

        cursor.close()

    except mysql.connector.Error as error:
        logging.error(f"insert_relations_table()")
        logging.error(f"Error while updating Relations table {error}")
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

def get_parent_child_relation_graph(sqlConnection) -> dict:
    # The "relations" dict contains (parent_package_name, child_package_name) as keys and
    #       a list of (parent_package_version, child_package_version) as value.
    # relations = { }
    data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "requirement-durations")

    for (root,dirs,files) in os.walk(data_dir, topdown=False):
        for file in files:
            if file.endswith(".csv"):
                file_path = os.path.join(data_dir, root, file)
                logging.info(f"file_path: {file_path}")

                with open(file_path, 'r', encoding="utf-8") as f:
                    csvreader = csv.reader(f, delimiter=';', doublequote=False,
                                           escapechar='"', quoting=csv.QUOTE_NONE)
                    try:
                        for i, line in enumerate(csvreader):
                            if i == 0:
                                continue
                            # System;Name;Version;RequirementName;RequirementVersion;HighestMatchingVersion;HighestAvailableRelease;IntervalStart;IntervalEnd;IsOutOfDate;IsRegular;Warnings
                            if line == '' or len(line) < 6 or line[1] == '' or line[2] == '' or line[3] == '' or line[5] == '':
                                continue

                            system_name = line[0]

                            logging.debug(f"Here system is: {system_name}")

                            if system_name == "NPM":

                                parent_package_name = line[1]
                                parent_package_version = line[2]

                                # parent_package_id = get_PackageId_from_VersionInfo(sqlConnection,
                                #                                                    system_name,
                                #                                                    parent_package_name,
                                #                                                    parent_package_version)
                                
                                child_package_name = line[3]
                                child_package_version = line[5]

                                # child_package_id = get_PackageId_from_VersionInfo(sqlConnection,
                                #                                                   system_name,
                                #                                                   child_package_name,
                                #                                                   child_package_version)
                                
                                # if parent_package_id == None or child_package_id == None:
                                #     # No way to use this record
                                #     logging.error(f"Something wrong with this record: system: {system_name}")
                                #     logging.error(f"parent: {parent_package_id} {parent_package_name} {parent_package_version}")
                                #     logging.error(f"child: {child_package_id} {child_package_name} {child_package_version}")
                                #     continue


                                # if (parent_package_name, child_package_name) not in relations.keys():
                                #     relations[(parent_package_name, child_package_name)] = [ ]
                                
                                # relations[(parent_package_name, child_package_name)].append(
                                #     (parent_package_version, child_package_version)
                                # )

                                insert_relations_table(sqlConnection, system_name,
                                                    parent_package_name, parent_package_version,
                                                    child_package_name, child_package_version)
                    except csv.Error:
                        logging.warning(f"{line}")
                        print (line)

                # # Commiting after reading every csv file
                # sqlConnection.commit()
    
    # return relations

def main():
    # Maybe delete the database if exists
    sqlConnection = db_init()
    # get_package_versions(ecosystem, sqlConnection)
    get_parent_child_relation_graph(sqlConnection)
    print("relations completed")
    db_close(sqlConnection)
    

if __name__ == "__main__":
    main()