class Case
  require 'open-uri'
  require 'nokogiri'
  require 'date'

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
      anfrage_datum: Time.now.to_i,
      standort: @raw_details.xpath('//*[@id="standort"]').last['value'],
      wartebereich: @raw_details.xpath('//*[@id="warteschlange"]').last['value'],
      adresse: @raw_details.xpath('//*[@id="adresse"]').last['value'],
      anliegen: @raw_details.xpath('//*[@id="anliegen"]').last.text,
      tag: @raw_details.xpath('//*[@id="tag"]').last['value'],
      uhrzeit: @raw_details.xpath('//*[@id="uhrzeit"]').last['value'],
      termin: appointment.to_i,
      wartetage: waiting_days
    }
  end

  private

  def appointment
    date_string = @raw_details.xpath('//*[@id="tag"]').last['value'].match(/(0[1-9]|[1-2][0-9]|3[0-1]).(0[1-9]|1[0-2]).[0-9]{4}/).to_s
    time_string = @raw_details.xpath('//*[@id="uhrzeit"]').last['value'].gsub(' Uhr', '')
    DateTime.strptime("#{date_string}-#{time_string}", '%d.%m.%Y-%H:%M').to_time
  end

  def waiting_days
    diff = appointment - Time.now
    (diff / (60*60*24)).to_i
  end

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
