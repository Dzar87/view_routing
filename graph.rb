require 'priority_queue'

class Graph
  MAXINT = (2**(0.size * 8 - 2) - 1)

  def initialize(views={})
    @matrix = {}
    @vertices = Hash.new { | h, k | h[k] = {} }
    @button_vertices = Hash.new { | h, k | h[k] = {}}
    return if views.empty?
    self.create_matrix(views)
  end

  def add_vertex(name, edges)
    edges.each do | key, value |
      # For calculating path
      @vertices[name][key] = value[1]
      # For finding correct button
      @button_vertices[name][key] = value[0]
    end
  end

  def shortest_path(start, finish)
    distances = {}
    previous = {}
    nodes = PriorityQueue.new

    @vertices.each do | vertex, _value |
      if vertex == start
        distances[vertex]= 0
        nodes[vertex] = 0
      else
        distances[vertex] = MAXINT
        nodes[vertex] = MAXINT
      end
      previous[vertex] = nil
    end

    while nodes
      smallest = nodes.delete_min_return_key

      if smallest == finish
        path = {}
        following = nil
        puts smallest.inspect
        while previous[smallest]
          if  !following
            #path[smallest] = nil
          else
            path[smallest] = @button_vertices[smallest][following]
          end
          following = smallest
          smallest = previous[smallest]
        end
        path[smallest] = @button_vertices[smallest][following]

        path = path.to_a.reverse.to_h
        return path
      end

      if smallest == nil or distances[smallest] == MAXINT
        puts "No available path from #{start} to #{finish}"
        return nil
      end

      @vertices[smallest].each do | neighbor, _value |
        alt = distances[smallest] + @vertices[smallest][neighbor]
        if alt < distances[neighbor]
          distances[neighbor] = alt
          previous[neighbor] = smallest
          nodes[neighbor] = alt
        end
      end
    end

    distances.inspect
  end

  def get_button(node, vertex)
    @button_vertices[node][vertex]
  end

  def to_s
    @vertices.each do | key, value |
      puts "#{key}: #{value}"
    end
    #@vertices.inspect
  end

  def create_matrix(views)
    views.each do | view_key, view_value |

      # Matrix does not have view_key
      if !@matrix.key?(view_key)
        @matrix[view_key] = view_value

      # Matrix has the view_key
      else
        view_value.each do | k, v |
          @matrix[view_key][k] = v
        end
      end

      # Add empty row hash for uncontained edge
      @matrix[view_key].each do | button_key, _button_value |
        next if button_key == :nativeback
        unless @matrix.key?(button_key)
          @matrix[button_key] = {}
        end
      end

      # Populate the empty hashes and expand the existing ones.
      @matrix.each do | key, _value |
        @matrix.keys.each do | node |
          unless @matrix[key].key?(node)
            @matrix[key][node] = [nil, MAXINT]
          end
        end
      end
    end

    # add_vertex
    @matrix.each do | node, vertex |
      self.add_vertex(node, vertex)
    end

    @matrix
  end

  def remove_vertex(node, vertex)
    @matrix[node][vertex] = [nil, MAXINT]
    @vertices[node][vertex] = MAXINT
    @button_vertices[node][vertex] = nil
  end

  alias_method :update_matrix, :create_matrix

end

if __FILE__ == $0
  # Sliders = 1, popups = 2, viewchange = 3, toggle = 4
  #views = {
  #  main: { levelselect: [:playbutton, 3], settings: [:settingsbutton, 1] },
  # levelselect: { main: [:backbutton, 3], facebook: [:facebookbutton, 2] },
  #  settings: { music: [:musicbutton, 4], sound: [:soundbutton, 4], credits: [:creditsbutton, 2]}
  #}
  views = {
      main: { levelselect: [:playbutton, 1], settings: [:settingsbutton, 1] },
      levelselect: { main: [:backbutton, 1], facebook: [:facebookbutton, 1] },
      settings: { music: [:musicbutton, 1], sound: [:soundbutton, 1], credits: [:creditsbutton, 1]}
  }
  #matrix =
  g = Graph.new(views)
  #g.create_matrix(views)
  #matrix.each do | node, vertex |
  #  g.add_vertex(node, vertex)
  #end
  #puts g.to_s
  puts g.shortest_path(:levelselect, :sound)
  #puts g.to_s

  views[:main][:mainfacebook] = [:mainFacebookButton, 1]
  g.create_matrix(views)

  #matrix.each do | node, vertex |
  #  g.add_vertex(node, vertex)
  #end

  puts g.shortest_path(:main, :mainfacebook)
  #puts g.to_s

  views[:levelselect][:settings] = [:settingsbutton, 1]
  g.create_matrix(views)
  puts g.shortest_path(:levelselect, :sound)

  g.remove_vertex(:levelselect, :settings)
  puts g.shortest_path(:levelselect, :sound)

  puts g.shortest_path(:credits, :main)
end

=begin
  while priorityqueue.popqueue
    case event
    when derp, herp
      add nodes andvertex to matrix
      start priorityqueue for moving, has popup handling
      do event stuff

    when popup
      check if popup is event/buttons exists
      if yes click it away
      else next
    when
=end