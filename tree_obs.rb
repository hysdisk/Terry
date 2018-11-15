
class Content < Struct.new(:name,:type,:methods)
end

class Tree
  def initialize(root)
    @root = root
    @node = [root]
    @leaf = {root: Branch.new(nil,nil)}
  end
  attr_reader :root

  def add(node,id,content)
    raise "Already #{id} exists." if @node.include?(id)
    @node << id
    raise "Parent #{node} dose not exist." unless @leaf[node]
    @leaf[node].children << id
    @leaf[id] = Branch.new(node,content)
  end

  def put(id=:root,indent='')
    indent = indent + '  '
    puts "#{indent}#{id}"
    @leaf[id].children.each{|child| put(child,indent) }
  end

  def exist?(id)
    @node.include?(id)
  end

end

class Branch
  def initialize(parent,content)
    @parent = parent
    @content = content
    @children = []
  end
  attr_accessor :parent,:children
  attr_reader :content
end



def go(name,node)
  tree = Tree.new(:root)
  mons = node.find_from_name(name)

  tree.add(:root,name,Content.new(name,"",mons.methods))

  add_node_recurse(tree,name,mons,node)

  tree.put()
end

def add_node_recurse(tree,parent_name,leaf,node)

  leaf.parents.each{|parent|
    parent.each{|name|
      mons = node.find_from_name(name)
      if tree.exist?(name) 
        puts sprintf("exist:%s\n",name)
      next 
      end
      unless mons.nil?
        tree.add(parent_name,name,
                 Content.new(name,parent.type,mons.methods))

        unless parent.type == "rank"
          add_node_recurse(tree,name,mons,node)
        end
      end
    }
  }
end
