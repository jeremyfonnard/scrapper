require 'rspec'
require_relative '../lib/scraper'

RSpec.describe 'scraper' do
  describe '#scraper' do
    it 'returns an array of hashes' do
      result = scraper
      expect(result).to be_an(Array)
      expect(result.first).to be_a(Hash)
    end

    it 'contains names and prices for each cryptocurrency' do
      result = scraper
      first_crypto = result.first

      expect(first_crypto).to have_key(:name)
      expect(first_crypto).to have_key(:price)

      expect(first_crypto[:name]).to be_a(String)
      expect(first_crypto[:price]).to be_a(String)
    end

    it 'returns a list of at least 20 cryptocurrencies' do
      result = scraper
      expect(result.size).to be >= 20
    end

    it 'returns valid prices with a dollar sign' do
      result = scraper
      prices = result.map { |crypto| crypto[:price] }

      prices.each do |price|
        expect(price).to match(/^\$/) # Vérifie que chaque prix commence par un $
      end
    end
  end
end
