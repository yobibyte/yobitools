use chrono::Utc;
use rss::Guid;
use rss::{Channel, ItemBuilder};
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let feed_path = "/home/yobibyte/dev/yobibyte.github.io/feed.xml";
    let file = File::open(feed_path).unwrap();
    let mut channel = Channel::read_from(BufReader::new(file)).unwrap();

    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Provide path to the html page as an argument!");
    }
    let html_content_fpath = args[1].clone();
    // TODO check that the file exists

    let html_content_file = File::open(&html_content_fpath).unwrap();
    let reader = BufReader::new(html_content_file);
    // let mut lines: Vec<String> = reader.lines().collect::<Result<Vec<_>, io::Error>>().unwrap();
    let mut title: String = String::new();
    let lines: Vec<String> = reader
        .lines()
        .filter_map(
            //TODO replace with regex.
            |line_result| match line_result {
                Ok(line) => {
                    if line.contains("<title>") {
                        title = line
                            .strip_prefix("<title>")
                            .unwrap()
                            .strip_suffix("</title>")
                            .unwrap()
                            .to_string();
                    }
                    if !line.contains("<img")
                        && !line.contains("<meta")
                        && !line.contains("<link")
                        && !line.contains("<title>")
                    {
                        Some(line)
                    } else {
                        None
                    }
                }
                _ => None,
            },
        )
        .collect();
    // TODO: it will probably be easier if we use w3m to dump text instead of going via raw html
    // and figuring out the tags.

    let html_content = lines.join("\n");
    println!(
        "<content:encoded><![CDATA[\n{}\n]]></content:encoded>",
        html_content
    );

    let website_url = "https://yobibyte.github.io";
    let page_full_url = format!(
        "{website_url}/{}",
        html_content_fpath.split("/").last().unwrap()
    );

    let guid = Guid {
        value: page_full_url.clone(),
        permalink: true,
    };
    let new_item = ItemBuilder::default()
        .title(title.clone())
        .guid(guid)
        .link(page_full_url)
        .pub_date(Utc::now().to_rfc2822())
        .description(title)
        .content(html_content)
        .build();

    let mut items = channel.items_mut().to_vec();
    items.push(new_item);
    channel.set_items(items);

    let file = File::create(feed_path).expect("Cannot create file");
    channel.write_to(file).unwrap(); // write to the channel to a writer
}
