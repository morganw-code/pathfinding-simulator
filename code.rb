=begin
    Pathfinding Simulator is a terminal-based pathfinding simulator.
    Copyright (C) 2020 Morgan Webb

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>
=end

=begin
    My goal is to eventually create a mini simple terminal engine for running pathfinding simulations visually

    tests:
    - items should never draw over borders

    TODO:
    - collision detection
=end

require 'colorize'


# printer_active_buffer is pushed to printer_cache_buffer and then wiped each line
$printer_cache_buffer = []
$printer_active_buffer = []
$time_now = nil
$time_end = nil
$drawable_width = 0
$drawable_height = 0
$i = 0
$conflicting_values = true
$open_list = {}
$current_node = {}
$current_node_sym = nil
$last_node_sym = nil
$node_count = 0
$boot = true

# positions are relative to the entire width / height
$put_at = { :a => {:x => 2, :y => 2},
            :b => { :x => 15, :y => 9 },
            :wall => { :x => [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], :y => 5 } }

def generate_node_item(id_sym, type_sym, x, y, is_open)
    $open_list[id_sym] = { :type => type_sym, :x => x, :y => y, :is_open => is_open }
end

def printer(print_buffer)
    print("#{print_buffer.join()}\n")
    $printer_cache_buffer.push(print_buffer)
    $printer_active_buffer.clear()
end

def clear_cache_buffer()
    $printer_cache_buffer.clear()
end

def redraw()
    system('clear') || system('cls')
    # $current_node.clear()
    $node_count = 0
    draw_screen()
end

def query_symbol(x, y)
    $open_list.each { |k, v|
        if($open_list[k][:x] == x && $open_list[k][:y] == y)
            return k
        end
    }
end

def draw_screen()
    width = 20
    border_width = 1
    height = 10

    x = 0
    y = 0

    $drawable_width = width - border_width * 2
    $drawable_height = height - border_width * 2

    $current_node[:x] = $put_at[:a][:x]
    $current_node[:y] = $put_at[:a][:y]

    while(y < height)
        x = 0
        # check if inside border
        while(x < width && $printer_active_buffer.count() < width)
            $node_count += 1
            # if x is supposed to be a border left and right side
            if((x == 0 || x == width - border_width) && border_width > 0)
                $printer_active_buffer.push("N".colorize(:red))
                if($boot)
                    generate_node_item("n#{$node_count}".to_sym(), :border, x, y, false)
                end
            # if y is supposed to be a border top and bottom side
            elsif((y == 0 || y == height - border_width) && border_width > 0)
                $printer_active_buffer.push("N".colorize(:red))
                if($boot)
                    generate_node_item("n#{$node_count}".to_sym(), :border, x, y, false)
                end
            # if x is item and in correct y position
            elsif(x + border_width == $put_at[:a][:x] && y + border_width == $put_at[:a][:y])
                $printer_active_buffer.push("X".colorize(:blue))
                if($boot)
                    generate_node_item("n#{$node_count}".to_sym(), :a, x, y, true)
                end
            # if x is item and in correct y position
            elsif(x + border_width == $put_at[:b][:x] && y + border_width == $put_at[:b][:y])
                $printer_active_buffer.push("X".colorize(:green))
                if($boot)
                    generate_node_item("n#{$node_count}".to_sym(), :b, x + border_width, y, true)
                end
            elsif(x + border_width == $put_at[:wall][:x][$i] && y + border_width == $put_at[:wall][:y])
                $printer_active_buffer.push("N".colorize(:red))
                if($boot)
                    generate_node_item("n#{$node_count}".to_sym(), :wall, x + border_width, y + border_width, false)
                end
                $i += 1
            # else x is empty space
            else
                generate_node_item("n#{$node_count}".to_sym(), :empty, x, y, true)
                $printer_active_buffer.push("0")
            end
            x += 1
        end
        printer($printer_active_buffer)
        $i = 0
        y += 1
    end

    # set current node symbol
    $open_list.each { |k, v|
        if($open_list[k][:x] == $current_node[:x] && $open_list[k][:y] == $current_node[:y])
            $current_node_sym = k
        end
    }

    $boot = false
    print("drawable_width: #{$drawable_width}\n")
    print("drawable_height: #{$drawable_width}\n")
    print("A: x_pos: #{$put_at[:a][:x]} y_pos: #{$put_at[:a][:y]}\n")
    print("B: x_pos: #{$put_at[:b][:x]} y_pos: #{$put_at[:b][:y]}\n")

    # calculate distance
    dx = $put_at[:a][:x] - $put_at[:b][:x]
    dy = $put_at[:a][:y] - $put_at[:b][:y]

    distance = Math.sqrt(dx * dx + dy * dy)
    print("A distance from B: #{distance}\n")

    # directions
    a_north = $put_at[:a][:y] - 1
    a_south = $put_at[:a][:y] + 1
    a_east = $put_at[:a][:x] + 1
    a_west = $put_at[:a][:x] - 1

    # surrounding nodes from A
    a_north_x = $put_at[:a][:x]
    a_north_y = $put_at[:a][:y] - 1
    a_north_pair = [a_north_x, a_north_y]
    a_north_east = [$put_at[:a][:y] - 1, $put_at[:a][:x] + 1]

    a_south_east = [$put_at[:a][:y] + 1, $put_at[:a][:x] + 1]

    a_south_x = $put_at[:a][:x]
    a_south_y = $put_at[:a][:y] + 1
    a_south_pair = [a_south_x, a_south_y]
    a_south_west = [$put_at[:a][:y] + 1, $put_at[:a][:x] - 1]

    a_north_west = [$put_at[:a][:y] - 1, $put_at[:a][:x] - 1]

    a_east_x = $put_at[:a][:x] + 1
    a_east_y = $put_at[:a][:y]
    a_east_pair = [a_east_x, a_east_y]

    a_west_x = $put_at[:a][:x] - 1
    a_west_y = $put_at[:a][:y]
    a_west_pair = [a_west_x, a_west_y]

    # surrounding node calculations g cost (distance from starting node)

    a_north_node_x = $put_at[:a][:x] - a_north_pair[0]
    a_north_node_y = $put_at[:a][:y] - a_north_pair[1]
    a_north_g_cost = Math.sqrt(a_north_node_x * a_north_node_x + a_north_node_y * a_north_node_y)

    a_south_node_x = $put_at[:a][:x] - a_south_pair[0]
    a_south_node_y = $put_at[:a][:y] - a_south_pair[1]
    a_south_g_cost = Math.sqrt(a_south_node_x * a_south_node_x + a_south_node_y * a_south_node_y)

    a_east_node_x = $put_at[:a][:x] - a_east_pair[0]
    a_east_node_y = $put_at[:a][:y] - a_east_pair[1]
    a_east_g_cost = Math.sqrt(a_east_node_x * a_east_node_x + a_east_node_y * a_east_node_y)

    a_west_node_x = $put_at[:a][:x] - a_west_pair[0]
    a_west_node_y = $put_at[:a][:y] - a_west_pair[1]
    a_west_g_cost = Math.sqrt(a_west_node_x * a_west_node_x + a_west_node_y * a_west_node_y)

    # surrounding node calculations h cost (distance from end node)

    a_north_node_x = $put_at[:b][:x] - a_north_pair[0]
    a_north_node_y = $put_at[:b][:y] - a_north_pair[1]
    a_north_h_cost = Math.sqrt(a_north_node_x * a_north_node_x + a_north_node_y * a_north_node_y)

    a_south_node_x = $put_at[:b][:x] - a_south_pair[0]
    a_south_node_y = $put_at[:b][:y] - a_south_pair[1]
    a_south_h_cost = Math.sqrt(a_south_node_x * a_south_node_x + a_south_node_y * a_south_node_y)

    a_east_node_x = $put_at[:b][:x] - a_east_pair[0]
    a_east_node_y = $put_at[:b][:y] - a_east_pair[1]
    a_east_h_cost = Math.sqrt(a_east_node_x * a_east_node_x + a_east_node_y * a_east_node_y)

    a_west_node_x = $put_at[:b][:x] - a_west_pair[0]
    a_west_node_y = $put_at[:b][:y] - a_west_pair[1]
    a_west_h_cost = Math.sqrt(a_west_node_x * a_west_node_x + a_west_node_y * a_west_node_y)

    # surrounding node calculations f cost - lowest preferred (g cost + h cost)

    a_north_f_cost = a_north_g_cost + a_north_h_cost
    a_south_f_cost = a_south_g_cost + a_south_h_cost
    a_east_f_cost = a_east_g_cost + a_east_h_cost
    a_west_f_cost = a_west_g_cost + a_west_h_cost

    print("a_north_g_cost: #{a_north_g_cost}\n")
    print("a_south_g_cost: #{a_south_g_cost}\n")
    print("a_east_g_cost: #{a_east_g_cost}\n")
    print("a_west_g_cost: #{a_west_g_cost}\n")

    print("a_north_h_cost: #{a_north_h_cost}\n")
    print("a_south_h_cost: #{a_south_h_cost}\n")
    print("a_east_h_cost: #{a_east_h_cost}\n")
    print("a_west_h_cost: #{a_west_h_cost}\n")

    print("a_north_f_cost: #{a_north_f_cost}\n")
    print("a_south_f_cost: #{a_south_f_cost}\n")
    print("a_east_f_cost: #{a_east_f_cost}\n")
    print("a_west_f_cost: #{a_west_f_cost}\n")

    g_cost = { :north => a_north_g_cost, :south => a_south_g_cost, :east => a_east_g_cost, :west => a_west_g_cost }
    h_cost = { :north => a_north_h_cost, :south => a_south_h_cost, :east => a_east_h_cost, :west => a_west_h_cost }
    f_cost = { :north => a_north_f_cost.round(0), :south => a_south_f_cost.round(0), :east => a_east_f_cost.round(0), :west => a_west_f_cost.round(0) }

    sleep(0.1)

    # if A pos != B pos
    if(!($put_at[:a][:x] == $put_at[:b][:x] && $put_at[:a][:y] == $put_at[:b][:y]))
        if(a_north_y == $put_at[:wall][:y] && $put_at[:wall][:x].any?(a_north_x) && !is_open(a_north_x, a_north_y))
            h_cost.delete(:north)
            f_cost.delete(:north)
        end
        if(a_south_y == $put_at[:wall][:y] && $put_at[:wall][:x].any?(a_south_x) && !is_open(a_south_x, a_south_y))
            h_cost.delete(:south)
            f_cost.delete(:south)
        end
        if($put_at[:wall][:x].any?(a_east_x) && a_east_y == $put_at[:wall][:y] && !is_open(a_east_x, a_east_y))
            h_cost.delete(:east)
            f_cost.delete(:east)
        end
        if($put_at[:wall][:x].any?(a_west_x) && a_west_y == $put_at[:wall][:y] && !is_open(a_west_x, a_west_y))
            h_cost.delete(:west)
            f_cost.delete(:west)
        end

        calculate_move(g_cost, h_cost, f_cost)
    else
        while($conflicting_values)
            x = rand(border_width + 1..width - border_width)
            y = rand(border_width + 1..height - border_width)
            $conflicting_values = $put_at[:wall][:x].any?(x) && $put_at[:wall][:y] == y
            if(!$conflicting_values)
                $put_at[:b][:x] = x
                $put_at[:b][:y] = y
            end
        end

        $conflicting_values = true
        redraw()
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

    $last_node_sym = $current_node_sym
    $open_list[$current_node_sym][:is_open] = false

    case(direction)
    when :north
        $put_at[:a][:y] -= 1
    when :south
        $put_at[:a][:y] += 1
    when :east
        $put_at[:a][:x] += 1
    when :west
        $put_at[:a][:x] -= 1
    else
        print("help, something is wrong!\ndirection was: #{direction}".colorize(:red))
        sleep(2)
    end

    redraw()
end

def is_open(x, y)
    # p "open #{$open_list[query_symbol(x, y).to_sym()][:is_open]} id #{$open_list[query_symbol(x, y).to_sym()][:type]}"
    # sleep(2)
    return $open_list[query_symbol(x, y).to_sym()][:is_open]
end

def animate(x = 0, y = 0)
    #$put_at[:a][:x] = x
    #$put_at[:a][:y] = y
    redraw()
end

draw_screen()