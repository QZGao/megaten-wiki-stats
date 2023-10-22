import os
from pywikibot import Site, Page
from time import sleep

site = Site("zh", "megaten")

# Gather all files to update
wiki_files = {}

for root, dirs, files in os.walk("../Module"):
    for file in files:
        if file.endswith(".lua"):
            wiki_files[f"Module:{file[:-4]}"] = os.path.join(root, file)

for root, dirs, files in os.walk("../Template"):
    for file in files:
        if file.endswith(".html"):
            wiki_files[f"Template:{file[:-5]}"] = os.path.join(root, file)

print(f"|> Total {len(wiki_files)} files.")

# Update each file
for page_name, file_path in wiki_files.items():
    page = Page(site, page_name)
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Skip text before first double newline
    content = content[content.find("\n\n") + 2:].strip()

    # Save only if content changed
    if page.text != content:
        page.text = content
        page.save(summary="Update from GitHub Actions", botflag=True)
        print(f"|> Updated {page_name}.")

    else:
        print(f"|> No changes to {page_name}.")