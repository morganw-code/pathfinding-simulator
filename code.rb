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

def printer(print_buffer)
    print("#{print_buffer.join()}\n")
    $printer_cache_buffer.push(print_buffer)
    $printer_active_buffer.clear()
end

def clear_cache_buffer()
    $printer_cache_buffer.clear()
end

def draw_screen()
    width = 20
    border_width = 1
    height = 10

    put_at = { :a => {:x => 10, :y => 1} }

    x = 0
    y = 0

    while(y < height)
        x = 0
        # check if inside border
        if(y > 0 && y < height - 1)
            while(x < width && $printer_active_buffer.count() < width)
                # if x is supposed to be a border
                if(x == 0 || x == width - 1)
                    $printer_active_buffer.push("N".colorize(:red))
                # if x pos is item
                elsif(x + border_width == put_at[:a][:x])
                    $printer_active_buffer.push("X".colorize(:blue))
                # else x is empty space
                else
                    $printer_active_buffer.push("0")
                end
                x += 1
            end
        else
            # print first and last frame 'borders'
            width.times {
                $printer_active_buffer.push("N".colorize(:red))
            }
        end

        printer($printer_active_buffer)
        y += 1
    end

    print("drawable_width: #{(width - border_width * 2)}\n")
    print("drawable_height: #{(height - border_width * 2)}\n")
end

draw_screen()