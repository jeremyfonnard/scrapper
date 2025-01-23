require 'nokogiri'
require 'open-uri'
require 'http'
require 'rspec'


# Étape 1: Récupérer l'email d'une mairie à partir de son URL
def get_townhall_email(townhall_url)
  begin
    page = Nokogiri::HTML(URI.open(townhall_url))
  rescue StandardError => e
    puts "Erreur lors de l'accès à #{townhall_url}: #{e.message}"
    return nil
  end

  # Extraire l'email
  email = page.xpath('//*[@id="contentContactEmail"]/span[2]/a').text.strip
  email.empty? ? nil : email
end

# Étape 2 : Récupérer toutes les URLs et noms des mairies du Val-d'Oise
def get_townhall_urls(department_url)
  begin
    page = Nokogiri::HTML(URI.open("https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie"))
  rescue StandardError => e
    puts "Erreur lors de l'accès à #{department_url}: #{e.message}"
    return []
  end

  # Trouver les liens et noms des mairies
  links = page.xpath('//p[@class="fr-mb-0"]/a[@class="fr-link"]')
  urls_and_names = links.map do |link|
    {
      name: link.text.strip,
      url: URI.join("https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie", link['href']).to_s
    }
  end
  urls_and_names
end

# Étape 3 : Récupérer les emails pour toutes les mairies
def get_all_townhall_emails(department_url)
  towns = get_townhall_urls("https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie")
  emails = {}

  towns.each do |town|
    email = get_townhall_email(town[:url])
    if email
      puts "#{town[:name]} : #{email}"
      emails[town[:name]] = email
    else
      puts "Aucun email trouvé pour #{town[:name]}"
    end
  end

  emails
end

# Tester avec l'URL de l'annuaire des mairies du Val-d'Oise
department_url = "https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie"
emails = get_all_townhall_emails(department_url)

puts "\nListe des emails trouvés :"
emails.each do |name, email|
  puts "#{name} : #{email}"
end


