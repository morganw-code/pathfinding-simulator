require 'colorize'
require 'terminal-table'

class Printer
    attr_accessor :printer_cache_buffer, :printer_active_buffer, :boot, :node_count, :SCREEN_WIDTH, :SCREEN_HEIGHT, :SCREEN_BORDER_THICKNESS, :SIMULATOR_INSTANCE

    def initialize(width, height, border_thickness, simulator_instance)
        @printer_cache_buffer = []
        @printer_active_buffer = []
        @boot = true
        @node_count = 0
        @SCREEN_WIDTH  = width
        @SCREEN_HEIGHT = height
        @SCREEN_BORDER_THICKNESS = border_thickness
        @SIMULATOR_INSTANCE = simulator_instance
    end

    def frame()
        x = 0
        y = 0
        i = 0
        while(y < @SCREEN_HEIGHT)
            x = 0
            # check if inside border
            while(x < @SCREEN_WIDTH && @printer_active_buffer.count() < @SCREEN_WIDTH)
                @node_count += 1
                # if x is supposed to be a border left and right side
                if((x == 0 || x == @SCREEN_WIDTH - @SCREEN_BORDER_THICKNESS) && @SCREEN_BORDER_THICKNESS > 0)
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :border, x, y, false)
                    end
                # if y is supposed to be a border top and bottom side
                elsif((y == 0 || y == @SCREEN_HEIGHT - @SCREEN_BORDER_THICKNESS) && @SCREEN_BORDER_THICKNESS > 0)
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :border, x, y, false)
                    end
                # if x is item and in correct y position
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:a][:x] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:a][:y])
                    @printer_active_buffer.push("X".colorize(:blue))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :a, x, y, true)
                    end
                # if x is item and in correct y position
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:b][:x] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:b][:y])
                    @printer_active_buffer.push("X".colorize(:green))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :b, x + @SCREEN_BORDER_THICKNESS, y, true)
                    end
                elsif(x + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:wall][:x][i] && y + @SCREEN_BORDER_THICKNESS == @SIMULATOR_INSTANCE.put_at[:wall][:y])
                    @printer_active_buffer.push("N".colorize(:red))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :wall, x + @SCREEN_BORDER_THICKNESS, y + @SCREEN_BORDER_THICKNESS, false)
                    end
                    $i += 1
                     # ghost
                elsif(@SIMULATOR_INSTANCE.traversed.has_key?("n#{@node_count}".to_sym()))
                        @printer_active_buffer.push("X".colorize(:yellow))
                # else x is empty space
                else
                    @printer_active_buffer.push("0".colorize(:black))
                    if(@boot)
                        generate_node("n#{@node_count}".to_sym(), :empty, x, y, true)
                    end
                end
                x += 1
                i += 1
            end
            $i = 0
            y += 1

            print_line()
        end
        @boot = false


        @SIMULATOR_INSTANCE.current_position[:x] = @SIMULATOR_INSTANCE.put_at[:a][:x]
        @SIMULATOR_INSTANCE.current_position[:y] = @SIMULATOR_INSTANCE.put_at[:a][:y]

        @SIMULATOR_INSTANCE.set_current_node_key()
    end

    def do_frame()
        system('clear') || system('cls')
        @node_count = 0

        frame()
    end

    def print_line()
        print("#{@printer_active_buffer.join()}\n")
        @printer_cache_buffer.push(@printer_active_buffer)
        @printer_active_buffer.clear()
    end

    def print_stats()
        rows = []
        rows << ["G COST", @SIMULATOR_INSTANCE.stats[:gcost][:north], @SIMULATOR_INSTANCE.stats[:gcost][:south], @SIMULATOR_INSTANCE.stats[:gcost][:east], @SIMULATOR_INSTANCE.stats[:gcost][:west], @SIMULATOR_INSTANCE.stats[:gcost][:north_west], @SIMULATOR_INSTANCE.stats[:gcost][:north_east], @SIMULATOR_INSTANCE.stats[:gcost][:south_west], @SIMULATOR_INSTANCE.stats[:gcost][:south_east]]
        rows << ["H COST", @SIMULATOR_INSTANCE.stats[:hcost][:north], @SIMULATOR_INSTANCE.stats[:hcost][:south], @SIMULATOR_INSTANCE.stats[:hcost][:east], @SIMULATOR_INSTANCE.stats[:hcost][:west], @SIMULATOR_INSTANCE.stats[:hcost][:north_west], @SIMULATOR_INSTANCE.stats[:hcost][:north_east], @SIMULATOR_INSTANCE.stats[:hcost][:south_west], @SIMULATOR_INSTANCE.stats[:hcost][:south_east]]
        rows << ["F COST", @SIMULATOR_INSTANCE.stats[:fcost][:north], @SIMULATOR_INSTANCE.stats[:fcost][:south], @SIMULATOR_INSTANCE.stats[:fcost][:east], @SIMULATOR_INSTANCE.stats[:fcost][:west], @SIMULATOR_INSTANCE.stats[:fcost][:north_west], @SIMULATOR_INSTANCE.stats[:fcost][:north_east], @SIMULATOR_INSTANCE.stats[:fcost][:south_west], @SIMULATOR_INSTANCE.stats[:fcost][:south_east]]
        table = Terminal::Table.new(:headings => ['COST', 'NORTH', 'SOUTH', 'EAST', 'WEST', 'NORTH_WEST', 'NORTH_EAST', 'SOUTH_WEST', 'SOUTH_EAST'], :rows => rows, :all_separators => true) 
        print "#{table}\n"
    end

    # this should reside in sim
    def generate_node(id_sym, type_sym, x, y, is_open)
        @SIMULATOR_INSTANCE.node_list[id_sym] = { :type => type_sym, :x => x, :y => y, :is_open => is_open }
    end
end

# testing
#printer = Printer.new(20, 10, 1)
#printer.start()