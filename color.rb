class String  
  def docolor(code)
    "\e[#{code}m#{self}\e[0m"
  end

  def red
    docolor(31)
  end

  def green
    docolor(32)
  end

  def blue
    docolor(34)
  end

end