require_relative './printer.rb'

class Simulator

    attr_accessor :width, :height, :border_thickness, :drawable_width, :drawable_height, :node_list, :stats, :put_at, :traversed, :current_position, :last_position, :conflicting_values, :n_pos, :s_pos, :e_pos, :w_pos, :current_node_key, :printer

    def initialize(width, height, border_thickness)
        @width = width
        @height = height
        @border_thickness = border_thickness
        @drawable_width = @width - @border_thickness * 2
        @drawable_height = @height - @border_thickness * 2
        @node_list = {}
        @stats = { }
        @put_at = { :a => {:x => 2, :y => 2},
            :b => { :x => 19, :y => 9 },
            :wall => { :x => [2, 3, 4, 5, 6, 7, 8, 9, 10], :y => 5 },
            :ghost => {:x => 0, :y => 0}}
        @traversed = { }
        @current_position = { :x => 2, :y => 2 }
        @conflicting_values = true
        @n_pos = nil
        @s_pos = nil
        @e_pos = nil
        @w_pos = nil
        @printer = Printer.new(@width, @height, @border_thickness, self)

    end

    def run()
        # main sim loop
        while(true)
            @printer.do_frame()
            @traversed[query_symbol(@current_position[:x], @current_position[:y])] = true
            #p @traversed
            #sleep(3)
            calculate_a_star()
            @printer.print_stats()
            sleep(0.5)
        end
    end

    def calculate_a_star()
        # calculate distance
        dx = @put_at[:a][:x] - @put_at[:b][:x]
        dy = @put_at[:a][:y] - @put_at[:b][:y]

        distance = Math.sqrt(dx * dx + dy * dy)
        print("A distance from B: #{distance}\n")

        # directions
        north = @put_at[:a][:y] - 1
        south = @put_at[:a][:y] + 1
        east = @put_at[:a][:x] + 1
        west = @put_at[:a][:x] - 1

        # surrounding nodes from A
        north_x = @put_at[:a][:x]
        north_y = @put_at[:a][:y] - 1
        north_pair = [north_x, north_y]
        north_east = [@put_at[:a][:y] - 1, @put_at[:a][:x] + 1]

        south_east = [@put_at[:a][:y] + 1, @put_at[:a][:x] + 1]

        south_x = @put_at[:a][:x]
        south_y = @put_at[:a][:y] + 1
        south_pair = [south_x, south_y]
        south_west = [@put_at[:a][:y] + 1, @put_at[:a][:x] - 1]

        north_west = [@put_at[:a][:y] - 1, @put_at[:a][:x] - 1]

        east_x = @put_at[:a][:x] + 1
        east_y = @put_at[:a][:y]
        east_pair = [east_x, east_y]

        west_x = @put_at[:a][:x] - 1
        west_y = @put_at[:a][:y]
        west_pair = [west_x, west_y]

        @n_pos = query_symbol(north_x, north_y)
        @s_pos = query_symbol(south_x, south_y)
        @e_pos = query_symbol(east_x, east_y)
        @w_pos = query_symbol(west_x, west_y)
        # surrounding node calculations g cost (distance from starting node)

        north_node_x = @put_at[:a][:x] - north_pair[0]
        north_node_y = @put_at[:a][:y] - north_pair[1]
        north_g_cost = Math.sqrt(north_node_x * north_node_x + north_node_y * north_node_y)

        south_node_x = @put_at[:a][:x] - south_pair[0]
        south_node_y = @put_at[:a][:y] - south_pair[1]
        south_g_cost = Math.sqrt(south_node_x * south_node_x + south_node_y * south_node_y)

        east_node_x = @put_at[:a][:x] - east_pair[0]
        east_node_y = @put_at[:a][:y] - east_pair[1]
        east_g_cost = Math.sqrt(east_node_x * east_node_x + east_node_y * east_node_y)

        west_node_x = @put_at[:a][:x] - west_pair[0]
        west_node_y = @put_at[:a][:y] - west_pair[1]
        west_g_cost = Math.sqrt(west_node_x * west_node_x + west_node_y * west_node_y)

        # surrounding node calculations h cost (distance from end node)

        north_node_x = @put_at[:b][:x] - north_pair[0]
        north_node_y = @put_at[:b][:y] - north_pair[1]
        north_h_cost = Math.sqrt(north_node_x * north_node_x + north_node_y * north_node_y)

        south_node_x = @put_at[:b][:x] - south_pair[0]
        south_node_y = @put_at[:b][:y] - south_pair[1]
        south_h_cost = Math.sqrt(south_node_x * south_node_x + south_node_y * south_node_y)

        east_node_x = @put_at[:b][:x] - east_pair[0]
        east_node_y = @put_at[:b][:y] - east_pair[1]
        east_h_cost = Math.sqrt(east_node_x * east_node_x + east_node_y * east_node_y)

        west_node_x = @put_at[:b][:x] - west_pair[0]
        west_node_y = @put_at[:b][:y] - west_pair[1]
        west_h_cost = Math.sqrt(west_node_x * west_node_x + west_node_y * west_node_y)

        # surrounding node calculations f cost - lowest preferred (g cost + h cost)

        north_f_cost = north_g_cost + north_h_cost
        south_f_cost = south_g_cost + south_h_cost
        east_f_cost = east_g_cost + east_h_cost
        west_f_cost = west_g_cost + west_h_cost

        @stats[:gcost] = { :north => north_g_cost, :south => south_g_cost, :east => east_g_cost, :west => west_g_cost }
        @stats[:hcost] = { :north => north_h_cost, :south => south_h_cost, :east => east_h_cost, :west => west_h_cost }
        @stats[:fcost] = { :north => north_f_cost.round(0), :south => south_f_cost.round(0), :east => east_f_cost.round(0), :west => west_f_cost.round(0) }

        # calculate moves

        # if A pos != B pos
        if(!(@put_at[:a][:x] == @put_at[:b][:x] && @put_at[:a][:y] == @put_at[:b][:y]))
            if(north_y == @put_at[:wall][:y] && @put_at[:wall][:x].any?(north_x) && !is_open(north_x, north_y) || @traversed.has_key?(@n_pos))
                @stats[:hcost].delete(:north)
                @stats[:fcost].delete(:north)
            end
            if(south_y == @put_at[:wall][:y] && @put_at[:wall][:x].any?(south_x) && !is_open(south_x, south_y) || @traversed.has_key?(@s_pos))
                @stats[:hcost].delete(:south)
                @stats[:fcost].delete(:south)
            end
            if(@put_at[:wall][:x].any?(east_x) && east_y == @put_at[:wall][:y] && !is_open(east_x, east_y) || @traversed.has_key?(@e_pos))
                @stats[:hcost].delete(:east)
                @stats[:fcost].delete(:east)
            end
            if(@put_at[:wall][:x].any?(west_x) && west_y == @put_at[:wall][:y] && !is_open(west_x, west_y) || @traversed.has_key?(@w_pos))
                @stats[:hcost].delete(:west)
                @stats[:fcost].delete(:west)
            end

            calculate_move(@stats[:gcost], @stats[:hcost], @stats[:fcost])
        else
            @traversed.clear()
            while(@conflicting_values)
                x = rand(border_thickness + 1..width - @border_thickness)
                y = rand(border_thickness + 1..height - border_thickness)
                @conflicting_values = @put_at[:wall][:x].any?(x) && @put_at[:wall][:y] == y
                if(!@conflicting_values)
                    @put_at[:b][:x] = x
                    @put_at[:b][:y] = y
                end
            end

            @conflicting_values = true
        end
    end

    def lowest_direction_costs(costs)
        i = 0
        buffer = []
        sorted_costs = costs.sort_by { |k, v| v }
        while(i < sorted_costs.length)
            if(sorted_costs[i][1] == sorted_costs[0][1])
                buffer.push(sorted_costs[i][0])
            end
            i += 1
        end
    
        return buffer
    end
    
    def calculate_move(g_costs, h_costs, f_costs)
        options_f = lowest_direction_costs(f_costs)
        options_h = lowest_direction_costs(h_costs)
        direction = nil
    
        @node_list[@current_node_key][:is_open] = false
        begin
            if(options_f.length() > 1)
                if(options_h.length() > 1)
                    i = rand(0..options_h.length() - 1)
                    direction = options_h[i]
                else
                    direction = options_h[0]
                end
            else
                # pick lowest f cost
                direction = options_f[0]
            end
        rescue => ex 
            print("critical: calculate_move() exception raised on line #{__LINE__} in file #{__FILE__}.\nreason: #{ex}\n".colorize(:red))
            sleep(5)
        end
    
        # @last_node_sym = @current_node_key
        #@current_node_key = get_current_node_key()

        case(direction)
        when :north
            @put_at[:a][:y] -= 1
        when :south
            @put_at[:a][:y] += 1
        when :east
            @put_at[:a][:x] += 1
        when :west
            @put_at[:a][:x] -= 1
        else
            print("help, something is wrong!\ndirection was: #{direction}\ntraversed: #{@traversed}\n".colorize(:red))
            sleep(2)
        end
    end

    def set_current_node_key()
        # set current node symbol
        @node_list.each { |k, v|
            if(@node_list[k][:x] == @current_position[:x] && @node_list[k][:y] == @current_position[:y])
                @current_node_key = k
            end
        }
    end

    def is_open(x, y)
        # p "open #{@node_list[query_symbol(x, y).to_sym()][:is_open]} id #{@node_list[query_symbol(x, y).to_sym()][:type]}"
        # sleep(2)
        return @node_list[query_symbol(x, y)][:is_open]
    end

    def query_symbol(x, y)
        @node_list.each { |k, v|
            if(@node_list[k][:x] == x && @node_list[k][:y] == y)
                return k
            end
        }
    end
end

sim = Simulator.new(20, 10, 1)
sim.run()