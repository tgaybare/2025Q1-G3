import os
import shutil
import subprocess
import sys

spa_source_dir = sys.argv[1]

# Step 1: Copy .env file to project root if needed
if spa_source_dir != ".":
    src_env = os.path.join(spa_source_dir, ".env")
    dst_env = ".env"
    try:
        shutil.copyfile(src_env, dst_env)
        print(f"Copied {src_env} to {dst_env}")
    except FileNotFoundError:
        print(f"Warning: {src_env} not found. Continuing...")

# Step 2: Change directory and build the SPA
os.chdir(spa_source_dir)

# Step 3: Run npm install and build
subprocess.run("npm install", shell=True, check=True)
subprocess.run("npm run build", shell=True, check=True)