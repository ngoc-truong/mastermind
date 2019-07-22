class Player
    attr_reader :role

    def initialize(role)
        @role = role
    end
end


class Codemaker < Player
    attr_accessor :code

    def initialize
        super("codemaker")
        @code = []
    end

    def create_code
        # Usability-question: Is it better to get individual colors or four colors at once?
        4. times do |index| 
            puts "#{index + 1}. Position: Please choose a color: red, orange, yellow, green, blue, or violett."
            color = gets.chomp.downcase
            code_pin = CodePin.new(color)
            @code << code_pin
            puts self.get_code.inspect
        end
        return @code
    end

    def get_code
        colors = []
        @code.each { |item| colors << item.color }
        return colors
    end
end


class Codebreaker < Player
    def initialize
        super("codebreaker")
    end

    def take_guess
    end
end


class Pin
    attr_accessor :color

    def initialize(color, allowed_colors)
        if allowed_colors.include?(color)
            @color = color
        else 
            while !(allowed_colors.include?(color))
                puts "Sorry, but your color is not allowed." 
                puts "Please, choose a color: #{allowed_colors.join(', ')}!"

                color = gets.chomp.downcase
            end

            self.color = color
        end
    end
end


class CodePin < Pin
    @@allowed_colors = ["red", "orange", "yellow", "green", "blue", "violett"]

    def initialize(color)
        super(color, @@allowed_colors)
    end
end


class FeedbackPin < Pin
    @@allowed_colors = ["black", "white"]

    def initialize(color)
        super(color, @@allowed_colors)
    end
end
