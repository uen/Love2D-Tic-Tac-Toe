local CPUSTurn = false


GridSize = 3
WindowSize = 900
CellSize = WindowSize/GridSize

require('cell')


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
                print(User..' IS WINNER')
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

        --Check horizontal
        if (b.Occupier == x) then
            for k2,v2 in pairs(v) do
                if(v2.Occupier==b.Occupier) then
                    a[#a+1] = v2.Occupier
                end
            end
            if(#a >= GridSize) then
                print('WIN: 1')
                return true
            end
        end

        --Check Vertical
        for k3,v3 in pairs(v) do
            a = {}
            b = v3

            if (b.Occupier == x) then
                for k4, v4 in pairs(board) do
                    if(v4[k3].Occupier==b.Occupier) then
                        a[#a+1] = v4[k3]
                    end
                end
            end

            if(#a >= GridSize) then
                return true
            end
        end

        -- Diagonals
        a = {}
        b = Grid[1][1]
        c = {}
        d = Grid[1][GridSize]
        for i=1, GridSize do 
            for o=1, GridSize do
                if (d.Occupier == x) then       
                    if(d.Occupier == Grid[i][GridSize-o+1].Occupier) then
                        c[#c+1] = Grid[(GridSize-i)+1][o]
                    end
                end
                if(b.Occupier == x) then
                    if(b.Occupier == Grid[i][o].Occupier) then
                        a[#a+1] = Grid[i][o]
                    end
                end
            end

            if (d.Occupier == x) then

                if(#a == GridSize) then
                    return true
                end

                if(#c == GridSize) then
                    return true
                end
            end
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


function CPUTurn()
    local clone = DeepCopy(Grid) 
    for k,v in pairs(clone) do
        for k2, v2 in pairs(v) do
            if(not(IsTaken(k2,k))) then
                --This is temporary, AI coming soon
                return TakeTurn(2,k2,k)
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(255,255,255,255)
    --love.graphics.draw(board,0,0)
    love.graphics.setBackgroundColor(255,255,255)
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


function love.update(dt)
    if(CPUSTurn == true) then
        CPUTurn()
        CPUSTurn = false
    end
end

function love.mousepressed(x, y, button)
    x = math.floor(((x/(WindowSize/GridSize)+0.5)+0.5)) -- Convert mouse pos to cell position
    y = math.floor(((y/(WindowSize/GridSize)+0.5)+0.5))
    TakeTurn(1,x,y) -- User take turn
end

function love.load()
    love.window.setMode(WindowSize,WindowSize)

    -- Generate Cells
    local Cells = {}
    for i=1,GridSize do
        Grid[i] = {}
        for ix=1,GridSize do
            Grid[i][ix] = {}
            Grid[i][ix] = NewCell((ix*CellSize)-CellSize,(i*CellSize)-CellSize,CellSize,CellSize)
        end
    end
end