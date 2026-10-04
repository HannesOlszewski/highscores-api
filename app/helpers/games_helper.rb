module GamesHelper
  # Draws a number in seven-segment digits over a row of unlit "8"s, like a handheld LCD.
  def lcd_number(value, digits: 0)
    text = value.to_s
    ghost = "8" * [ digits, text.length ].max

    tag.span(class: "lcd-number") do
      tag.span(ghost, class: "ghost", aria: { hidden: true }) + tag.span(text)
    end
  end
end
