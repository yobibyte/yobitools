from datetime import datetime 
import urllib.request
import sys
import subprocess
import os
import re

LIBDIR = "/home/yobibyte/papers"
NOTES = "/home/yobibyte/yobivault/papers.md"
DUMMY_FILE = "/home/yobibyte/Downloads/f.pdf"

timestamp = datetime.strftime(datetime.now(),"%Y_%m_%d_%H_%M_%S")
fpath = os.path.join(LIBDIR, f"{timestamp}.pdf")

url = sys.argv[1]

# if it's arxiv link, download from an abs link.
abs_url = None
if 'arxiv' in url and "abs" in url:
    abs_url = url
    url = url.replace("abs", "pdf")

if len(sys.argv) > 2:
    # we send an additional arg, 'pd' and save to Downloads as f.pdf.
    urllib.request.urlretrieve(url, DUMMY_FILE)
else:
    urllib.request.urlretrieve(url, fpath)
    # Extract the title:
    title = None
    if abs_url:
        with urllib.request.urlopen(abs_url) as response:
            html = response.read()
            title = re.search(r'Title:</span>(.*?)</h1>', html.decode('utf-8')).group(1)

    # Add to the inbox
    with open(NOTES, 'r') as f:
        content = f.read()
    with open(NOTES, 'w') as f:
        entry = [url, '\n', fpath, '\n\n', content]
        if title:
            entry = [f"# {title}\n"] + entry
        f.writelines(entry)

subprocess.run(['notify-send', 'Paper added!'])

