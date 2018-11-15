require 'yaml'
require 'highline'
require 'pp'

class Parent < Array
  def initialize(parent)
    push(*make_mons_array(parent))
    @type = "４体" if /4体/ =~ parent 
    @type = "特殊" if /特/  =~ parent 
    @type = "位階" if /位/  =~ parent 
  end
  attr_reader :type

  def make_mons_array(pair)
    pair.gsub(/【.+】/,"").split("×").map{|m|m.strip}
  end

  def dump
    sprintf("【%s】%s",@type,join(" X "))
  end

end


class ParentNode < Array

  def initialize(parents,child)
    @child = child
    push(*parents)
  end

  def dump
    each{|pairs|
      printf("【%s】%s\n",pairs.type,pairs.join(" X "))
    }
  end

end


class Monster
  attr_accessor :name,:system,:c_rank,:rank,:size,:parents,:methods

  def dump
    sprintf("%s:%s",@name,@methods)
  end

  def detail_dump
    sprintf("|%-4s|%3s|%-2s|%s|%-16s|%-30s",
            @system,@c_rank,@rank,@size,@name,@methods)
  end

end

class MonsterNode < Array

  def monster(name)
    find{|m|m.name == name}
  end

  def parents(name)
    find{|m|m.name == name}.parents
  end

  def detail_parents_print(name)
    parents(name).each{|parent|
      puts parent.dump
      puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
      parent.each{|pair| 
        m = monster(pair)
        puts m.detail_dump unless m.nil? 
      }
      puts '--------------------------------------------------------------------------------'
    }
  end

end


module ParentFactory
  class << self
    def make(parents,child)

      ParentNode.new(
        parents.map{|parent|Parent.new(parent)},
        child
      )
    end
  end
end


class NodeFactory

  def initialize(yml_file)
    @yml = YAML.load_file(yml_file)
  end

  def make

    nodeset = MonsterNode.new()

    @yml.each{|node|
      mons = Monster.new()

      mons.name = node[:name]
      mons.system = node[:system]
      mons.c_rank = node[:c_rank]
      mons.rank = node[:rank]
      mons.size = node[:size]
      mons.methods = node[:methods]

      mons.parents = ParentFactory.make(node[:parents],node[:name])
      nodeset.push(mons)
    }
    nodeset

  end

end

fab = NodeFactory.new("./FtoSS.yml")
node = fab.make


cli = HighLine.new

system "clear"
cli.choose {|menu|
  menu.prompt = "ようこそ！"
  menu.choice(:List) { puts "List"}
  menu.choice(:Play) { puts "Play"}
  menu.choice(:Quit) { puts "Quit"}
}

loop {
  name = cli.ask('親モンスター名') { |q| q.default = 'アンドレアル' }

  unless node.monster(name).nil?
    puts
    puts '================================================================================'
    puts node.monster(name).detail_dump
    puts '================================================================================'
    node.detail_parents_print(name)
  end

}
