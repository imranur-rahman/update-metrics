import os
os.remove("./combined.csv") if os.path.exists("./combined.csv") else None
os.system('python3.9 mttu.py')
os.system('python3.9 mttr.py')
os.system('python3.9 cdon.py')