require "rubygems"
require "gosu"
require "chingu"
Chingu::Text.trait :asynchronous
$levels = {
	:head => [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 0, 1, 0, 0, 0, 0, 1, 1, 1],
		[1, 3, 3, 0, 0, 1, 0, 3, 0, 1],
		[1, 2, 1, 1, 1, 1, 1, 0, 1, 1],
		[1, 1, 0, 0, 0, 0, 1, 3, 1, 1],
		[1, 3, 3, 1, 0, 1, 0, 0, 1, 1],
		[1, 0, 0, 1, 0, 1, 0, 0, 0, 1],
		[1, 0, 0, 1, 0, 1, 1, 0, 1, 1],
		[1, 4, 0, 1, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
	:torso => [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 0, 3, 0, 0, 0, 0, 0, 1],
		[1, 1, 0, 3, 0, 0, 1, 0, 1, 1],
		[1, 1, 0, 3, 0, 1, 1, 3, 1, 1],
		[1, 1, 0, 2, 1, 4, 1, 0, 1, 1],
		[1, 1, 1, 1, 0, 0, 1, 0, 1, 1],
		[1, 0, 0, 0, 0, 1, 1, 0, 1, 1],
		[1, 1, 0, 1, 1, 1, 1, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
	:arms => [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 2, 1, 0, 0, 0, 0, 3, 0, 1],
		[1, 3, 1, 0, 3, 3, 0, 0, 0, 1],
		[1, 0, 1, 0, 3, 0, 0, 3, 0, 1],
		[1, 0, 1, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 1, 1, 0, 1, 0, 1, 1, 1],
		[1, 0, 1, 0, 0, 1, 0, 3, 0, 1],
		[1, 0, 3, 0, 0, 0, 1, 0, 3, 1],
		[1, 0, 1, 1, 0, 1, 0, 0, 4, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
	:track => [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 3, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 3, 0, 0, 0, 0, 0, 3, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 3, 0, 1],
		[1, 0, 0, 0, 1, 1, 0, 3, 0, 1],
		[1, 0, 0, 0, 3, 0, 0, 3, 0, 1],
		[1, 0, 0, 3, 0, 0, 0, 3, 0, 1],
		[1, 0, 0, 3, 0, 3, 3, 3, 0, 1],
		[1, 0, 0, 0, 0, 0, 2, 3, 4, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]}
$intro_texts = [
	"Bot Q-99_0E ('Helper')",
	"1045k RAM detected",
	"MEGATRANS BIOS V 1.0.99-e",
	"Last boot: 150y55d43h ago",
	"Scanning environment:",
	"** WARNING! RADIATION LEVELS ABOVE HUMAN LIVING STANDARD. EVACUATE ALL REMAINING CITIZENS",
	"** NEW DIRECTIVE: FIND ALL LIVING CITIZENS AND EVACUATE CITY",
	"Scanning area:",
	"Citizens..........0 found",
	"Bots..............0 found",
	"Living Entities...0 found",
	"Scanning bus:",
	"Main CPU...........ONLINE",
	"Visual Cortex......ONLINE",
	"Rotor Control......ONLINE",
	"Network Connection...FAILED",
	"Network unreachable!",
	"Battery Monitor....FAILED!",
	"Power levels unknown!",
	"SEEK REPAIR IMMEDIATELY",
	"Repair facilities...FAILED!",
	"Bot network.........FAILED!",
	"** NEW DIRECTIVE: BUILD REPAIR BOT",
	"Things needed:",
	"1 head",
	"1 torso (Univega Model 10 or newer)",
	"1 pair of arms",
	"1 track"]
$outro_texts = [
	"Companion parts located",
	"** WARNING! MISSING POWER CORE",
	"Scanning for power core:",
	"1 power core found. Location: Bot Q-99_0E ('Helper')",
	"** WARNING! LOW POWER! TRANSFER POWER CORE NOW!"]
class LD22 < Chingu::Window
	def setup
		@states = [Intro,
		Intermission.new(:text => "Find a head"),
		Level.new(:level => :head),
		Intermission.new(:text => "Find a torso (Univega Model 10 or newer)"),
		Level.new(:level => :torso),
		Intermission.new(:text => "Find a pair of arms"),
		Level.new(:level => :arms),
		Intermission.new(:text => "Find a track"),
		Level.new(:level => :track),
		Outro].reverse.each do |state|
			push_game_state(state, :setup => false)
		end
		current_scope.setup
		on_input(:esc) {exit}
	end
end
class Intro < Chingu::GameState
	trait :timer
	def setup
		Chingu::Text.destroy_all
		@text = Chingu::Text.create(
			$intro_texts.first,
			:max_width => $window.width,
			:size => 20,
			:font => "./DisplayOTF.otf")
		delay = 0
		$intro_texts[1..-1].each do |text|
			after(200 + rand() * 500 + delay) do
				@text.text += "\n" + text
				while(@text.image.height > $window.height)
					@text.text = @text.text.split("\n")[1..-1].join("\n")
				end
			end
			delay += 1300
		end
		after(delay + 2000) do
			@text.async do |q|
				q.tween(1000, :alpha => 0)
				q.exec {pop_game_state}
			end
		end
		on_input(:space) do
			@text.async do |q|
				q.tween(1000, :alpha => 0)
				q.exec {pop_game_state}
			end
		end
	end
end
class Outro < Chingu::GameState
	trait :timer
	def setup
		Chingu::Text.destroy_all
		@text = Chingu::Text.create(
			$outro_texts.first,
			:max_width => $window.width,
			:size => 20,
			:font => "./DisplayOTF.otf")
		delay = 0
		$outro_texts[1..-1].each do |text|
			after(200 + rand() * 500 + delay) do
				@text.text += "\n" + text
				while(@text.image.height > $window.height)
					@text.text = @text.text.split("\n")[1..-1].join("\n")
				end
			end
			delay += 1300
		end
		after(delay + 2000) do
			@text.async do |q|
				q.tween(1000, :alpha => 0)
				q.exec {pop_game_state}
			end
		end
		on_input(:space) do
			@text.async do |q|
				q.tween(1000, :alpha => 0)
				q.exec {pop_game_state}
			end
		end
	end
end
class Intermission < Chingu::GameState
	def setup
		Chingu::Text.destroy_all
		@text = Chingu::Text.create(
			@options[:text],
			:max_width => $window.width,
			:font => "./DisplayOTF.otf",
			:y => $window.height,
			:x => $window.width / 2,
			:rotation_center => :center,
			:size => 20)
		@text.async do |q|
			q.tween(1000, :y => $window.height / 2)
		end
		on_input(:space) do
			@text.async do |q|
				q.tween(1000, :alpha => 0)
				q.exec {pop_game_state if $window.current_scope == self}
				q.call :destroy
			end
		end
	end
end
class Level < Chingu::GameState
	trait :timer
	def setup
		@whoosh = Gosu::Sound["whoosh.wav"]
		after(3000 + rand() * 3000) do
			@whoosh.play
		end
		@map = $levels[@options[:level]]
		@robot = Gosu::Image["robot.png"]
		@wall = Gosu::Image["wall.png"]
		@block = Gosu::Image["block.png"]
		@part = Gosu::Image["part.png"]
		@parts = Chingu::Animation.new(:file => "parts.png")
		@parts.frame_names = {:head => 0, :torso => 1, :arms => 2, :track => 3}
		@bg_color = Gosu::Color.new(0xff888888)
		@bg_tile = Gosu::Image["bg_tile.png"]
		on_input(:up) do
			x, y = *@robot_index
			if(y > 0)
				case @map[y - 1][x]
					when 0:
					# if(@map[y - 1][x].zero?)
						@map[y][x] = 0
						@map[y - 1][x] = 2
					when 3:
					# elsif(@map[y - 1][x] == 3)
						if(y - 1 > 0 && @map[y - 2][x].zero?)
							@map[y][x] = 0
							@map[y - 1][x] = 2
							@map[y - 2][x] = 3
						end
					when 4:
						win
				end
			end
		end
		on_input(:down) do
			x, y = *@robot_index
			if(y < @map.length)
				case @map[y + 1][x]
					when 0:
					# if(@map[y + 1][x].zero?)
						@map[y][x] = 0
						@map[y + 1][x] = 2
					when 3:
					# elsif(@map[y + 1][x] == 3)
						if(y + 1 < @map.length && @map[y + 2][x].zero?)
							@map[y][x] = 0
							@map[y + 1][x] = 2
							@map[y + 2][x] = 3
						end
					when 4:
						win
				end
			end
		end
		on_input(:left) do
			x, y = *@robot_index
			if(x > 0)
				case @map[y][x - 1]
					when 0:
					# if(@map[y][x - 1].zero?)
						@map[y][x] = 0
						@map[y][x - 1] = 2
					when 3:
					# elsif(@map[y][x - 1] == 3)
						if(x - 1 > 0 && @map[y][x - 2].zero?)
							@map[y][x] = 0
							@map[y][x - 1] = 2
							@map[y][x - 2] = 3
						end
					when 4:
						win
				end	
			end
		end
		on_input(:right) do
			x, y = *@robot_index
			if(x < @map[y].length)
				case @map[y][x + 1]
					when 0:
					# if(@map[y][x + 1].zero?)
						@map[y][x] = 0
						@map[y][x + 1] = 2
					when 3:
					# elsif(@map[y][x + 1] == 3)
						if(x + 1 < @map[y].length && @map[y][x + 2].zero?)
							@map[y][x] = 0
							@map[y][x + 1] = 2
							@map[y][x + 2] = 3
						end
					when 4:
						win
				end
			end
		end
	end
	def draw
		fill(@bg_color)
		($window.height / 32).times do |y|
			($window.width / 32).times do |x|
				@bg_tile.draw(x * 32, y * 32, 0)
			end
		end
		x, y = 0, 0
		@map.each do |row|
			row.each do |col|
				case col
					when 1:
						@wall.draw(x * 32, y * 32, 0)
					when 2:
						@robot_index = [x, y]
						@robot.draw(x * 32, y * 32, 0)
					when 3:
						@block.draw(x * 32, y * 32, 0)
					when 4:
						# @part.draw(x * 32, y * 32, 0)
						@parts[@options[:level]].draw(x * 32, y * 32, 0)
				end
				x += 1
			end
			x = 0
			y += 1
		end
		super
	end
	def win
		pop_game_state if $window.current_scope == self
	end
end
LD22.new(320, 320).show