# Doesn't work yet
class String 
    class String
        # colorization
        def colorize(color_code)
          "\e[#{color_code}m#{self}\e[0m"
        end
      
        def red
          colorize(31)
        end
        
        def light_blue
            colorize(36)
        end

        def yellow
            colorize(33)
          end
      
        def green
          colorize(32)
        end
      
        def blue
          colorize(34)
        end
      
        def pink
          colorize(35)
        end
    end
end


class Player
    attr_reader :role
    attr_accessor :code

    def initialize(role)
        @role = role
        @code = []
    end

    def create_code
        puts ""
        puts "You can choose from these colors: red, orange, yellow, green, blue, pink" 
        puts "Please, give me a color code, seperated by a space, e.g. 'red orange yellow green'"
        color_code = gets.chomp.downcase.split(/\W+/)

        while color_code.size != 4 do
            puts "Sorry, but you have to provide four and not #{color_code} colors, e.g. 'red orange yellow green"

            color_code = nil
            color_code = gets.chomp.downcase.split(/\W+/)
            puts color_code.size
        end

        color_code.each do |color|
            code_pin = CodePin.new(color)
            @code << code_pin
        end

        puts ""
        puts self.get_code_colors.inspect
        return self.get_code_colors
    end

    def get_code_colors
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
        get_code_colors
    end

    # Refactor Player class to have a 2d array of guesses, so you don't need this array
    def reset_guesses
        self.code = []
    end
end


class Pin
    attr_accessor :color

    def initialize(color, allowed_colors)
        if allowed_colors.include?(color)
            @color = color
        else 
            while !(allowed_colors.include?(color))
                puts "Sorry, but #{color} is not allowed." 
                puts "Please, choose a color: #{allowed_colors.join(', ')}!"

                color = gets.chomp.downcase
            end

            self.color = color
        end
    end
end


class CodePin < Pin
    @@allowed_colors = ["red", "orange", "yellow", "green", "blue", "pink"]

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


class Game
    def initialize(codemaker, codebreaker)
        @codemaker = codemaker
        @codebreaker = codebreaker
        @past_guesses = []
        @past_feedback = []
    end

    def welcome_codemaker
        puts ""
        puts "-----------------------------------------------------------------------"
        puts "Welcome you evil man! Let's create a code to destroy the world, muhaha!"
        puts "-----------------------------------------------------------------------"
    end

    def welcome_codebreaker
        puts "-----------------------------------------------------------------------"
        puts "Welcome Agent Cody B. Reaker, please break the code and save the world!"
        puts "-----------------------------------------------------------------------"
    end

    def generate_code
        @codemaker.create_code
    end

    def one_round
        # One guess
        @past_guesses << @codebreaker.take_guess

        # Refactor data structure (guesses to 2d array), so you don't need this line of code anymore
        @past_feedback << self.give_feedback

        @codebreaker.reset_guesses  
    end

    def give_feedback
        feedback = []

        @codebreaker.get_code_colors.each_with_index do |guess, index|
            if guess == @codemaker.code[index].color 
                correct_position = FeedbackPin.new("black")
                feedback << correct_position.color
            elsif @codemaker.get_code_colors.include?(guess)
                correct_color = FeedbackPin.new("white")
                feedback << correct_color.color
            end
        end

        feedback
    end

    def win?
        if @past_feedback.include?(["black", "black", "black", "black"])
            return true
        end
        false
    end

    def start
        self.welcome_codemaker
        self.generate_code
        40.times { puts " " }

        self.welcome_codebreaker
        i = 0
        while !win? 
            self.one_round
            self.print_board
            i += 1

            # Second condition, too tired to put into the while expression 
            if (i == 12) 
                puts "-------------------------------------------------------------------------------------"
                puts "Sorry, but you couldn't solve the code in #{i} steps, you looser, pew pew, explosions!!"
                puts "-------------------------------------------------------------------------------------"
                puts ""
                return
            end
        end

        if win? 
            puts "------------------------------------------------------------------"
            puts "You won, Agent! You intelligent one of a kind %!$§(!§%*$&!!!111elf" 
            puts "------------------------------------------------------------------"
            puts ""
        end

    end

    def print_board
        puts ""
        puts "    " + "-" * 7 + " ".ljust(40) + "-" * 8
        puts "    Guesses".ljust(51) + "Feedback"
        puts "    " + "-" * 7 + " ".ljust(40) + "-" * 8

        @past_guesses.each_with_index do |guess, index|
            empty_space = " " * (47 - guess.inspect.to_s.length)

            # prepend a "0" if index is smaller 10
            if index + 1 < 10
                puts "0#{index + 1}) " + guess.inspect + empty_space + @past_feedback[index].inspect
            else 
                puts "#{index + 1}) " + guess.inspect + empty_space + @past_feedback[index].inspect
            end
        end
        puts ""
    end
end



=begin
    ToDo: 
        - Refactor code, so that the user can input abbreviations (e.g. r, r, y, y)
        - Implement AI codebreaker (the user is the codemaker)
        - Add question: Would you like to play again? Y/N
        - Add instructions to play?
        - Add real colors to console?

=end

game = Game.new(Codemaker.new, Codebreaker.new)
game.start