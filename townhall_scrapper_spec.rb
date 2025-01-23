require_relative '../lib/townhall_scraper'
require 'rspec'

RSpec.describe 'TownhallScraper' do
  describe '#get_townhall_email' do
    it 'returns the email of a townhall from its URL' do
      # URL d'exemple avec un mock
      url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/ville1'

      # Mock de la réponse HTTP pour simuler une page contenant un email
      allow(URI).to receive(:open).with(url).and_return(
        '<html><div id="contentContactEmail"><span></span><a>email1@ville.fr</a></div></html>'
      )

      email = get_townhall_email(url)
      expect(email).to eq('email1@ville.fr')
    end

    it 'returns nil if no email is found on the page' do
      url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/ville2'

      # Mock d'une page sans email
      allow(URI).to receive(:open).with(url).and_return('<html><div id="contentContactEmail"></div></html>')

      email = get_townhall_email(url)
      expect(email).to be_nil
    end
  end

  describe '#get_townhall_urls' do
    it 'returns an array of hashes with townhall names and URLs' do
      department_url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'

      # Mock de la page contenant les liens des mairies
      allow(URI).to receive(:open).with(department_url).and_return(
        '<html><p class="fr-mb-0"><a class="fr-link" href="/mairie-ville1">Ville1</a></p>' \
        '<p class="fr-mb-0"><a class="fr-link" href="/mairie-ville2">Ville2</a></p></html>'
      )

      towns = get_townhall_urls(department_url)
      expect(towns).to be_an(Array)
      expect(towns.size).to eq(2)
      expect(towns).to include({ name: 'Ville1', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville1' })
      expect(towns).to include({ name: 'Ville2', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville2' })
    end

    it 'returns an empty array if no links are found' do
      department_url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'

      # Mock d'une page sans liens
      allow(URI).to receive(:open).with(department_url).and_return('<html></html>')

      towns = get_townhall_urls(department_url)
      expect(towns).to eq([])
    end
  end

  describe '#get_all_townhall_emails' do
    it 'returns a hash of townhall names and their emails' do
      department_url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'

      # Mock des URLs de mairies
      allow(self).to receive(:get_townhall_urls).and_return([
        { name: 'Ville1', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville1' },
        { name: 'Ville2', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville2' }
      ])

      # Mock des réponses des pages des mairies
      allow(self).to receive(:get_townhall_email).with('https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville1')
                                                 .and_return('email1@ville.fr')
      allow(self).to receive(:get_townhall_email).with('https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville2')
                                                 .and_return('email2@ville.fr')

      emails = get_all_townhall_emails(department_url)
      expect(emails).to eq({
        'Ville1' => 'email1@ville.fr',
        'Ville2' => 'email2@ville.fr'
      })
    end

    it 'handles cases where no emails are found' do
      department_url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'

      # Mock des URLs de mairies
      allow(self).to receive(:get_townhall_urls).and_return([
        { name: 'Ville1', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville1' },
        { name: 'Ville2', url: 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville2' }
      ])

      # Mock des réponses des pages des mairies sans emails
      allow(self).to receive(:get_townhall_email).with('https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville1')
                                                 .and_return(nil)
      allow(self).to receive(:get_townhall_email).with('https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/mairie-ville2')
                                                 .and_return(nil)

      emails = get_all_townhall_emails(department_url)
      expect(emails).to eq({})
    end
  end
end

