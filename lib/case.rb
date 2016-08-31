class Case
  require 'open-uri'
  require 'nokogiri'
  require 'date'
  require 'firebase'
  require 'firebase_token_generator'

  @firebase_key = false
  @request_path = false
  @raw_response = false
  @raw_details = false

  def initialize(key, title, path)
    @firebase_key = key
    @title = title
    @request_path = path
    set_raw_response!
    set_detail_response!
  end

  def data
    {
      beschreibung: @title,
      angefragt_timestamp: Time.now.to_i,
      standort: @raw_details.xpath('//*[@id="standort"]').last['value'],
      wartebereich: @raw_details.xpath('//*[@id="warteschlange"]').last['value'],
      adresse: @raw_details.xpath('//*[@id="adresse"]').last['value'],
      anliegen: @raw_details.xpath('//*[@id="anliegen"]').last.text,
      tag: @raw_details.xpath('//*[@id="tag"]').last['value'],
      uhrzeit: @raw_details.xpath('//*[@id="uhrzeit"]').last['value'],
      termin_timestamp: appointment.to_i,
      wartezeit: waiting_days
    }
  end

  def save_data!
    payload = { uid: @@config['firebase']['user_uuid'], password: @@config['firebase']['user_password']}
    generator = Firebase::FirebaseTokenGenerator.new(@@config['firebase']['secret'])
    @firebase_jwt = generator.create_token(payload)
    firebase = Firebase::Client.new(firebase_url)
    push_to_firebase!(firebase, @firebase_key, data)
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
    @raw_response = Nokogiri::HTML(open("#{base_url}#{@request_path}", read_timeout: 10))
  end

  def set_detail_response!
    detail_path = @raw_response.css('#standortauswahl .nav_menu2').first['href']
    @raw_details = Nokogiri::HTML(open("#{base_url}#{detail_path}", read_timeout: 10))
  end

  def base_url
    'https://meintermin.essen.de/termine/index.php'
  end

  def firebase_url
    'https://essen-buergeramt-wartezeiten.firebaseio.com/'
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

  def push_to_firebase!(firebase, key, data)
    response = firebase.get("cases/#{key}")
    if response.raw_body != 'null'
      result = JSON.parse(response.raw_body)
      current_day_entry_res = current_day_entry(result)
      if current_day_entry_res
        puts 'Updating day value..'
        node = current_day_entry_res.first
        puts "#{firebase.update("cases/#{key}/#{node}", date_data.merge(data), "auth=#{@firebase_jwt}").raw_body}"
      else
        puts 'Creating day value..'
        puts "#{firebase.push("cases/#{key}", date_data.merge(data), "auth=#{@firebase_jwt}").raw_body}"
      end
    else
      puts 'Needs to initialize!'
      puts "#{firebase.push("cases/#{key}", date_data.merge(data), "auth=#{@firebase_jwt}").raw_body}"
    end
  end
end
