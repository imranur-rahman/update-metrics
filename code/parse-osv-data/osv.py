import os
from json import loads
from pathlib import Path
import csv
import json
#from src.helpers import open_db, FileWrapper

soup_ingredient = 'html.parser'
base_path = Path.cwd()

class OSV:
    def __init__(self, ecosystem) -> None:
        self.ecosystem = ecosystem
        self.meta_folder = f"{base_path}/osv-data/" + ecosystem
        
    def run(self):
        pages = os.listdir(self.meta_folder)
            
    def process(self):
        # Open CSV file to store the data
        csv_file = open(f"{self.ecosystem}.csv", "w")
        csv_header = ["vul_id", "pkg_name", "vul_introduced", "vul_fixed", "repo_url"]
        csv_writer = csv.DictWriter(csv_file, fieldnames=csv_header)
        csv_writer.writeheader()

        # print (os.listdir(self.meta_folder))

        for file in os.listdir(self.meta_folder):
            with open(self.meta_folder + f'/{file}', 'r', encoding="utf-8") as f:
                try:
                    # meta = loads(stream.read())
                    meta = json.load(f)

                    # print (meta)
                    vul_id = meta["id"]

                    packageName = ""
                    url = ""
                    cve_ids = []
                    cwe_ids = []
                    references = []

                    pkgset = set()

                    repo_url = ""
                    if "references" in meta:
                        for reference in meta["references"]:
                            if "type" in reference and reference["type"] == "PACKAGE":
                                repo_url = reference["url"]
                    
                    if 'affected' in meta:# and 'package' in meta['affected'][0]\
                        #and 'ranges' in meta['affected'][0]:
                        for affected in meta['affected']:
                            if 'package' in affected and 'ranges' in affected:
                                packageName = affected['package']['name']
                                # print (packageName)

                                pkgset.add(packageName)

                                ranges = affected['ranges']
                                # print (ranges)
                                for range in ranges:
                                    # print (range)
                                    events = range['events']
                                    # print (events)
                                    for event in events:
                                        if 'introduced' in event:
                                            vul_introduced = event['introduced']
                                        elif 'fixed' in event:
                                            vul_fixed = event['fixed']
                                            # print (vul_introduced)
                                            # print (vul_fixed)
                                            csv_writer.writerow({
                                                "vul_id": vul_id,
                                                "pkg_name": packageName,
                                                "vul_introduced": vul_introduced,
                                                "vul_fixed": vul_fixed,
                                                "repo_url": repo_url
                                            })
                                        
                            if 'package' in affected and 'versions' in affected:
                                packageName = affected['package']['name']
                                # print (packageName)
                                versions = affected['versions']
                                # print (versions)
                                # for version in versions:
                                #     print (version) # This is probably the affected versions
                            
                                pkgset.add(packageName)

                except Exception:
                    pass
        print (pkgset)
        print (len(pkgset))