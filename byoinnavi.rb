require 'anemone'
require 'nokogiri'
require 'open-uri'
require 'csv'

names = []
tells = []
addresses = []
urls = []

Anemone.crawl("https://byoinnavi.jp/tokyo/bunkyoku/000?p=", delay: 3) do |anemone|
  anemone.focus_crawl do |page|
    page.links.keep_if do |link| 
      link.to_s.match('/byoinnavi.jp\/tokyo\/bunkyoku\/000\?p=[0-9]') 
    end
  end

  anemone.on_every_page do |page|
    doc = Nokogiri.HTML(open(page.url))

    n = 1
    clinics = doc.css(".corp_name.corp_clinic").size
    clinics.times do
      names << doc.css("#corp_list > table > tbody > tr:nth-child(#{n}) > td > div > div.corp_title > h3 > a").text.strip
      tell = doc.css("#corp_list > table > tbody > tr:nth-child(#{n}) > td > table > tbody > tr:nth-child(3) > td.clinic_tel").text.strip
      if tell == ""
        tells << "電話番号の記載なし"
      else
        tells << tell
      end
      addresses << doc.css("#corp_list > table > tbody > tr:nth-child(#{n}) > td > table > tbody > tr:nth-child(1) > td.clinic_address").text.delete("[地図]").strip
      url = doc.css("#corp_list > table > tbody > tr:nth-child(#{n}) > td > table > tbody > tr:nth-child(3) > td.url_break.clinic_url > a")[0]
      if url == nil
        urls << "URLの記載なし"
      else
        urls << url[:href]
      end
      n += 1
    end
  end
end

headers = ["病院名", "電話番号", "住所", "病院のサイトURL"]

CSV.open("byoinnavi.csv", "w") do |csv|
  csv << headers
  names.length.times do |n|
    csv << [names[n], tells[n], addresses[n], urls[n]]
  end
end
