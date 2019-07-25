class String 
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end
    
    def red
        colorize(31)
    end
    
    def cyan
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


class Player
    attr_reader :role
    attr_accessor :code
    @@colors = ["red", "cyan", "yellow", "green", "blue", "pink"]

    def initialize(role)
        @role = role
        @code = []
    end

    # Refactor code, so that codemaker only has one code and codebreaker can have 12 codes?
    def create_code_manually
        puts ""
        puts "You can choose from these colors: #{@@colors[0].red}, #{@@colors[1].cyan}, #{@@colors[2].yellow}, #{@@colors[3].green}, #{@@colors[4].blue}, #{@@colors[5].pink}" 
        puts "Please, give me a color code, seperated by a space, e.g. 'red cyan yellow green'"
        color_code = gets.chomp.downcase.split(/\W+/)

        if color_code[0] == "cheat"
            puts "Warum kommt der hier nicht rien?"
            puts self.get_code_colors.inspect
            puts "seltsam, hier auch?"
        end 

        while color_code.size != 4 do
            puts "Sorry, but you have to provide four and not #{color_code.size} colors, e.g. 'red cyan yellow green"

            color_code = nil
            color_code = gets.chomp.downcase.split(/\W+/)
            puts color_code.size
        end

        color_code.each do |color|
            code_pin = CodePin.new(color)
            @code << code_pin
        end

        puts ""
        return self.get_code_colors
    end

    def create_code_randomly
        4.times do 
            random_number = rand(0..5)
            code_pin = CodePin.new(@@colors[random_number])
            @code << code_pin
        end
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
        create_code_manually
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
    @@allowed_colors = ["red", "cyan", "yellow", "green", "blue", "pink"]

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

    def choose_role
        puts "What do you want to do? Guess or create a code?"
    end

    def welcome_codemaker
        puts ""
        puts "-----------------------------------------------------------------------"
        puts "Welcome you evil man! Let's create a code to destroy the world, muhaha!"
        puts "-----------------------------------------------------------------------"
    end

    def welcome_codebreaker
        puts ""
        puts <<~HEREDOC
            --------------------------------------------------------------------------------
            Welcome Agent Cody B. Reaker. 

            The world needs you! Crack the code by choosing a color code combination. You 
            can choose from six different colors. But remember: The evil knieval codemaker 
            could also have used one color multiple times.

            Our smart device will give you feedback on how good you are. If you see a black 
            pin, you got one color and its position correct. If you see a white pin, you got 
            one color correct (but not its position).

            Good luck, Agent. We are trusting you.
            --------------------------------------------------------------------------------
        HEREDOC
    end

    def create_code_manually
        @codemaker.create_code_manually
    end

    def create_code_randomly
        @codemaker.create_code_randomly
    end

    def one_round
        @past_guesses << @codebreaker.take_guess
        @past_feedback << self.give_feedback
        @codebreaker.reset_guesses  
    end


    def give_feedback 
        feedback = []
        guess_colors = @codebreaker.get_code_colors
        code_colors = @codemaker.get_code_colors

        # First look at all the black pins (correct color + position)
        guess_colors.each_with_index do |guess, index| 
            if guess == code_colors[index]
                feedback << FeedbackPin.new("black").color

                # Delete colors which were already used
                guess_colors[index] = ""
                code_colors[index] = ""
            end
        end
      
        guess_colors.each_with_index do |guess, index| 
            if code_colors.include?(guess) && guess != ""
                feedback << FeedbackPin.new("white").color

                # Delete one element of the colors which were already used
                guess_colors[index] = ""
                code_colors[code_colors.index(guess)] = ""
            end
        end

        feedback.shuffle
    end

    def get_solution
        @codemaker.get_code_colors
    end

    def win?
        if @past_feedback.include?(["black", "black", "black", "black"])
            return true
        end
        false
    end

    def start_two_player
        self.welcome_codemaker
        self.create_code_manually
        40.times { puts " " }
        self.all_rounds        
    end

    def start_user_is_codebreaker
        self.create_code_randomly
        puts self.welcome_codebreaker
        self.all_rounds
    end

    def all_rounds
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
            puts "You won, Agent! You intelligent biest monster %!$§(!§%*$&!!!111elf" 
            puts "------------------------------------------------------------------"
            puts ""
        end
    end

    def print_board
        puts ""
        puts "    " + "-" * 7 + " ".ljust(29) + "-" * 8
        puts "    Guesses".ljust(40) + "Feedback"
        puts "    " + "-" * 7 + " ".ljust(29) + "-" * 8

        @past_guesses.each_with_index do |guess, index|
            # Get the length of empty space
            num_of_characters = 0
            guess.each do |item|
                num_of_characters += item.length
            end

            empty_space = " " * (32 - num_of_characters)

            # Paint the pins in terminal
            string_of_colors = ""
            guess.each_with_index { |color, index| string_of_colors += "#{paint_to(guess)[index]} " }

            # prepend a "0" if index is smaller 10
            if index + 1 < 10
                puts "0#{index + 1}) " + string_of_colors  + empty_space + @past_feedback[index].inspect
            else 
                puts "#{index + 1}) " + string_of_colors + empty_space + @past_feedback[index].inspect
            end
        end
        puts ""
    end

    def paint_to(array_code)
        # ["red", "cyan", "yellow", "green", "blue", "pink"]

        colored_code = []

        array_code.each do |color|
            case color
            when "red"
                colored_code << color.red
            when "cyan"
                colored_code << color.cyan
            when "yellow"
                colored_code << color.yellow
            when "green"
                colored_code << color.green
            when "blue"
                colored_code << color.blue
            when "pink"
                colored_code << color.pink
            end
        end

        colored_code
    end
end


play = true

while play 
    game = Game.new(Codemaker.new, Codebreaker.new)
    game.start_user_is_codebreaker
    puts "The answer was #{game.get_solution.inspect}"
    puts ""
    puts "Do you want to play again? (y/n)"
    answer = gets.chomp.downcase 
    if answer == "n"
        puts "Ok, tschö!"
        play = false 
    end
end


=begin
    ToDo: 
        - Implement AI codebreaker (the user is the codemaker)
=end

