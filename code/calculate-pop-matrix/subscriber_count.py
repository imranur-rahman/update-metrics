import csv
import time
import os
import json
from dotenv import load_dotenv
from github import Github, UnknownObjectException

NUMBER_OF_COMMITS_TO_CHECK = 30

def load_access_token_in_env():
    """
    This functions loads the Github access token stored in the ".env" file
    and makes it available to use later in the program by simply accessing
    the token (e.g., with os.environ).

    Parameters
    ----------
    No parameter necessary. However, it assumes that the secret is stored
    in the ".env" file and the ".env" file is located in the same folder 
    of this script.

    Returns
    -------
    This function returns nothing.

    """
    dotenv_path = os.path.join(os.path.dirname(__file__), '.env')
    load_dotenv(dotenv_path)

def authenticate_user():
    """
    This function authenticates an user from the access token.

    This function first access the environment variable to get the
    Github access token and verifies whether an access token is 
    available in the environment variable. Then, it calls the Github
    REST API to verify if the access token is correct and returns
    the client object found from calling the REST API.
    
    In this function and the following functions we are using the 
    PyGithub library to communicate with Github REST API.

    Parameters
    ----------
    This function takes no parameter.

    Returns
    -------
    object
        Instantiation of the object which can be used further to
        make calls to the Github REST API.

    """
    # Reading the personal access token from os environ
    access_token = os.environ.get("GITHUB_ACCESS_TOKEN")

    # To check if the access token is actually in env variable
    assert access_token != None
    
    client = Github(login_or_token=access_token)
    return client

def repo_extract_from_url(repo_url: str) -> str:
    repo = repo_url.split("/")
    username = repo[-2]
    repo_name = repo[-1]
    return username + "/" + repo_name

def get_subscriber_count(client, repo_name):
    repo = client.get_repo(repo_name)
    return repo.subscribers_count

def get_subscriber_count_with_time(client, repo_name):
    
    # Starting time
    st = time.time()
    subscriber_count = get_subscriber_count(client=client, repo_name=repo_name)
    # Ending time
    et = time.time()
    return subscriber_count, (et - st)

def open_csv_file():
    """
    This function creates a CSV file with headers, "Repository",
    "Are All Dependencies Pinned", "Time Elapsed (s)", "Repo URL".
    Then it returns the writer object to write on the CSV file
    later.

    Parameters
    ----------
    No parameters

    Returns
    -------
    object
        Instance of CSV writer object.

    """
    # Open CSV file to store the data
    csv_file = open("subscriber_count.csv", "w")
    header = ["Repository", "Subscriber Count", "Repo URL"]
    writer = csv.DictWriter(csv_file, fieldnames=header)
    writer.writeheader()
    return writer

def func(csv_writer, client, repo_name):
    """
    This function calls the "check_pinned_dependency_with_time" function
    to find the pinned_dependency status and the time needed to do the 
    computation. After that, it writes the informations to the CSV
    file by using csv_writer object.

    Parameters
    ----------
    csv_writer : object
        Instance of CSV writer object.
    client : object
        Instance of the Github REST API object.
    repo_name : string
        The repository name in the format "user_name/repository_name".

    Returns
    -------
    This function returns nothing.

    """
    subscriber_count, time_elapsed = get_subscriber_count_with_time(client=client, repo_name=repo_name)
    csv_writer.writerow({
        "Repository": repo_name,
        "Subscriber Count": subscriber_count,
        "Repo URL": "https://github.com/" + repo_name
    })

def main():
    load_access_token_in_env()
    client = authenticate_user()

    csv_writer = open_csv_file()
    
    with open("npm_repos.txt") as file:
        for line in file:
            repo_url = line.rstrip()
            repo = repo_extract_from_url(repo_url)
            print (repo)
            func(csv_writer=csv_writer, client=client, repo_name=repo)

if __name__ == "__main__":
    main()