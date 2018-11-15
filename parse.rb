require 'open-uri'
require 'nokogiri'
require 'json'
require 'yaml'

require 'pp'



class Formula < Array
  def initialize(pair,type)
    @type = type
    self.push(*pair)
  end

  def dump
    puts sprintf("%s",self)
  end

end

class PairNode < Array
  def initialize()
  end

  def dump
    each{|leaf|leaf.dump}
  end

end

class Monster
  attr_accessor :name,:system,:c_rank,:rank,:size,:pairs,:methods

  def dump
    puts sprintf("%s:%s",@name,@methods)
    puts "===================="
    @pairs.dump
  end
end

class MonsterNode < Array

  def search(name)
    find{|mons|mons.name == name}
  end

  def tree(name,done)

    mons = search(name)
    if mons.nil?
      puts "fin."
      return
    end

    done.push(mons.name)
    done.uniq!

    mons.dump
    puts

    mons.pairs.each{|pairs|
      pairs.uniq.each{|parent|
        if done.find{|m|m == parent} 
          puts parent, "skip"
          next 
        end
        puts "--------------------"
        tree(parent,done)

      }
    }
  end

  def dump
    each{|mons|mons.dump}
  end
end

f = File.open('./BtoSS.htm')

# page = URI.parse(url).read
doc = Nokogiri::HTML(f)

mons_node = MonsterNode.new()


arrayMons = doc.xpath("//*[@class='weprow']")
arrayMons.each_with_index {|trs,i|

  node = PairNode.new()
  mons = Monster.new()

  next if i == 0
  mons.name    = trs.xpath('td[1]').text.strip
  mons.system  = trs.xpath('td[2]').text.strip
  mons.c_rank  = trs.xpath('td[3]').text.strip
  mons.rank    = trs.xpath('td[4]').text.strip
  mons.size    = trs.xpath('td[5]').text.strip
  mons.methods = trs.xpath('td[7]').text.split(/\n/).map{|m|m.strip}

  pairs = trs.xpath('td[6]').text.strip.split(/\n/)

  pairs.each{|pair|
    if /4体/ =~ pair 
      hoge = pair.gsub(/【.+】/,"").split("×").map{|m|m.strip}
      node.push(Formula.new(hoge,"four"))

    end
    if /特/ =~ pair 
      hoge = pair.gsub(/【.+】/,"").split("×").map{|m|m.strip}
      node.push(Formula.new(hoge,"special"))

    end
    if /位/ =~ pair 
      hoge = pair.gsub(/【.+】/,"").split("×").map{|m|m.strip}
      node.push(Formula.new(hoge,"rank"))
    end
  }

  mons.pairs = node

  mons_node.push(mons)
  
}

done = []
mons_node.tree("グレイトドラゴン",done)

