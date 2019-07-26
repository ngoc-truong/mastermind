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

        while color_code.size != 4 do
            puts "Sorry, but you have to provide four and not #{color_code.size} colors, e.g. 'red cyan yellow green"

            color_code = nil
            color_code = gets.chomp.downcase.split(/\W+/)
            puts color_code.size
        end

        self.create_pins_with_color_code(color_code)

        puts ""
        return self.get_code_colors
    end

    def create_pins_with_color_code(color_code)
        color_code.each do |color|
            code_pin = CodePin.new(color)
            @code << code_pin
        end
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

    def get_one_random_color
        @@colors.sample
    end

    def reset 
        self.code = []
    end
end


class Codemaker < Player
    def initialize
        super("codemaker")
    end

    def reset_code 
        self.reset
    end
end


class Codebreaker < Player
    attr_accessor :black_index_color, :white_index_color

    def initialize
        super("codebreaker")
        @black_index_color = Hash.new
        @white_index_color = Hash.new
    end

    # Only renaming methods here. Functionality is (almost) the same as in parent methods
    def take_guess
        create_code_manually
    end

    def take_guess_ai
        create_code_randomly
    end

    def get_guesses
        get_code_colors
    end

    # Refactor Player class to have a 2d array of guesses, so you don't need this array
    def reset_guesses
        self.reset
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

    def start
        # Choose a role
        role = self.choose_role
        if role == "create"
            self.welcome_codemaker
            @codemaker.create_code_manually
        else 
            self.welcome_codebreaker
            @codemaker.create_code_randomly
        end

        # Play one game
        all_rounds(role)
        puts "The answer was #{self.get_solution.inspect}"
        puts ""
    end

    def start_two_player
        self.welcome_codemaker
        self.create_code_manually
        40.times { puts " " }
        self.all_rounds        
    end

    def start_user_is_codebreaker
        self.create_code_randomly
        self.welcome_codebreaker
        self.all_rounds
    end

    def start_pc_is_codebreaker
        self.welcome_codemaker
        self.create_code_manually
        self.all_rounds
    end

    def one_round
        @past_guesses << @codebreaker.take_guess
        @past_feedback << self.give_feedback
        @codebreaker.reset_guesses  
    end

    def one_round_ai
        ai_guess = ["", "", "", ""]

        # Fill the guesses with "black" guesses (correct position and color from previous guess)
        if !@codebreaker.black_index_color.empty?
            @codebreaker.black_index_color.each do |position, color| 
                position = position.to_i
                ai_guess[position] = color
            end
        end 

        # Fill guesses with "white" guesses
        # If at the current position there is a black one, let it there. If at the current position is a white one, change it to another white one or a random color (if white_index_color.size == 1)
        if !@codebreaker.white_index_color.empty? 
            ai_guess.each_with_index do |guess, index|
                # If at this position there is a black one, leave it there
                if guess == @codebreaker.black_index_color[index]
                
                # If at this position is a white one, put (if it is the only white one, put a random number, else put a random white one)
                elsif @codebreaker.white_index_color.has_value?(guess)
                    if @codebreaker.white_index_color.size == 1
                        ai_guess[index] = @codebreaker.get_one_random_color
                    else 
                        ai_guess[index] = @codebreaker.white_index_color.values.sample
                    end
                else
                    ai_guess[index] = @codebreaker.get_one_random_color
                end
            end
        end

        # First AI guess
        if ai_guess.all?("")
            ai_guess = ai_guess.map {|guess| guess = @codemaker.get_one_random_color }
        end

        # Fill empty spaces which does not match the conditionals above
        ai_guess.each do |guess| 
            if guess == ""
                ai_guess = ai_guess.map { |guess| guess = @codebreaker.get_one_random_color }
            end
        end 

        puts "The computer chooses #{ai_guess}"

        @codebreaker.create_pins_with_color_code(ai_guess)
        @past_guesses << ai_guess
        @past_feedback << self.give_feedback
        @codebreaker.reset_guesses
    end

    def all_rounds(role)
        i = 0
        while !win? 
            if role == "create"
                self.one_round_ai
            else 
                self.one_round 
            end

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

    def give_feedback 
        feedback = []
        guess_colors = @codebreaker.get_code_colors
        code_colors = @codemaker.get_code_colors

        # First look at all the black pins (correct color + position)
        guess_colors.each_with_index do |guess, index| 
            if guess == code_colors[index]
                feedback << FeedbackPin.new("black").color
                @codebreaker.black_index_color[index] = guess

                # Delete colors which were already used
                guess_colors[index] = ""
                code_colors[index] = ""
            end
        end
      
        guess_colors.each_with_index do |guess, index| 
            if code_colors.include?(guess) && guess != ""
                feedback << FeedbackPin.new("white").color
                @codebreaker.white_index_color[code_colors[code_colors.index(guess)]] = guess

                # Delete one (the first) element of the colors which were already used
                guess_colors[index] = ""
                code_colors[code_colors.index(guess)] = ""
            end
        end

        feedback
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

    def choose_role
        puts "What do you want to do? 'Guess' or 'create' a code?"
        role = gets.chomp.downcase
        incorrect_input = true

        while incorrect_input 
            if role == "guess" || role == "create"
                incorrect_input = false 
                break
            end
            puts "Sorry, but you cannot choose '#{role}'. Do you want to 'guess' or 'create' a code?"
            role = gets.chomp.downcase
        end

        role
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
                puts "0#{index + 1}) " + string_of_colors  + empty_space + @past_feedback[index].shuffle.inspect
            else 
                puts "#{index + 1}) " + string_of_colors + empty_space + @past_feedback[index].shuffle.inspect
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

while play do
    game = Game.new(Codemaker.new, Codebreaker.new)
    game.start
    puts "Do you want to play again? (y/n)"
    answer = gets.chomp.downcase
    if answer == "n"
        play = false 
        puts "Ok, tschö!"
    end
end



