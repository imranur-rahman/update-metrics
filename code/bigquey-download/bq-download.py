import google.auth
from google.oauth2 import service_account
from google.cloud import bigquery
import os
import pandas as pd
import pickle
import math

# Script inspired by: https://stackoverflow.com/a/60727919/3450691
# Downloading BigQuery data to pandas dataframe in chunks

credentials, project = google.auth.default()
# https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
bq_client = bigquery.Client(credentials=credentials)

class BqToDfChunker(object):


    def __init__(self, query_job, results_per_page):
        bq_result = query_job.result()
        destination = query_job.destination
        destination =  bq_client.get_table(destination)

        self.destination = destination
        self.results_per_page = results_per_page
        self.num_pages = math.ceil(float(destination.num_rows/results_per_page))
        self.index = 0
        self.next_token = None


    def get_next_df_page(self):
        rows = bq_client.list_rows(self.destination,
           max_results = self.results_per_page,
           page_token = self.next_token)

        if self.index < self.num_pages:

            df = pd.DataFrame(rows)
            self.index += 1
            self.next_token = rows.next_page_token 

            return df, self.index

        else:
            return None


    def has_next(self):
        if self.index != self.num_pages:
            return True
        else:
            return False


def get_data_all(ecosystem):
    data_dir = os.path.join(os.path.join(os.getcwd(), "data"), ecosystem.lower() + "-pkgver")
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
    ecosystem_upper = ecosystem.upper()

    query = f"""
        SELECT
            p.System as system_name,
            p.Name as package_name,
            p.Version as version_name,
            p.UpstreamPublishedAt as release_date
        FROM
            `bigquery-public-data.deps_dev_v1.PackageVersions` AS p
        WHERE
            p.System = '{ecosystem_upper}'
            and p.UpstreamPublishedAt is not null
            and p.Version is not null
            and p.Name is not null
            and p.SnapshotAt >= TIMESTAMP('2024-08-17') 
            and p.SnapshotAt < TIMESTAMP('2024-08-22');
    """

    

    df = bq_client.query(query).to_dataframe()
    print ("Finished query.")

    with open(os.path.join(data_dir, 'all.pkl'), 'wb') as fp:
        pickle.dump(df, fp)
        print("Saved all to pickle file.")

def get_data_in_chunk(ecosystem):
    data_dir = os.path.join(os.path.join(os.getcwd(), "data"), ecosystem.lower() + "-pkgver")
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
    ecosystem_upper = ecosystem.upper()

    query = f"""
        SELECT
            p.System as system_name,
            p.Name as package_name,
            p.Version as version_name,
            p.UpstreamPublishedAt as release_date
        FROM
            `bigquery-public-data.deps_dev_v1.PackageVersions` AS p
        WHERE
            p.System = '{ecosystem_upper}'
            and p.UpstreamPublishedAt is not null
            and p.Version is not null
            and p.Name is not null
            and p.SnapshotAt >= TIMESTAMP('2024-08-17') 
            and p.SnapshotAt < TIMESTAMP('2024-08-22');
    """
    print (query)
    job_config = bigquery.job.QueryJobConfig(allow_large_results=True) # Not sure if this really is doing anything.
    query_job = bq_client.query(query, job_config=job_config)
    
    
    #initialize the class with the query_job and number_of_results_per_page
    bq_test = BqToDfChunker(query_job, 100000)

    df, index = bq_test.get_next_df_page()
    df.columns = ['system_name', 'package_name', 'version_name', 'release_date']
    print (df.head())
    with open(os.path.join(data_dir, str(index)+'.pkl'), 'wb') as fp:
        pickle.dump(df, fp)
        print("Saved page " + str(index) + " to pickle file.")
    # df.to_csv(os.path.join(data_dir, str(index)+'.csv'), encoding='utf-8', index=False, header=True)

    while bq_test.has_next():
        # print(bq_test.get_next_df_page())
        df, index = bq_test.get_next_df_page()
        df.columns = ['system_name', 'package_name', 'version_name', 'release_date']
        print (df.head())
        with open(os.path.join(data_dir, str(index)+'.pkl'), 'wb') as fp:
            pickle.dump(df, fp)
            print("Saved page " + str(index) + " to pickle file.")
        # df.to_csv(os.path.join(data_dir, str(index)+'.csv'), encoding='utf-8', index=False, header=True)

def dry_run(ecosystem):
    ecosystem_upper = ecosystem.upper()
    query = f"""
        SELECT
            p.System as system_name,
            p.Name as package_name,
            p.Version as version_name,
            p.UpstreamPublishedAt as release_date
        FROM
            `bigquery-public-data.deps_dev_v1.PackageVersions` AS p
        WHERE
            p.System = '{ecosystem_upper}'
            and p.UpstreamPublishedAt is not null
            and p.Version is not null
            and p.Name is not null
            and p.SnapshotAt >= TIMESTAMP('2024-08-17') 
            and p.SnapshotAt < TIMESTAMP('2024-08-22');
    """

    job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)

    # Start the query, passing in the extra configuration.
    query_job = bq_client.query(
        query,
        job_config=job_config,
    )  # Make an API request.

    # A dry run query completes immediately.
    print("This query will process {} bytes.".format(query_job.total_bytes_processed))

def get_data_using_paginated_query(ecosystem):
    data_dir = os.path.join(os.path.join(os.getcwd(), "data"), ecosystem.lower() + "-pkgver")
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)

    query = """
        SELECT
            p.System as system_name,
            p.Name as package_name,
            p.Version as version_name,
            p.UpstreamPublishedAt as release_date
        FROM
            `bigquery-public-data.deps_dev_v1.PackageVersions` AS p
        WHERE
            p.System = '{}'
            and p.UpstreamPublishedAt is not null
            and p.Version is not null
            and p.Name is not null
            and p.SnapshotAt >= TIMESTAMP('2024-08-17') 
            and p.SnapshotAt < TIMESTAMP('2024-08-22')
        LIMIT {} OFFSET {};
    """

    # Process the data in smaller chunks
    chunk_size = 100000000 # Should be changed based on the data you are pulling, start from big, and reduce if you see "Response too large to return"
    offset =     0 # Start from 0, and if encounter error like "403 Quota Exceeded", start after some time for the correct offset

    while True:
        chunk_query = query.format(ecosystem.upper(), chunk_size, offset)
        df = bq_client.query(chunk_query).to_dataframe()
        # rows = list(query_job.result())

        # if not rows:
        #     break
        if not df.shape[0]:
            break

        
        # Process the rows here
        # df.columns = ['system_name', 'package_name', 'version_name', 'release_date']
        # print (df.head())
        with open(os.path.join(data_dir, str(offset)+'.pkl'), 'wb') as fp:
            pickle.dump(df, fp)
            print("Saved page " + str(offset) + " to pickle file.")

        offset += chunk_size


if __name__ == '__main__':
    # get_data_all('cargo')
    # get_data_all('pypi')
    # get_data_all('npm')
    # dry_run('npm')
    # get_data_using_paginated_query('npm') # No need
    # get_data_all('go')
    # get_data_using_paginated_query('maven') # No need
    # get_data_all('maven')
    get_data_all('nuget')