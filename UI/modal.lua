local button = require "UI/button"

local modal = {
    active = false,
    title = "",
    message = "",
    buttons = {},
    width = 356,
    height = 200
}

function modal:show(title, message, options, width, height)
    self.active = true
    self.title = title or "Message"
    self.message = message or ""
    self.buttons = {}
    self.width = width or 356
    self.height = height or 200

    options = options or {
        {label = "OK", action = function() modal:close() end}
    }

    local startX = (GameConfig.windowW - (#options * 120 + (#options - 1) * 20)) / 2
    local y = (GameConfig.windowH + self.height) / 2 - 60

    for i, opt in ipairs(options) do
        local b = button:new(opt.label, function()
            opt.action()
            modal:close()
        end, 100, 40, startX + (i - 1) * 140, y)
        table.insert(self.buttons, b)
    end
end

function modal:close()
    self.active = false
    self.buttons = {}
end

function modal:draw()
    if not self.active then return end

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, GameConfig.windowW, GameConfig.windowH)

    -- Modal box
    local x = (GameConfig.windowW - self.width) / 2
    local y = (GameConfig.windowH - self.height) / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, self.width, self.height, 10, 10)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, self.width, self.height, 10, 10)

    love.graphics.setFont(love.graphics.newFont("UI/JetBrainsMono-Regular.ttf", 18))
    love.graphics.printf(self.title, x + 20, y + 20, self.width - 40, "center")

    love.graphics.setFont(love.graphics.newFont("UI/JetBrainsMono-Regular.ttf", 14))
    love.graphics.printf(self.message, x + 20, y + 80, self.width - 40, "center")

    for _, b in ipairs(self.buttons) do
        b:draw(colors.yellow, XSfont, colors.black)
    end
end

function modal:mousepressed(x, y, buttonType)
    if not self.active then return false end
    for _, b in ipairs(self.buttons) do
        b:mousepressed(x, y, buttonType)
    end
    return true -- blocks input to underlying game
end

return modal