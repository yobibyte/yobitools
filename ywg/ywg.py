from compressor.data import PaperDB
from pandas.core.dtypes.dtypes import datetime
from tqdm import tqdm
import pandas as pd
import sys
from util import get_pubdate
import shutil
import xml.etree.ElementTree as ET


def get_feed_item(page_name, title, desc):
    return """
        <item>
            <title>title_placeholder</title>
            <pubDate>date_placeholder</pubDate>
            <link>https://yobibyte.github.io/link_placeholder.html</link>
            <guid>https://yobibyte.github.io/guid_placeholder.html</guid>
            <description>description_placeholder</description>
        </item>
    """.replace("title_placeholder", title).replace("date_placeholder", get_pubdate()).replace("link_placeholder", page_name).replace("guid_placeholder", page_name).replace("description_placeholder", desc)

def add_page():
    page_name = input("Enter page filename... ")
    page_title = input("Enter page title... ")
    page_desc = input("Enter page description... ")

    # make a feed entry first
    new_item = get_feed_item(page_name, page_title, page_desc)

    feed_xml = ET.parse('../feed.xml')
    root = feed_xml.getroot()
    root.find('.//channel').append(ET.fromstring(new_item))
    feed_xml.write('../feed.xml')

    shutil.copyfile("../template.html", f"../{page_name}.html")

if __name__ == '__main__':
    args = sys.argv
    add_page()
