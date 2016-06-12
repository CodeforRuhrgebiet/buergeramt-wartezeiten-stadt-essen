require 'yaml'

project_root = File.expand_path(File.dirname(__FILE__))
Dir["#{project_root}/lib/*.rb"].each {|file| require file }

@@config = YAML.load_file("#{project_root}/config.yml")

# Personalausweis beantragen
perso_data = Case.new('perso-beantragen', 'Personalausweis beantragen', '?anr=21&anwendung=332&action=open&page=standortauswahl&tasks=810&kuerzel=nPA&schlangen=2-31-34-20-18-25-5-23-36')
perso_data.save_data!

# Anmeldung in Essen
anmelde_data = Case.new('anmeldung','Anmeldung in Essen', '?anr=21&anwendung=332&action=open&page=standortauswahl&tasks=731&kuerzel=Anmeld&schlangen=2-31-34-20-18-25-5-23-36')
anmelde_data.save_data!

# Ummeldung innerhalb Essens (ohne KfZ)
ummeldung_data = Case.new('ummeldung', 'Ummeldung innerhalb Essens (ohne KfZ)', '?anr=21&anwendung=332&action=open&page=standortauswahl&tasks=1410&kuerzel=Umeldohne&schlangen=2-31-34-20-18-25-5-23-36')
ummeldung_data.save_data!
