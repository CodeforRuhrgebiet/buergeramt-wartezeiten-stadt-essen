class Case
  require 'open-uri'
  require 'nokogiri'
  require 'date'
  require 'mysql2'

  @type = false
  @request_path = false
  @raw_response = false
  @raw_details = false

  def initialize(key, title, path)
    @type = key
    @title = title
    @request_path = path
    timeout(15) do
      set_raw_response!
    end
    timeout(15) do
      set_detail_response!
    end
  end

  def data
    @data_cache ||= {
      beschreibung: @title,
      angefragt_timestamp: Time.now,
      standort: @raw_details.xpath('//*[@id="standort"]').last['value'],
      wartebereich: @raw_details.xpath('//*[@id="warteschlange"]').last['value'],
      adresse: @raw_details.xpath('//*[@id="adresse"]').last['value'],
      anliegen: @raw_details.xpath('//*[@id="anliegen"]').last.text,
      tag: @raw_details.xpath('//*[@id="tag"]').last['value'],
      uhrzeit: @raw_details.xpath('//*[@id="uhrzeit"]').last['value'],
      termin_timestamp: appointment,
      wartezeit: waiting_days
    }
  end

  def save_data!
    @db = Mysql2::Client.new(host: ENV['MYSQL_HOST'],
                             username: ENV['MYSQL_USER'],
                             password: ENV['MYSQL_PASSWORD'],
                             database: ENV['MYSQL_DATABASE'])

    @db.query("INSERT INTO #{ENV['MYSQL_TABLE']}}
              (
                type,
                adresse,
                angefragt_timestamp,
                standort,
                termin_timestamp,
                uhrzeit,
                wartebereich,
                wartezeit,
                beschreibung,
                tag,
                anliegen
              ) VALUES
              (
                '#{@type}',
                '#{data[:adresse]}',
                '#{data[:angefragt_timestamp]}',
                '#{data[:standort]}',
                '#{data[:termin_timestamp]}',
                '#{data[:uhrzeit]}',
                '#{data[:wartebereich]}',
                '#{data[:wartezeit]}',
                '#{data[:beschreibung]}',
                '#{data[:tag]}',
                '#{data[:anliegen]}'
              )")
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

  def date_data
    {
      angefragt_date: Date.today.to_time.to_i
    }
  end

  def current_date_timestamp
    Date.today.to_time.to_i
  end

  def current_day_entry(data)
    data.each { |entry| return entry if entry[1]['angefragt_date'] == current_date_timestamp }
    nil
  end
end
