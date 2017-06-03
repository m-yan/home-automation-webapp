class EnvironmentalInfo
  attr_reader :temperature, :humidity

  def initialize(temperature, humidity)
    @temperature = temperature
    @humidity = humidity
  end

  def determine_air_operating_area
    case @humidity
    when 0..20
      return 9 if @temperature.round == 24
      @temperature.in?(22..25) ? 0 : 1
    when 21..50
      return 9 if @temperature.round == 23
      @temperature.in?(21..25) ? 0 : 2
    when 51..55
      return 9 if @temperature.round == 23
      @temperature.in?(21..24) ? 0 : 2
    when 56..60
      return 9 if @temperature.round == 22
      @temperature.in?(21..24) ? 0 : 3
    when 61..65
      return 9 if @temperature.round == 22
      @temperature.in?(20..24) ? 0 : 3
    when 66..68
      @temperature.in?(18..25) ? 8 : 4
    when 69..70
      @temperature.in?(18..23) ? 8 : 4
    when 71..82
      @temperature.in?(18..23) ? 8 : 5
    when 83
      @temperature.in?(18..23) ? 8 : 6
    when 84..87
      @temperature.in?(18..22) ? 8 : 6
    when 88
      @temperature.in?(18..22) ? 8 : 7
    when 89..98
      @temperature.in?(18..21) ? 8 : 7
    when 99..100
      @temperature.in?(18..20) ? 8 : 7
    end
  end

end
