require 'pp'



class Monster
end


module Factory

  require 'yaml'
  require 'nokogiri'

  class << self
    def make(url)

      doc = parse(url)

      nodeset = make_nodeset(doc)

      write_yaml(nodeset,url)
    end


    def parse(url)
      f = File.open(url)
      doc = Nokogiri::HTML(f)
      doc.xpath("//*[@class='weprow']")
    end

    def make_nodeset(doc)
      array = []
      doc.each_with_index{|trs,i|
        # next if i == 0
        hash = {}

        hash[:name]    = trs.xpath('td[1]').text.strip
        hash[:system]  = trs.xpath('td[2]').text.strip
        hash[:c_rank]  = trs.xpath('td[3]').text.strip
        hash[:rank]    = trs.xpath('td[4]').text.strip
        hash[:size]    = trs.xpath('td[5]').text.strip
        hash[:methods] = trs.xpath('td[7]').text.split(/\n/).map{|m|m.strip}

        hash[:parents] = trs.xpath('td[6]').text.strip.split(/\n/).map{|m|m.strip}

        array.push(hash)
      }
      array

    end

    def write_yaml(source,url)
      File.write("#{url}.yml",YAML.dump(source))
    end

  end

end

Factory.make("./BtoSS.htm")
Factory.make("./FtoC.htm")



