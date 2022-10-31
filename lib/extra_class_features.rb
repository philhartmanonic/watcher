class Object
  SIZE_NAMES=['Byte', 'Kilobyte', 'Megabyte', 'Gigabyte', 'Terabyte', 'Petabyte', 'Exabyte', 'Zettabyte', 'Yottabyte'].each_with_index.map{ |x, i| [i, [x, "#{x[0]}B", "#{x[0]}B".downcase, "1024**#{i}", 1024**i]] }.to_h
  SUPS={0 => "\u2070", 1 => "\u00B9", 2 => "\u00B2", 3 => "\u00B3", 4 => "\u2074", 5 => "\u2075", 6 => "\u2076", 7 => "\u2077", 8 => "\u2078", 9 => "\u2079", "," => "\u22C5"}
  SUBS={0 => "\u2080", 1 => "\u2081", 2 => "\u2082", 3 => "\u2083", 4 => "\u2084", 5 => "\u2085", 6 => "\u2086", 7 => "\u2087", 8 => "\u2088", 9 => "\u2089", "," => ","}
  TERM_WIDTH=`tput cols`.strip.to_i
  BEST_COLOR_PAIRINGS={:black=>:bg_bright_magenta, :gray=>:bg_black, :red=>:bg_cyan, :bright_red=>:bg_bright_gray, :green=>:bg_bright_red, :bright_green=>:bg_black, :yellow=>:bg_cyan, :bright_yellow=>:bg_bright_magenta, :blue=>:bg_black, :bright_blue=>:bg_green, :magenta=>:bg_bright_cyan, :bright_magenta=>:bg_bright_gray, :bright_cyan=>:bg_red, :cyan=>:bg_green, :bright_gray=>:bg_bright_blue, :white=>:bg_black, :bg_bright_magenta=>:black, :bg_black=>:bright_green, :bg_cyan=>:yellow, :bg_bright_gray=>:bright_magenta, :bg_bright_red=>:green, :bg_green=>:bright_blue, :bg_bright_cyan=>:magenta, :bg_red=>:bright_cyan, :bg_bright_blue=>:bright_gray, :bg_yellow=>:bright_blue, :bg_blue=>:black, :bg_magenta=>:green, :bg_gray=>:black, :bg_bright_green=>:black, :bg_bright_yellow=>:bright_cyan, :bg_white=>:black}
  BEST_CODE_PAIRINGS={"\e[30m"=>:bg_bright_magenta, "\e[31m"=>:bg_cyan, "\e[32m"=>:bg_bright_red, "\e[33m"=>:bg_cyan, "\e[34m"=>:bg_black, "\e[35m"=>:bg_bright_cyan, "\e[36m"=>:bg_green, "\e[37m"=>:bg_bright_blue, "\e[90m"=>:bg_black, "\e[91m"=>:bg_bright_gray, "\e[92m"=>:bg_black, "\e[93m"=>:bg_bright_magenta, "\e[94m"=>:bg_green, "\e[95m"=>:bg_bright_gray, "\e[96m"=>:bg_red, "\e[97m"=>:bg_black, "\e[40m"=>:bright_green, "\e[41m"=>:bright_cyan, "\e[42m"=>:bright_blue, "\e[43m"=>:bright_blue, "\e[44m"=>:black, "\e[45m"=>:green, "\e[46m"=>:yellow, "\e[47m"=>:bright_magenta, "\e[100m"=>:black, "\e[101m"=>:green, "\e[102m"=>:black, "\e[103m"=>:bright_cyan, "\e[104m"=>:bright_gray, "\e[105m"=>:black, "\e[106m"=>:magenta, "\e[107m"=>:black}
  FOREGROUND_COLORS=[:black, :red, :green, :yellow, :blue, :magenta, :cyan, :bright_gray, :gray, :bright_red, :bright_green, :bright_yellow, :bright_blue, :bright_magenta, :bright_cyan, :white]
  BACKGROUND_COLORS=[:bg_black, :bg_red, :bg_green, :bg_yellow, :bg_blue, :bg_magenta, :bg_cyan, :bg_bright_gray, :bg_gray, :bg_bright_red, :bg_bright_green, :bg_bright_yellow, :bg_bright_blue, :bg_bright_magenta, :bg_bright_cyan, :bg_white]
  TEXT_EFFECTS=[:none, :bold, :dim, :italic, :italics, :underscore, :underline, :strikethrough, :blink, :longblink, :shortblink, :reverse_color, :concealed]
  ALPHANUMERICS=(('0'..'9').to_a + ('a'..'z').to_a.map{ |x| [x.upcase, x] }.flatten).sort
  LIST_OF_A_LOT_OF_CHARACTERS=('0'..'z').to_a
end

class Integer
  def commas
    self.to_s.chars.reverse.each_slice(3).to_a.map{ |x| x.reverse.join }.reverse.join(',')
  end

  def print_size
    units = ['b', 'kb', 'mb', 'gb', 'tb', 'pb', 'eb', 'zb', 'yb']
    my_unit = units.each_with_index.select{ |x, i| 1024**i >= (self * 2) }[-1]
    "#{(self.to_f / (1024**my_unit[1])).round(2).decimal_padded} #{my_unit[0]}"
  end

  def print_time
    h = (self.to_f / 60**2).floor
    m = ((self % 60**2).to_f / 60).floor
    s = self % 60
    ((h > 0 || m >= 45 ? [h] : []) + [m, s]).map{ |x| x.to_s.rjust(2, '0') }.join(':')
  end
end

class Float
  def commas
    "#{self.floor.commas}.#{self.to_s.split('.')[1]}"
  end

  def decimal_padded(decimal_length=2, commas=true)
    parts = self.to_s.split('.')
    parts[1] = (parts[1].nil? ? ("0" * decimal_length) : parts[1].ljust(decimal_length))
    parts[0] = (commas ? parts[0].to_i.commas : parts[0])
    parts.join(".")
  end

  def print_percent(roundto=2)
    parts = (self * 100).round(roundto).to_s.split('.')
    parts[0] = (parts[0].to_i < 100 ? parts[0].rjust(3) : parts[0].to_i.commas)
    parts[1] = (parts[1].nil? ? ('0' * roundto) : parts[1].ljust(roundto, '0'))
    "#{parts.join('.')}%"
  end

  def print_time
    self.round(0).print_time
  end
end

class String
  def cjust(width=screenwidth, filler=" ")
    if self.length >= width
      self
    else
      self.rjust((width.to_f / 2).floor, filler).ljust(width, filler)
    end
  end

  def padded
    self.cjust(self.length + 2)
  end

  def paired
    self.public_send(BEST_CODE_PAIRINGS[self.match(/\e\[\d{1,3}m/).to_s])
  end

  def black;                         "\e[30m#{self}\e[0m" end
  def red;                           "\e[31m#{self}\e[0m" end
  def green;                         "\e[32m#{self}\e[0m" end
  def yellow;                        "\e[33m#{self}\e[0m" end
  def blue;                          "\e[34m#{self}\e[0m" end
  def magenta;                       "\e[35m#{self}\e[0m" end
  def cyan;                          "\e[36m#{self}\e[0m" end
  def white;                         "\e[37m#{self}\e[0m" end
  def gray;                          "\e[90m#{self}\e[0m" end
  def bright_red;                    "\e[91m#{self}\e[0m" end
  def bright_green;                  "\e[92m#{self}\e[0m" end
  def bright_yellow;                 "\e[93m#{self}\e[0m" end
  def bright_blue;                   "\e[94m#{self}\e[0m" end
  def bright_magenta;                "\e[95m#{self}\e[0m" end
  def bright_cyan;                   "\e[96m#{self}\e[0m" end
  def bright_gray;                  "\e[97m#{self}\e[0m" end
  def bg_black;                      "\e[40m#{self}\e[0m" end
  def bg_red;                        "\e[41m#{self}\e[0m" end
  def bg_green;                      "\e[42m#{self}\e[0m" end
  def bg_yellow;                     "\e[43m#{self}\e[0m" end
  def bg_blue;                       "\e[44m#{self}\e[0m" end
  def bg_magenta;                    "\e[45m#{self}\e[0m" end
  def bg_cyan;                       "\e[46m#{self}\e[0m" end
  def bg_white;                      "\e[47m#{self}\e[0m" end
  def bg_gray;                       "\e[100m#{self}\e[0m" end
  def bg_bright_red;                 "\e[101m#{self}\e[0m" end
  def bg_bright_green;               "\e[102m#{self}\e[0m" end
  def bg_bright_yellow;              "\e[103m#{self}\e[0m" end
  def bg_bright_blue;                "\e[104m#{self}\e[0m" end
  def bg_bright_magenta;             "\e[105m#{self}\e[0m" end
  def bg_bright_cyan;                "\e[106m#{self}\e[0m" end
  def bg_bright_gray;               "\e[107m#{self}\e[0m" end

  def bold;                          "\e[1m#{self}\e[0m" end
  def light;                         "\e[2m#{self}\e[0m" end
  def italic;                        "\e[3m#{self}\e[0m" end
  def underline;                     "\e[4m#{self}\e[0m" end
  def blink;                         "\e[5m#{self}\e[0m" end
  def fast_blink;                    "\e[6m#{self}\e[0m" end
  def reverse_colors;                "\e[7m#{self}\e[0m" end
  def striked;                       "\e[9m#{self}\e[0m" end
  def double_underline;              "\e[21m#{self}\e[0m" end
end
