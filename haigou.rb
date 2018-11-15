require 'open-uri'
require 'nokogiri'
require 'json'

require 'pp'


url = "https://dswiipspwikips3.jp/dragonquest_terry3ds/combination_a.html"


page = URI.parse(url).read
doc = Nokogiri::HTML(page,url)

# arrayMons == doc.xpath("//*[@class='weprow']")

arrayMons = doc.xpath("/html/body/div[@id='gameman']/div[@id='main']/div[@id='wiki']/div[@id='ds'][1]/table/tbody/tr")

node = {}

arrayMons.each_with_index {|trs,i|
  mons_detail = {}

  next if i == 0
  mons_detail[:name] = trs.xpath('td[2]').text
  pattern1 = trs.xpath('td[3]')
  pattern2 = trs.xpath('td[4]')
   # trs.xpath('td[3]').text.split('×')
  
  gran = []
  parents = []

  if pattern1.text.include?("特殊") then
    /（(.+)）＋（(.+)）/ =~ pattern1.text
    gran1 = $1.split('×')
    gran2 = $2.split('×')
    gran.push([gran1,gran2])
  else
    parents.push(pattern1.text.split('×'))
  end

  if pattern2.text.include?("特殊") then
    /（(.+)）＋（(.+)）/ =~ pattern2.text
    break if $1.nil?
    gran1 = $1.split('×')
    gran2 = $2.split('×')
    gran.push([gran1,gran2])
  else
    parents.push(pattern2.text.split('×'))
  end

  mons_detail[:parent] = parents
  mons_detail[:gran] = gran


  pp mons_detail
  
}










