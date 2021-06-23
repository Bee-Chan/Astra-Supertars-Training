print("Astra Superstars Training Mode")
print("Hope you find this useful")
print("Made by Bee Chan")

--Defining variables


--Configurable Variables. Feel free to change these to fit preference.

local P1meterFill = true -- Defaults P1 auto-refill to false
local P2meterFill = true -- Defaults P2 auto-refill to false
local healthToggle = true -- Defaults automatic Health refill to true
local inputHistory = 11 -- Number of frames of input history shown
local scrollFromBottom = true -- Toggles scrolling the input history upwards or downwards
local xP1 = 13 -- X Position of the first frame of P1's input history.
local yP1 = 207-- Y Position of the first frame of P1's input history. 207 and 70 are recommended for scrolling from the bottom and top respectively.
local xP2 = 337-- X Position of the first frame of P2's input history.
local yP2 = 207-- Y Position of the first frame of P2's input history. 207 and 70 are recommended for scrolling from the bottom and top respectively.


--Configurable Colours. The colours "clear", "red", "green", "blue", "white", "black", "gray", "grey", "orange", "yellow", "green", "teal", "cyan", "purple" and "magenta" are available by default. Additionally you can create your own colours with rgb in the format {red,green,blue,alpha} (don't put it in quotation marks). e.g. "red" or {255,0,0}

local comboCounterActiveColour = "blue"-- Colour of the combo counter if the combo hasn't dropped



--Non-Configurable Variable. It's best if you don't change these
local playerOnePreviousHealth = playerOneHealth
local playerTwoPreviousHealth = playerTwoHealth
local playerOneHealth = memory.readbyte(0x07F52B) -- Reads Player One's current health
local playerTwoHealth = memory.readbyte(0x07F9DF) -- Reads Player Two's current health
local playerOneDamage = 0 -- Current Damage on P1
local playerTwoDamage = 0 -- Current Damage on P2
local playerOnePreviousDamage = 0 -- Value of Damage used for display
local playerTwoPreviousDamage = 0 -- Value of Damage used for display
local playerOneComboDamage = 0 -- Value of Combo Damage used for display
local playerTwoComboDamage = 0 -- Value of Combo Damage used for display
local playerOneCombo=0
local playerTwoCombo=0
local P1control=0
local P2control=0
local controlTemp=0
local P1inputs = 0
local P2inputs = 0
local P1previousinputs = 0
local P2previousinputs = 0
local inputHistoryTableP1 = {}
local inputHistoryTableP2 = {}
for i = 1, inputHistory, 1 do --Sets the table for use
	inputHistoryTableP1[i] = 0
	inputHistoryTableP2[i] = 0
end
local offset = 3
local toggleP1Gui = true
local toggleP2Gui = false
local frameLockP1=0
local frameLockP2=0
local P1recording=false
local P1playback=false
local P1recorded = {0}
local P1frameCount = 0
local P2recording=false
local P2playback=false
local P2recorded = {0}
local P2frameCount = 0
local P1Loop = false
local P2Loop = false
local frameLockP1 = 1
local frameLockP2 = 1
local P1previousDirection = 0
local P1direction=0
local P2previousDirection = 0
local P2direction=0
local displayComboCounterP1=0
local displayComboCounterP2=0
local comboCounterColourP1="white"
local comboCounterColourP2="white"
local scroll = 1
if scrollFromBottom~=true then
	scroll=-1
end
function memoryReader() -- Reads from memory and assigns variables based on the memory
	playerOnePreviousHealth = playerOneHealth -- Health Value of P1 1f ago
	playerTwoPreviousHealth = playerTwoHealth -- Health Value of P2 1f ago
	playerOneHealth = memory.readbyte(0x07F52B) -- P1 Health this frame
	playerTwoHealth = memory.readbyte(0x07F9DF) -- P2 Health this frame
	playerOnePreviousCombo = playerOneCombo -- P1s combo meter count 1f ago
	playerTwoPreviousCombo = playerTwoCombo -- P2s combo meter count 1f ago
	playerOneCombo = memory.readbyte(0x08B4D6) -- P1s Combo count this frame
	playerTwoCombo = memory.readbyte(0x07FAE6) -- P2s Combo count this frame

	end



    function gameplayLoop() --main loop for gameplay calculations

    --combo counters


        if (playerOnePreviousHealth > playerOneHealth) or (playerTwoCombo>playerTwoPreviousCombo) then
            playerOneDamage = math.abs(playerOnePreviousHealth-playerOneHealth) -- Calculates damage to P1
            if (playerTwoCombo>1 and playerTwoPreviousCombo~=0) then -- Checks to see if the combo damage counter for P2 should increase. playerTwoCombo and playerTwoPreviousCombo checks that it's not the first hit. playerTwoCombo needs to be >1 or a multihitting move will continue the combo counter.
                playerTwoComboDamage=math.abs(playerTwoComboDamage)+playerOneDamage  -- Increments Counter by the amount of damage done
            else
                playerTwoComboDamage=playerOneDamage -- Otherwise the combo damage is whatever is done
            end
            playerOnePreviousDamage = playerOneDamage -- Sets a display value for damage dealt
        end

        if (playerTwoPreviousHealth > playerTwoHealth) or (playerOneCombo>playerOnePreviousCombo) then
            playerTwoDamage = math.abs(playerTwoPreviousHealth-playerTwoHealth) -- Calculates damage to P2
            if (playerOneCombo>1 and playerOnePreviousCombo~=0) then -- Checks to see if the combo damage counter for P1 should increase. playerOneCombo and playerOnePreviousCombo checks that it's not the first hit. playerOneCombo needs to be >1 or a multihitting move will continue the combo counter.
                playerOneComboDamage=math.abs(playerOneComboDamage)+playerTwoDamage -- Increments Counter by the amount of damage done
            else
                playerOneComboDamage=playerTwoDamage -- Otherwise the combo damage is whatever is done
            end
            playerTwoPreviousDamage = playerTwoDamage -- Sets a display value for damage dealt
        end

        if playerOneCombo>=2 then
            displayComboCounterP1 = playerOneCombo
            comboCounterColourP1=comboCounterActiveColour
        else
            comboCounterColourP1="white"
        end

        if playerTwoCombo>=2 then
            displayComboCounterP2 = playerTwoCombo
            comboCounterColourP2=comboCounterActiveColour
        else
            comboCounterColourP2="white"
        end


--Health Regen

	--print(playerOnePreviousCombo..":"..playerTwoDamage..":"..playerOneCombo)
	if ((playerOnePreviousCombo>0 or playerTwoDamage~=0) and (playerOneCombo==0)) and healthToggle==true then
        	memory.writebyte(0x07F9DF, 0xC8)	--p2 health
		playerTwoDamage = 0
	end

	if ((playerTwoPreviousCombo>0 or playerOneDamage~=0) and (playerTwoCombo==0)) and healthToggle==true  then
        	memory.writebyte(0x07F52B, 0xC8)	--p1 health
		playerOneDamage = 0
	end


--Meter Refill

	if (P1meterFill == true) then
		memory.writebyte(0x07F510, 0xA0) --refills P1's meter
	end

	if P2meterFill == true then
		memory.writebyte(0x07F9C4, 0xA0) --refills P2's meter
	end
end


function guiWriter() -- Writes the GUI
	gui.text(420,140, playerOneHealth) -- P1 Health 
	gui.text(1450,140, playerTwoHealth) -- P2 Health
	gui.text(500,800,tostring(memory.readbyte(0x07F510))) -- P1's meter fill
	gui.text(1380,800,tostring(memory.readbyte(0x07F9C4))) -- P2's meter fill

	if (toggleP1Gui) then

		gui.text(540,300,"P1 Damage: ".. tostring(playerTwoPreviousDamage)) -- Damage of P1's last hit
		gui.text(540,320,"P1 Combo: ")
		gui.text(640,320, displayComboCounterP1, comboCounterColourP1) -- P1's combo count
		gui.text(540,340,"P1 Combo Damage: ".. tostring(playerOneComboDamage)) -- Damage of P1's combo in total


	end


	if (toggleP2Gui) then

		gui.text(300,50,"P2 Damage: " .. tostring(playerOnePreviousDamage)) -- Damage of P2's last hit
		gui.text(300,66,"P2 Combo: ")
		gui.text(348,66, displayComboCounterP2, comboCounterColourP2) -- P2's combo count
		gui.text(300,58,"P2 Combo Damage: " .. tostring(playerTwoComboDamage)) -- Damage of P2's combo in total


    end
end

while true do
	frame = emu.framecount()
	P1frameCount = P1frameCount+1
	P2frameCount = P2frameCount+1
	memoryReader()
	gameplayLoop()
	guiWriter()
    memory.writebyte(0x07E6D8, 0x02)
    memory.writebyte(0x07E6DA, 0x02)
    memory.writebyte(0x082C8A, 0x93)
	memory.writebyte(0x07EC64, 0x3D) -- Infinite Clock Time
	emu.frameadvance()
end
