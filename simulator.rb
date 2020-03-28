require_relative './printer.rb'

class Simulator

    attr_accessor :width, :height, :border_thickness, :drawable_width, :drawable_height, :node_list, :put_at, :current_position, :last_position, :n_pos, :s_pos, :e_pos, :w_pos, :current_node_key, :printer

    def initialize(width, height, border_thickness)
        @width = width
        @height = height
        @border_thickness = border_thickness
        @drawable_width = @width - @border_thickness * 2
        @drawable_height = @height - @border_thickness * 2


        @put_at = { :a => {:x => 2, :y => 2},
            :b => { :x => 19, :y => 9 },
            :wall => { :x => [2, 3, 4, 5, 6, 7, 8, 9, 10], :y => 5 } }


        @printer = Printer.new(@width, @height, @border_thickness, self)
    end

    def run()
        # main sim loop
        while(true)
            @printer.do_frame()
            sleep(0.5)
        end
    end
end

sim = Simulator.new(20, 10, 1)
sim.run()