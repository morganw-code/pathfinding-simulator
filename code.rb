=begin
    My goal is to eventually create a mini simple terminal engine for running path finding simulations visually
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

    # NNNN
    # NX  
    # N

    # define a pos
    # printer should calc where n is inside the arr
    put_at = { :a => {:x => 5, :y => 1} }

    x = 0
    y = 0

    while(y < height)
        x = 0

        # first and last 1 dimensional frame in the frame_stack_buffer should only ever
        if(y > 0 && y < height - 1)
            while(x < width && $printer_active_buffer.count() < width)
                $printer_active_buffer.push("N")
                x + border_width == put_at[:a][:x] ? $printer_active_buffer.push("X".colorize(:blue)) : false
                x += 1
            end
        else
            width.times {
                $printer_active_buffer.push("N")
            }
        end

        printer($printer_active_buffer)
        y += 1
    end
end

draw_screen()