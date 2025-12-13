import json
import os
from datetime import datetime
from pathlib import Path

def analyze_npm_packages():
    data_dir = Path("data/package-info-npmjs/")
    packages_info = []
    
    # Read all JSON files in the directory
    for json_file in data_dir.glob("*.json"):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                package_data = json.load(f)
            
            # Get package name
            package_name = package_data.get('name', json_file.stem)
            
            # Count dependencies
            latest_version = package_data.get('dist-tags', {}).get('latest')
            if latest_version and 'versions' in package_data:
                version_data = package_data['versions'].get(latest_version, {})
                dependencies = version_data.get('dependencies', {})
                dep_count = len(dependencies)
            else:
                dep_count = 0
            
            # Get first version release time
            versions = package_data.get('versions', {})
            if versions:
                # Get the earliest version by sorting version keys
                first_version_key = min(versions.keys(), 
                                      key=lambda v: datetime.fromisoformat(
                                          versions[v].get('dist', {}).get('published', '9999-12-31T00:00:00.000Z').replace('Z', '+00:00')))
                first_release = versions[first_version_key].get('dist', {}).get('published')
                if first_release:
                    first_release_date = datetime.fromisoformat(first_release.replace('Z', '+00:00'))
                else:
                    first_release_date = None
            else:
                first_release_date = None
            
            packages_info.append({
                'name': package_name,
                'dependencies': dep_count,
                'first_release': first_release_date
            })
            
        except (json.JSONDecodeError, KeyError, ValueError) as e:
            print(f"Error processing {json_file}: {e}")
            continue
    
    # Filter packages with exactly 10 dependencies
    packages_with_10_deps = [pkg for pkg in packages_info if pkg['dependencies'] == 10 and pkg['first_release']]
    
    # Sort by first release date (earliest first)
    packages_with_10_deps.sort(key=lambda x: x['first_release'])
    
    return packages_with_10_deps

if __name__ == "__main__":
    result = analyze_npm_packages()
    
    print(f"Found {len(result)} packages with exactly 10 dependencies:")
    print("-" * 60)
    
    for pkg in result:
        print(f"Package: {pkg['name']}")
        print(f"Dependencies: {pkg['dependencies']}")
        print(f"First Release: {pkg['first_release'].strftime('%Y-%m-%d %H:%M:%S')}")
        print("-" * 60)