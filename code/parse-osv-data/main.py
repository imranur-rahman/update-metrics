from osv import OSV
import deps
import logging

logging.basicConfig(filename='main.log', encoding='utf-8', level=logging.DEBUG)

def main():
    # One time running is enough
    osv_instance = OSV("npm")
    osv_instance.process()

    # deps.get_all_versions("npm")

    # deps.get_dependents("npm")

    # deps.get_all_versions_of_dependents("npm")

if __name__ == "__main__":
    main()