require 'nokogiri'
require 'http'

def get_townhall_urls
  url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'
  response = HTTP.get(url)
  doc = Nokogiri::HTML(response.to_s)

  links = page.search('//*[@id="main"]/div/div/div/article/div[3]/ul/li/div/div/p/a')  
  puts "Townhall Links: #{townhall_links}"
  
  townhall_urls = []

  townhall_links.each do |link|
    townhall_urls << "https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie#{link['href']}"
  end

  townhall_urls
end

def get_townhall_email(townhall_urls)
  emails = []

  townhall_urls.each do |townhall_url|
    response = HTTP.get(townhall_url)
    doc = Nokogiri::HTML(response.to_s)

    email = doc.xpath('//*[@id="contentContactEmail"]/span[2]/a').text.strip
    name = doc.xpath('/html/body/div/main/section[1]/div/div/div/h1').text.strip    

    emails << {name => email} unless email.empty?
  end

  emails
end

townhall_urls = get_townhall_urls
emails = get_townhall_email(townhall_urls)

puts emails
