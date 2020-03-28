require 'colorize'
#testing

$open_list = {}

class Printer
    attr_accessor :printer_cache_buffer, :printer_active_buffer, :boot , :SCREEN_WIDTH, :SCREEN_HEIGHT, :SCREEN_BORDER_THICKNESS, :SIMULATOR_INSTANCE

    def initialize(width, height, border_thickness, simulator_instance)
        @printer_cache_buffer = []
        @printer_active_buffer = []
        @boot = true
        put_at = {}
        @SCREEN_WIDTH  = width
        @SCREEN_HEIGHT = height
        @SCREEN_BORDER_THICKNESS = border_thickness
        @SIMULATOR_INSTANCE = simulator_instance
    end

    def do_frame()
        x = 0
        y = 0

        while(y < @SCREEN_HEIGHT)
            x = 0
            # check if inside border
            while(x < @SCREEN_WIDTH && @printer_active_buffer.count() < @SCREEN_WIDTH)
                # if x is supposed to be a border left and right side
                if((x == 0 || x == @SCREEN_WIDTH - @SCREEN_BORDER_THICKNESS) && @SCREEN_BORDER_THICKNESS > 0)
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :border, x, y, false)
                    end
                # if y is supposed to be a border top and bottom side
                elsif((y == 0 || y == @SCREEN_HEIGHT - @SCREEN_BORDER_THICKNESS) && @SCREEN_BORDER_THICKNESS > 0)
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :border, x, y, false)
                    end
                # if x is item and in correct y position
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:a][:x] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:a][:y])
                    @printer_active_buffer.push("X".colorize(:blue))
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :a, x, y, true)
                    end
                # if x is item and in correct y position
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:b][:x] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:b][:y])
                    @printer_active_buffer.push("X".colorize(:green))
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :b, x + @SCREEN_BORDER_THICKNESS, y, true)
                    end
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:wall][:x][$i] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:wall][:y])
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :wall, x + @SCREEN_BORDER_THICKNESS, y + @SCREEN_BORDER_THICKNESS, false)
                    end
                    $i += 1
                # else x is empty space
                else
                    @printer_active_buffer.push("0")
                    if(@boot)
                        generate_node("n#{$node_count}".to_sym(), :empty, x, y, true)
                    end
                end
                x += 1
            end
            $i = 0
            y += 1

            print_line()
        end
        @boot = false

        # stats
        # print_stats()
    end

    def print_line()
        print("#{@printer_active_buffer.join()}\n")
        @printer_cache_buffer.push(@printer_active_buffer)
        @printer_active_buffer.clear()
    end

    def print_stats()

    end

    # this should reside in sim
    def generate_node(id_sym, type_sym, x, y, is_open)
        $open_list[id_sym] = { :type => type_sym, :x => x, :y => y, :is_open => is_open }
    end
end

# testing
#printer = Printer.new(20, 10, 1)
#printer.start()