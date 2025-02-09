import email.utils

def get_pubdate():
    return email.utils.formatdate()

if __name__ == '__main__':
    print(get_pubdate())
