local utils = {}

local colors = {
  alphaBlack = {0, 0, 0, 0.7},
  white = {1, 1, 1},
  gray = {0.5, 0.5, 0.5},
  green = {0, 1, 0},
  red = {1, 0, 0},
  blue = {0.154, 0.698, 0.916}, -- LÖVE blue
  yellow = {1, 1, 0},
  orange = {1, 0.5, 0},
}

utils.colors = colors

--simplified background drawing
utils.drawBackground = function (manager, dialog)
  local dialogWidth = manager.viewportW * 0.9
  local xPos = (manager.viewportW - dialogWidth) / 2 + 80
  
  --drawing the background without the stencil (idk why the stencil didnt want to move)
  love.graphics.setColor((dialog.background and dialog.background.color) or manager.bgColor)
  love.graphics.rectangle(
    'fill',
    xPos,
    dialog.y + manager.margin,
    dialogWidth,
    dialog.backgroundH,
    manager.cornerRadius,
    manager.cornerRadius
  )
  
  if dialog.background and dialog.background.image then
    love.graphics.setColor(dialog.background.color or colors.white)

    if dialog.background.type == manager.backgroundTypes.normal then
      love.graphics.draw(dialog.background.image, 0, math.floor(dialog.y))
    elseif dialog.background.type == manager.backgroundTypes.tiled then
    elseif dialog.background.type == manager.backgroundTypes.clamped then
      love.graphics.draw(
        dialog.background.image,
        dialog.backgroundQuad,
        math.floor(xPos),
        math.floor(dialog.y + manager.margin))
      love.graphics.draw(
        dialog.background.image,
        dialog.backgroundQuad,
        math.floor(xPos + dialog.quadWidth * 2),
        math.floor(dialog.y + manager.margin + dialog.quadHeight * 2), 0, -1)
      love.graphics.draw(
        dialog.background.image,
        dialog.backgroundQuad,
        math.floor(xPos),
        math.floor(dialog.y + manager.margin + dialog.quadHeight * 2), 0, 1, -1)
      love.graphics.draw(
        dialog.background.image,
        dialog.backgroundQuad,
        math.floor(xPos + dialog.quadWidth * 2),
        math.floor(dialog.y + manager.margin), 0, -1, 1)
    end
  end
  
  if dialog.title then
    local titleBackgroundY = dialog.y + manager.margin - manager.lineHeight

    if dialog.top then
      titleBackgroundY = dialog.y + dialog.height - manager.margin - manager.lineHeight
    end

    love.graphics.setColor((dialog.background and dialog.background.color) or manager.bgColor)
    love.graphics.rectangle(
      'fill',
      math.floor(xPos),
      math.floor(titleBackgroundY),
      math.floor(manager.font:getWidth(dialog.title) + manager.horizontalPadding * 2),
      math.floor(manager.lineHeight * 2),
      manager.cornerRadius,
      manager.cornerRadius
    )
  end

  if manager.debug then
    love.graphics.setColor(colors.orange)
    love.graphics.rectangle('line', 0, dialog.y, manager.viewportW, dialog.height)
    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle('line',
      xPos,
      dialog.y + manager.margin,
      dialogWidth,
      dialog.height - manager.margin * 2
    )

    if dialog.title then
      local titleBackgroundY = dialog.y + manager.margin - manager.lineHeight
      if dialog.top then
        titleBackgroundY = dialog.y + dialog.height - manager.margin - manager.lineHeight
      end

      love.graphics.rectangle('line',
        math.floor(xPos),
        math.floor(titleBackgroundY),
        math.floor(manager.font:getWidth(dialog.title) + manager.horizontalPadding * 2),
        math.floor(manager.lineHeight * 2)
      )
    end
  end
end

utils.printTitle = function (manager, dialog)
  if not dialog.title then return end

  local dialogWidth = manager.viewportW * 0.9
  local xPos = (manager.viewportW - dialogWidth) / 2 + 80

  love.graphics.setColor(dialog.titleColor or colors.blue)
  local titleY = dialog.y + manager.margin - manager.lineHeight / 2
  if dialog.top then
    titleY = dialog.y + dialog.height - manager.margin
  else
    titleY = titleY - (manager.font:getHeight() / 4)
  end

  love.graphics.print(dialog.title,
    math.floor(xPos + manager.horizontalPadding / 2),
    math.floor(titleY))
end

utils.printText = function (manager, dialog, firstLine, lastLine, completeLine)
  local dialogWidth = manager.viewportW * 0.9
  local xPos = (manager.viewportW - dialogWidth) / 2 + 80
  
  local lineY = 0
  for n = firstLine, lastLine do
    local line = dialog.lines[n]
    local lineX = math.floor(xPos + manager.horizontalPadding)

    if dialog.image then
      lineX = lineX + dialog.image:getWidth() + manager.horizontalPadding
    end

    if not line then goto continue end
    lineY = dialog.y + manager.margin + manager.verticalPadding

    love.graphics.setColor(dialog.textColor or manager.fgColor)
    love.graphics.print(line:sub(1, (function ()
      if completeLine then
        return #line
      else
        return dialog.characterIndex
      end
    end)()),
      lineX,
      math.floor(lineY + (n - 1) * manager.lineHeight)
    )

    if manager.debug then
      love.graphics.setColor(colors.red)
      love.graphics.rectangle('line',
        lineX,
        math.floor(lineY + (n - 1) * manager.lineHeight),
        math.floor(manager.font:getWidth(line)),
        math.floor(manager.lineHeight)
      )
    end

    ::continue::
  end
end

utils.drawImage = function (manager, dialog)
  if not dialog.image then return end

  local dialogWidth = manager.viewportW * 0.9
  local xPos = (manager.viewportW - dialogWidth) / 2 + 80

  love.graphics.setColor(colors.white)
  love.graphics.draw(dialog.image,
    xPos + manager.horizontalPadding,
    dialog.y + manager.margin + manager.verticalPadding
  )
end

utils.printOptions = function (manager, dialog)
  local dialogWidth = manager.viewportW * 0.9
  local xPos = (manager.viewportW - dialogWidth) / 2 + 80
  
  local lineX = math.floor(xPos + manager.horizontalPadding)
  if dialog.image then
    lineX = lineX + dialog.image:getWidth() + manager.horizontalPadding
  end
  if dialog.options and (#dialog.optionLabels > 0) then
    local optionsY = dialog.y + dialog.height - manager.margin - manager.verticalPadding - dialog.optionsH
    for m = 1, #dialog.optionLabels do
      local label = dialog.optionLabels[m]

      love.graphics.setColor(dialog.unselectedOptionColor or colors.gray)
      if label == dialog.selectedOption then
        love.graphics.setColor(dialog.selectedOptionColor or colors.blue)
      end

      love.graphics.print(label, lineX, math.floor(optionsY + (m - 1) * manager.lineHeight) + manager.optionsSeparation)
    end
  end
end

return utils