require 'pp'




class Monster 
  attr_accessor :name,:size,:rank
  def initialize(name)
    @name = name
    @size = ""
    @rank = ""
  end

end


mons = Monster.new("スライム")


pp mons.name

mons.size = "S"
mons.rank = "G"


pp mons
