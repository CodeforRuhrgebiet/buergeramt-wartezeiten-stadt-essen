class Case
  require 'open-uri'
  require 'nokogiri'

  @request_path = false
  @raw_response = false
  @raw_details = false

  def initialize(title, path)
    @title = title
    @request_path = path
    set_raw_response!
    set_detail_response!
  end

  def data
    {
      beschreibung: @title,
      anfrage_datum: Date.today,
      standort: @raw_details.xpath('//*[@id="standort"]').last['value'],
      wartebereich: @raw_details.xpath('//*[@id="warteschlange"]').last['value'],
      adresse: @raw_details.xpath('//*[@id="adresse"]').last['value'],
      anliegen: @raw_details.xpath('//*[@id="anliegen"]').last['value'],
      tag: @raw_details.xpath('//*[@id="tag"]').last['value'],
      uhrzeit: @raw_details.xpath('//*[@id="uhrzeit"]').last['value'],
      wartezeit: 'x tage'
    }
  end

  private

  def set_raw_response!
    @raw_response = Nokogiri::HTML(open("#{base_url}#{@request_path}"))
  end

  def set_detail_response!
    detail_path = @raw_response.css('#standortauswahl .nav_menu2').first['href']
    @raw_details = Nokogiri::HTML(open("#{base_url}#{detail_path}"))
  end
  
  def base_url
    'https://meintermin.essen.de/termine/index.php'
  end
end
