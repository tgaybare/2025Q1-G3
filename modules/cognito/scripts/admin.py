import subprocess
import sys

user_pool_id = sys.argv[1]
client_id = sys.argv[2]
email = sys.argv[3]
password = sys.argv[4]

# Sign up the user
subprocess.run([
    "aws", "cognito-idp", "sign-up",
    "--client-id", client_id,
    "--username", email,
    "--password", password,
    "--user-attributes", f"Name=email,Value={email}"
], check=False)

# Confirm the user
subprocess.run([
    "aws", "cognito-idp", "admin-confirm-sign-up",
    "--user-pool-id", user_pool_id,
    "--username", email
], check=False)
