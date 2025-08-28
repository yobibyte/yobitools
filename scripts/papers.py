"""Utils to do local paper management."""
import os

LIB_PATH="/home/yobibyte/papers"
NOTES_PATH="/home/yobibyte/yobivault/papers.md"

def get_paper_paths_from_notes(notes_path):
    papers = []
    with open(notes_path) as f:
        for line in f:
            line = line.strip()
            if line.endswith('.pdf'):
                papers.append(line)
    return papers

def get_paper_paths_from_lib(lib_path):
    papers = []
    for file in os.listdir(lib_path):
        if file.endswith('.pdf'):
            papers.append(os.path.join(lib_path, file))
    return papers


def clean_lib(notes_path, lib_path):
    lib_papers = set(get_paper_paths_from_lib(lib_path))
    notes_papers = set(get_paper_paths_from_notes(notes_path))
    unused_papers = lib_papers - notes_papers
    for up in unused_papers:
        print(up)
        # os.remove(up)


if __name__ == '__main__':
    clean_lib(NOTES_PATH, LIB_PATH)

