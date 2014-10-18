local Cell = {}
Cell.Occupier = 0
Cell.Position = {0,0}
Cell.Size = {300,300}


Cell.Clicked = function(self,User)
    if not(self.Occupier == 0) then
        return
    else
        self.Occupier = User
    end
end

local cross = love.graphics.newImage("img/cross.png")
local nought = love.graphics.newImage('img/nought.png')
Cell.Draw = function(self)
    love.graphics.setColor(0,0,0,255)
    if not(self.Occupier==0) then
        if(self.Occupier == 1) then
            love.graphics.draw(cross,self.Position[1], self.Position[2], 0, CellSize/cross:getWidth(),  CellSize/cross:getWidth())
        elseif(self.Occupier==2) then
            love.graphics.draw(nought,self.Position[1], self.Position[2], 0, CellSize/cross:getWidth(),  CellSize/cross:getWidth())
        end
    end
end

function NewCell(x,y,sizex,sizey)
    local NCell = DeepCopy(Cell)
    NCell.Position = {x,y}
    NCell.Size = {sizex,sizey}
    return NCell
end
