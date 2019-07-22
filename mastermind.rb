class Player
    attr_reader :role
    attr_accessor :code

    def initialize(role)
        @role = role
        @code = []
    end

    def create_code
        # Usability-question: Is it better to get individual colors or four colors at once, seperated by comma?
        # If all at once: 1) split string to array, 2) for each item create a Pin and check whether items are allowed (already implemented in Pin class), 3) Add array to @code
        # Code will be a 2d-array

        4.times do |index| 
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


class Codemaker < Player
    def initialize
        super("codemaker")
    end
end


class Codebreaker < Player
    def initialize
        super("codebreaker")
    end

    # Only renaming methods here. Functionality is (almost) the same as in parent methods
    def take_guess
        create_code
    end

    def get_guesses
        get_code
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

=begin
    ToDo: 
        - Refactor Code, so that the user only inputs a string with four colors, e.g. "red, red, red, yellow"
        - Should also check whether input is correct
        - Implement basic game mechanics (e.g. should give_feedback() be a Game or a Codemaker method?)
        - Implement AI codebreaker (the user is the codemaker)
=end