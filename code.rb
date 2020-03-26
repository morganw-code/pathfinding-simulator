=begin
    My goal is to eventually create a mini simple terminal engine for running path finding simulations visually

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
$put_at = { :a => {:x => 2, :y => 2}, :b => { :x => 19, :y => 9 }}

def printer(print_buffer)
    print("#{print_buffer.join()}\n")
    $printer_cache_buffer.push(print_buffer)
    $printer_active_buffer.clear()
end

def clear_cache_buffer()
    $printer_cache_buffer.clear()
end

def redraw()
    system('clear')
    draw_screen()
end

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

    # surrounding node calculations
    a_north_node_x = $put_at[:a][:x] - a_north_pair[0]
    a_north_node_y = $put_at[:a][:y] - a_north_pair[1]
    a_north_g_cost = Math.sqrt(a_north_node_x * a_north_node_x + a_north_node_y * a_north_node_y)

    a_south_node_x = $put_at[:a][:x] - a_south_pair[0]
    a_south_node_y = $put_at[:a][:y] - a_south_pair[1]
    a_south_g_cost = Math.sqrt(a_south_node_x * a_south_node_x + a_south_node_y * a_south_node_y)

    print("a_north_g_cost: #{a_north_g_cost}\n")
    print("a_south_g_cost: #{a_south_g_cost}\n")

    sleep(1)
    if($put_at[:a][:x] == $put_at[:b][:x])
        animate($put_at[:a][:x], a_south)
    else
        animate(a_east, 2)
    end
end

def animate(x = 0, y = 0)
    $put_at[:a][:x] = x
    $put_at[:a][:y] = y
    redraw()
end

draw_screen()