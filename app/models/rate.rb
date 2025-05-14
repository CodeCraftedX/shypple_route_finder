class Rate
    attr_reader :rate, :rate_currency, :sailing_code

    def initialize(attrs)
        @sailing_code = attrs['sailing_code']
        @rate = attrs['rate']
        @rate_currency = attrs['rate_currency']
    end
end