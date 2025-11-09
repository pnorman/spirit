#!/usr/bin/env python3

import csv
import re

# Process a taginfo list of names for valid codes

# Get a list with curl -o names.csv 'https://taginfo.openstreetmap.org/api/4/keys/all?query=name%3A&format=csv'

def valid_name(key: str) -> bool:
    """Check if a name key is valid."""
    if not key.startswith("name:"):
        return False
    code = key[5:]

    if not code or not code.isascii() or code.startswith("-") or ":" in code or "_" in code:
        return False

    if code[0].isnumeric():
        return False

    first = code.split("-")[0]

    if not first.isalpha() or not first.islower():
        return False
    # first = re.match(r"^[a-z0-9]*", code)
    return len(first) in (2, 3)

with open("names.csv", newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    print("local DEFAULT_LANGUAGES = {")
    for row in reader:
        if valid_name(row['key']) and int(row['count_all']) > 50_000:
            print(f"""    ["{row['key'][5:]}"] = true,""")
    print("}")
