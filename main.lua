local CPUSTurn = false


GridSize = 3
WindowSize = 900
CellSize = WindowSize/GridSize
local CPUFight = false
local EnableCPU = true
local MultiPlayer = false
require('cell')

require('lib/loveframes') -- GUI


local Grid = {}

function IsTaken(x,y)

    if (Grid[y][x].Occupier == 0) then
        return false
    end
    return true
end

function TakeTurn(User,x,y)
    if not(IsTaken(x,y)) then
        if((User==2 and CPUSTurn) or (User==1 and (not CPUSTurn))) then
            Grid[y][x].Clicked(Grid[y][x], User)
            if(IsWinner(Grid,User)) then
                if(User==1)then
                    loveframes.SetState("win")
                else
                    loveframes.SetState("loose")
                end
                return
            end
            CPUSTurn = (not CPUSTurn)
        end
    end
end


function IsWinner(board, x)
    for k,v in pairs(board) do
        local b = v[1]
        local a = {}

        if ((b.Occupier == x))then
            for k2,v2 in pairs(v) do
                if not(v2.Occupier == 0) then
                    if(v2.Occupier==b.Occupier) then
                        a[#a+1] = v2.Occupier
                    end
                end
            end
            if(#a >= GridSize) then
                return true
            end
        end
    end
        --Check Vertical
        a = {}
        for i=1, GridSize do
            a= {}
            for k,v in pairs(board) do

                b=v[i]
                if(b.Occupier==x) then
                    for k2,v2 in pairs(v) do
                        if(v2.Occupier == x) then
                            if(v2.Position[1] == b.Position[1]) then
                                a[#a+1] = v2
                            end
                        end
                    end

                    if((#a >= GridSize)) then
                        return true   
                    end
                end
            end
        end
        for k,v in pairs(board) do

        -- Diagonals
        a = {}
        b = board[1][1]
        c = {}
        d = board[1][GridSize]
        for i=1, GridSize do
            --Check both at once
            if(board[i][i].Occupier==x) then
                c[#c+1]=board[i][i]
            else
                c={}
            end

            if(board[GridSize-i+1][i].Occupier==x) then
                a[#c+1]=Grid[GridSize-1+1][i]
            else
                a={}
            end
        end


        if(#c == GridSize) then
            return true
        end

        if(#a == GridSize) then
            return true
        end
    end
end


function Visualize(grid) -- Print the current grid to console
    local str2 = '|'
    local str3 = ''
    for k,v in pairs(grid) do
        local str = '|'
        for k2, v2 in pairs(v) do
            str = str..'-'..v2.Occupier..'-|'

            str2=str2..'---|'         
        end 
        
        print(str2)
        print(str)

        str = '|'
        str3 = str2
        str2 = '|'
    end
    print(str3)
end

function DeepCopy(orig) -- From Stack Overflow
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end


function CPUTurn(id,opponent)
    --Somebody optimise this

    local clone = DeepCopy(Grid)
    local count = 0
    --Can we win?
    for k,v in pairs(clone) do
        for k2, v2 in pairs(v) do
            if not(v2.Occupier == 0) then
                count=count+1
            end

            if(not(IsTaken(k2,k))) then -- Loop through non occupied cells
                clone[k][k2].Occupier = id -- Occupy the cloned cell 
                if(IsWinner(clone, id)) then -- Check if won

                    return TakeTurn(id,k2,k)
                else
                    clone[k][k2].Occupier = 0 -- Didn't win, so unoccupy it
                end
                --This is temporary, AI coming soon
            end
        end
    end

    if count == (GridSize*GridSize) then
        loveframes.SetState("draw")
        return false -- Grid full
    end

    --Can human win?
    for k,v in pairs(clone) do
        for k2,v2 in pairs(v) do
            if not(IsTaken(k2,k)) then
                clone[k][k2].Occupier = opponent
                if(IsWinner(clone, opponent)) then
                    return TakeTurn(id,k2,k)
                else
                    clone[k][k2].Occupier = 0 -- UnOccupy
                end
            end
        end
    end
    -- Human went corner? Try and take the corner opposite:
    -- Or just take any corner if not


    local available = {}
    if not(IsTaken(1,1)) then
        available[#available+1] = {1,1}
    else
        if not(IsTaken(3,3)) then
            return TakeTurn(id,3,3)
        end
    end

    if not(IsTaken(GridSize,1)) then
        available[#available+1] = {GridSize,1}
    else
        if (not(IsTaken(1,GridSize))) then
            return TakeTurn(id,1,GridSize)
        end
    end
    if not(IsTaken(1,GridSize)) then
        available[#available+1] = {1,GridSize}
    else
        if(not(IsTaken(GridSize,1))) then
            return TakeTurn(id,GridSize,1)
        end
    end

    if not(IsTaken(GridSize,GridSize)) then
        available[#available+1] = {GridSize,GridSize}
    else
        if not(IsTaken(1,1)) then
            return TakeTurn(id,1,1)
        end
    end

    -- Try to pick center
    if not(IsTaken(math.ceil(GridSize/2), math.ceil(GridSize/2))) then
        return TakeTurn(id,math.ceil(GridSize/2),math.ceil(GridSize/2))
    end


    local turn = available[math.random(#available)]
    if(turn) then
        return TakeTurn(id,turn[1],turn[2])
    end

    -- Everything cool position is taken! Go anywhere.

    x = math.random(GridSize)
    y = math.random(GridSize)
    while(IsTaken(x,y)) do
        x = math.random(GridSize)
        y = math.random(GridSize)
        // Optimise!
    end
    return TakeTurn(id,x,y)
end

function love.draw()
    love.graphics.setBackgroundColor(255,255,255)
    if not(loveframes.state == 'menu') then
        love.graphics.setColor(255,255,255,255)
        --love.graphics.draw(board,0,0)
        
        for k,v in pairs(Grid) do
            --Vertical Grid Lines .1 of normal
            love.graphics.setColor(0,0,0,255)
            love.graphics.rectangle('fill',k*CellSize,0, 1, WindowSize)

            for k2,v2 in pairs(v) do
                love.graphics.setColor(0,0,0,255)

                -- Draw cells
                v2.Draw(v2)

                --Horizontal Grid lines
                love.graphics.rectangle('fill',0,k*(CellSize), WindowSize,1)
            end
        end
    end

    loveframes.draw()
end


function love.update(dt)
    loveframes.update(dt)
    if(loveframes.state=='game') then
        if not(MultiPlayer) then
            if(CPUSTurn == true) then
                if(EnableCPU) then
                    CPUTurn(2,1)
                end
            else
                if(CPUFight) then
                    CPUTurn(1,2)
                end
            end
        end
  end
end


function love.mousepressed(x, y, button)
    if(loveframes.state=='game') then
        x = math.floor(((x/(WindowSize/GridSize)+0.5)+0.5)) -- Convert mouse pos to cell position
        y = math.floor(((y/(WindowSize/GridSize)+0.5)+0.5))
        if(button == 'l') then
            TakeTurn(1,x,y) -- User take turn
        else
            TakeTurn(2,x,y) -- User take turn
            CPUSTurn = false
        end
        
    end

    loveframes.mousepressed(x, y, button)
end

function love.load()
    love.window.setTitle('Tic Tac Toe by Manolis Vrondakis')
    math.randomseed(os.time())
    love.window.setMode(WindowSize,WindowSize)

    loveframes.SetState("menu")
    local wFrame = loveframes.Create("frame") -- Win Frame
    wFrame:SetName("You Win!")
    wFrame:SetWidth(200)
    wFrame:SetHeight(200)
    wFrame:Center()

    local wText = loveframes.Create("text", wFrame)
    wText:SetText("You win! Well done!")
    wText:CenterX()
    wText:SetY(40)

    local wButton = loveframes.Create("button",wFrame)
    wButton:SetText("Restart")
    wButton:SetWidth(100)
    wButton:CenterX()
    wButton:SetY(100)
    wButton.OnClick = function()
        loveframes.SetState("game")
    Reset()

    end
    wFrame:SetState("win")


    local dFrame = loveframes.Create("frame") -- Draw Frame
    dFrame:SetName("Draw")
    dFrame:SetWidth(200)
    dFrame:SetHeight(200)
    dFrame:Center()

    local dText = loveframes.Create("text", dFrame)
    dText:SetText("It's a draw!")
    dText:CenterX()
    dText:SetY(40)

    local dButton = loveframes.Create("button",dFrame)
    dButton:SetText("Restart")
    dButton:SetWidth(100)
    dButton:CenterX()
    dButton:SetY(100)
    dButton.OnClick = function()
    loveframes.SetState("game")
    Reset()
    end

    local dButton2 = loveframes.Create("button",dFrame)
    dButton2:SetText("Menu")
    dButton2:SetWidth(100)
    dButton2:CenterX()
    dButton2:SetY(130)
    dButton2.OnClick = function()
    loveframes.SetState("menu")

    end
    dFrame:SetState("draw")






    local lFrame = loveframes.Create("frame") -- Loose Frame
    lFrame:SetName("You Loose!")
    lFrame:SetWidth(200)
    lFrame:SetHeight(200)
    lFrame:Center()

    local lText = loveframes.Create("text", lFrame)
    lText:SetText("You lost!")
    lText:CenterX()
    lText:SetY(40)

    local lButton = loveframes.Create("button",lFrame)
    lButton:SetText("Restart")
    lButton:SetWidth(100)
    lButton:CenterX()
    lButton:SetY(100)
    lButton.OnClick = function()
        Reset()
        loveframes.SetState("game")
    end


    local lButton2 = loveframes.Create("button",lFrame)
    lButton2:SetText("Menu")
    lButton2:SetWidth(100)
    lButton2:CenterX()
    lButton2:SetY(130)
    lButton2.OnClick = function()
        loveframes.SetState("menu")
    end
    lFrame:SetState("loose")


    local frame = loveframes.Create("frame")
    frame:SetName("Settings")
    frame:SetWidth(300)
    frame:SetHeight(300)
    frame:Center()



    local Slider = loveframes.Create("slider",frame)
    Slider:SetPos(5,50)
    Slider:SetWidth(290)
    Slider:SetText("Grid Size")
    Slider:SetMinMax(3, 20)
    Slider:SetValue(3)
    Slider:SetDecimals(0)
    Slider.OnValueChanged = function(object2, value)
    GridSize = value
    end

    local checkbox1 = loveframes.Create("checkbox", frame)
    checkbox1:SetText("CPU Battle")
    checkbox1:SetPos(5, 80)
    checkbox1.OnChanged = function(object,checked)
        CPUFight = checked
    end
    
    local checkbox1 = loveframes.Create("checkbox", frame)
    checkbox1:SetText("Multiplayer")
    checkbox1:SetPos(5, 110)
    checkbox1.OnChanged = function(object,checked)
        MultiPlayer = checked
    end

    local text1 = loveframes.Create("text", frame)
    text1:SetPos(5, 30)
    text1:SetText("Grid Size")
    text1:SetFont(love.graphics.newFont(10))
    local PlayButton = loveframes.Create("button", frame)
    PlayButton:SetText("Play Tic Tac Toe")
    PlayButton:SetPos(50,130)
    PlayButton:SetWidth(290)
    PlayButton:Center()     
    PlayButton.OnClick = function(object,x,y)
    Reset()
    loveframes.SetState("game")
    end

    local text2 = loveframes.Create("text", frame)
    text2:SetFont(love.graphics.newFont(10))
    text2.Update = function(object, dt)
    object:SetPos(Slider:GetWidth() - object:GetWidth(), 30)
    object:SetText(Slider:GetValue())
    end

    frame:SetState("menu")

    local buttonMenu = loveframes.Create("button")
    buttonMenu:SetText("Return to Menu")
    buttonMenu:SetPos(5,5)
    buttonMenu:SetSize(100,20)
    buttonMenu.OnClick = function()
    loveframes.SetState("menu")
    end

    buttonMenu:SetState("game")

end

function Reset()
    local Cells = {}
    Grid = {}
    math.randomseed(os.time())
    CPUSTurn = false
    CellSize = WindowSize/GridSize
    for i=1,GridSize do
        Grid[i] = {}
        for ix=1,GridSize do
            Grid[i][ix] = {}
            Grid[i][ix] = NewCell((ix*CellSize)-CellSize,(i*CellSize)-CellSize,CellSize,CellSize)
        end
    end  
end

function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
    loveframes.keyreleased(key)
end
