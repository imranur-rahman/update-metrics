import os

def main(ecosystem):
    deps_data_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "deps-dev-data")
    ecosystem_dir = os.path.join(deps_data_dir, ecosystem)

    # package_dir = os.path.join(ecosystem_dir, package_name)
    # if os.path.exists(package_dir) == False:
    #     os.mkdir(package_dir)
    # dependency_info_file = os.path.join(package_dir, version + extension)

    for (root,dirs,files) in os.walk(ecosystem_dir, topdown=True):
        for file in files:
            if file.endswith("versions.json"):
                # print (os.path.join(ecosystem_dir, root, file))
                os.remove(os.path.join(ecosystem_dir, root, file))

if __name__ == "__main__":
    main("npm")