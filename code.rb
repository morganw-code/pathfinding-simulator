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
# positions are relative to the entire width / height
$put_at = { :a => {:x => 2, :y => 2},
            :b => { :x => 2, :y => 9 },
            :wall => { :x => 2, :y => 7 }}

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
    draw_screen()
end
#
def draw_screen()
    width = 30
    border_width = 1
    height = 10

    x = 0
    y = 0

    while(y < height)
        x = 0
        # check if inside border
        while(x < width && $printer_active_buffer.count() < width)
            # if x is supposed to be a border left and right side
            if((x == 0 || x == width - border_width) && border_width > 0)
                $printer_active_buffer.push("N".colorize(:red))
            # if y is supposed to be a border top and bottom side
            elsif((y == 0 || y == height - border_width) && border_width > 0)
                $printer_active_buffer.push("N".colorize(:red))
            # if x is item and in correct y position
            elsif(x + border_width == $put_at[:a][:x] && y + border_width == $put_at[:a][:y])
                $printer_active_buffer.push("X".colorize(:blue))
            # if x is item and in correct y position
            elsif(x + border_width == $put_at[:b][:x] && y + border_width == $put_at[:b][:y])
                $printer_active_buffer.push("X".colorize(:green))
            elsif(x + border_width == $put_at[:wall][:x] && y + border_width == $put_at[:wall][:y])
                $printer_active_buffer.push("N".colorize(:red))
            # else x is empty space
            else
                $printer_active_buffer.push("0")
            end
            x += 1
        end
        printer($printer_active_buffer)
        y += 1
    end

    print("drawable_width: #{(width - border_width * 2)}\n")
    print("drawable_height: #{(height - border_width * 2)}\n")
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

    f_cost = { :north => a_north_f_cost, :south => a_south_f_cost, :east => a_east_f_cost, :west => a_west_f_cost }

    sleep(0.5)

    # if A pos != B pos
    if(!($put_at[:a][:x] == $put_at[:b][:x] && $put_at[:a][:y] == $put_at[:b][:y]))
        # collision detection
        # if A surrounding node == wall pos
        if(a_north_y == $put_at[:wall][:y] && a_north_x == $put_at[:wall][:x])
            f_cost.delete(:north)
        elsif(a_south_y == $put_at[:wall][:y] && a_north_x == $put_at[:wall][:x])
            f_cost.delete(:south)
        elsif(a_east_x == $put_at[:wall][:x] && a_north_x == $put_at[:wall][:y])
            f_cost.delete(:east)
        elsif(a_west_x == $put_at[:wall][:x] && a_north_x == $put_at[:wall][:y])
            f_cost.delete(:west)
        end

        calculate_move(f_cost)
    else
        system('clear')
        print("Woo!\n".colorize(:green))
    end
end

def calculate_move(f_cost)
    # only going to worry about f cost atm

    # takes min f_cost from hash and navs accordingly
    direction = f_cost.min_by { |k, v| v }[0] # first val

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
        print("help, something is wrong!\n")
    end

    redraw()
end

def animate(x = 0, y = 0)
    #$put_at[:a][:x] = x
    #$put_at[:a][:y] = y
    redraw()
end

draw_screen()