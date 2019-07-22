# Mastermind
In this project a version of Mastermind is built with ruby. 

## Game Objective
In mastermind two players play against each other: 1) a codebreaker and 2) a codemaker. 

The codemaker creates a code which consists of four pins. There are six different pin colors.
The code can consist of pins with the same color (e.g. "green", "green", "blue", "yellow") and the
codemaker can choose the order of the colors. 
The codebreaker will try to break the code. In the first round he must guess a random combination. 
The codemaker will then give feedback whether a) a color is correct, but not the position 
(e.g. Code: green, blue, yellow, red; Guessed code: blue, green, red, yellow all colors are correct, 
but all positions are wrong. This is indicated with a white feedback pin). Or b) a color is correct and the position
is correct (indicated by black feedback pins).

## Game rules: 
The codebreaker has a maximum of 12 trys to break the code

## Translation into object-oriented programming
### Classes
- class Players
 - role
 - code

- class Codebreaker < Player
 - take_guess()
 - get_guesses()
- class Codemaker < Player
 - create_code()
 - get_code()

- class Pin 
 - initialize() (should check whether input of user is allowed color)
 - color

- class FeedbackPin < Pin
- class CodePin < Pin

- class Game
 - welcome()
 - one_round()
 - max_round?()
 - give_feedback()
 - wrong_input?()
 - print_board()
 - update_board()
 - win? 


## Artificial intelligence
The computer can take the role as a Codemaker (creating a random code) or as a codebreaker. If the computer is a codebreaker, he should deductively decide which combination he will take for his next round (in a logical manner).