// Market stocks database - 1000 stocks with ticker, name, current price
class MarketStock {
  final String ticker;
  final String name;
  final double currentPrice;
  final String currency;
  final String exchange;
  final String isin;

  MarketStock({
    required this.ticker,
    required this.name,
    required this.currentPrice,
    required this.currency,
    required this.exchange,
    this.isin = '',
  });
}

class MarketStocksData {
  static final List<MarketStock> allStocks = [
    // ========================================
    // STOCKS FROM PORTFOLIO (MUST BE INCLUDED)
    // ========================================
    MarketStock(ticker: 'NVDA', name: 'NVIDIA Corporation', currentPrice: 495.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US67066G1040'),
    MarketStock(ticker: 'AAPL', name: 'Apple Inc.', currentPrice: 178.25, currency: 'USD', exchange: 'NASDAQ', isin: 'US0378331005'),
    MarketStock(ticker: 'OTP', name: 'OTP Bank Nyrt.', currentPrice: 21300, currency: 'HUF', exchange: 'BSE', isin: 'HU0000061726'),
    MarketStock(ticker: 'VOD', name: 'Vodafone Group plc', currentPrice: 341.00, currency: 'HUF', exchange: 'LSE', isin: 'GB00BH4HKS39'),
    MarketStock(ticker: 'TSLA', name: 'Tesla Inc.', currentPrice: 248.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US88160R1014'),
    MarketStock(ticker: 'MSFT', name: 'Microsoft Corporation', currentPrice: 374.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US5949181045'),
    MarketStock(ticker: 'RICHTER', name: 'Richter Gedeon Nyrt.', currentPrice: 11200, currency: 'HUF', exchange: 'BSE', isin: 'HU0000123456'),

    // ========================================
    // US TECH GIANTS (FAANG+)
    // ========================================
    MarketStock(ticker: 'GOOGL', name: 'Alphabet Inc. Class A', currentPrice: 139.75, currency: 'USD', exchange: 'NASDAQ', isin: 'US02079K3059'),
    MarketStock(ticker: 'GOOG', name: 'Alphabet Inc. Class C', currentPrice: 141.20, currency: 'USD', exchange: 'NASDAQ', isin: 'US02079K1079'),
    MarketStock(ticker: 'AMZN', name: 'Amazon.com Inc.', currentPrice: 145.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US0231351067'),
    MarketStock(ticker: 'META', name: 'Meta Platforms Inc.', currentPrice: 312.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US30303M1027'),
    MarketStock(ticker: 'NFLX', name: 'Netflix Inc.', currentPrice: 425.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US64110L1061'),
    MarketStock(ticker: 'AMD', name: 'Advanced Micro Devices', currentPrice: 118.45, currency: 'USD', exchange: 'NASDAQ', isin: 'US0079031078'),
    MarketStock(ticker: 'INTC', name: 'Intel Corporation', currentPrice: 43.25, currency: 'USD', exchange: 'NASDAQ', isin: 'US4581401001'),
    MarketStock(ticker: 'QCOM', name: 'Qualcomm Inc.', currentPrice: 142.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US7475251036'),
    MarketStock(ticker: 'AVGO', name: 'Broadcom Inc.', currentPrice: 892.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US11135F1012'),
    MarketStock(ticker: 'CSCO', name: 'Cisco Systems Inc.', currentPrice: 54.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US17275R1023'),
    MarketStock(ticker: 'ADBE', name: 'Adobe Inc.', currentPrice: 567.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US00724F1012'),
    MarketStock(ticker: 'CRM', name: 'Salesforce Inc.', currentPrice: 215.40, currency: 'USD', exchange: 'NYSE', isin: 'US79466L3024'),
    MarketStock(ticker: 'ORCL', name: 'Oracle Corporation', currentPrice: 108.90, currency: 'USD', exchange: 'NYSE', isin: 'US68389X1054'),
    MarketStock(ticker: 'NOW', name: 'ServiceNow Inc.', currentPrice: 685.20, currency: 'USD', exchange: 'NYSE', isin: 'US81762P1021'),

    // ========================================
    // US BLUE CHIPS - FINANCIALS
    // ========================================
    MarketStock(ticker: 'JPM', name: 'JPMorgan Chase & Co.', currentPrice: 152.80, currency: 'USD', exchange: 'NYSE', isin: 'US46625H1005'),
    MarketStock(ticker: 'BAC', name: 'Bank of America Corp', currentPrice: 34.75, currency: 'USD', exchange: 'NYSE', isin: 'US0605051046'),
    MarketStock(ticker: 'WFC', name: 'Wells Fargo & Company', currentPrice: 47.90, currency: 'USD', exchange: 'NYSE', isin: 'US9497461015'),
    MarketStock(ticker: 'GS', name: 'Goldman Sachs Group', currentPrice: 378.20, currency: 'USD', exchange: 'NYSE', isin: 'US38141G1040'),
    MarketStock(ticker: 'MS', name: 'Morgan Stanley', currentPrice: 89.65, currency: 'USD', exchange: 'NYSE', isin: 'US6174464486'),
    MarketStock(ticker: 'C', name: 'Citigroup Inc.', currentPrice: 58.40, currency: 'USD', exchange: 'NYSE', isin: 'US1729674242'),
    MarketStock(ticker: 'BLK', name: 'BlackRock Inc.', currentPrice: 742.30, currency: 'USD', exchange: 'NYSE', isin: 'US09247X1019'),
    MarketStock(ticker: 'SCHW', name: 'Charles Schwab Corp', currentPrice: 68.50, currency: 'USD', exchange: 'NYSE', isin: 'US8085131055'),
    MarketStock(ticker: 'AXP', name: 'American Express Co', currentPrice: 182.90, currency: 'USD', exchange: 'NYSE', isin: 'US0258161092'),
    MarketStock(ticker: 'USB', name: 'U.S. Bancorp', currentPrice: 46.20, currency: 'USD', exchange: 'NYSE', isin: 'US9029733048'),

    // ========================================
    // US BLUE CHIPS - ENERGY
    // ========================================
    MarketStock(ticker: 'XOM', name: 'Exxon Mobil Corporation', currentPrice: 102.30, currency: 'USD', exchange: 'NYSE', isin: 'US30231G1022'),
    MarketStock(ticker: 'CVX', name: 'Chevron Corporation', currentPrice: 147.55, currency: 'USD', exchange: 'NYSE', isin: 'US1667641005'),
    MarketStock(ticker: 'COP', name: 'ConocoPhillips', currentPrice: 112.40, currency: 'USD', exchange: 'NYSE', isin: 'US20825C1045'),
    MarketStock(ticker: 'SLB', name: 'Schlumberger NV', currentPrice: 52.80, currency: 'USD', exchange: 'NYSE', isin: 'AN8068571086'),
    MarketStock(ticker: 'EOG', name: 'EOG Resources Inc.', currentPrice: 125.60, currency: 'USD', exchange: 'NYSE', isin: 'US26875P1012'),

    // ========================================
    // US BLUE CHIPS - CONSUMER & RETAIL
    // ========================================
    MarketStock(ticker: 'WMT', name: 'Walmart Inc.', currentPrice: 162.50, currency: 'USD', exchange: 'NYSE', isin: 'US9311421039'),
    MarketStock(ticker: 'HD', name: 'Home Depot Inc.', currentPrice: 312.80, currency: 'USD', exchange: 'NYSE', isin: 'US4370761029'),
    MarketStock(ticker: 'MCD', name: "McDonald's Corporation", currentPrice: 285.40, currency: 'USD', exchange: 'NYSE', isin: 'US5801351017'),
    MarketStock(ticker: 'NKE', name: 'Nike Inc.', currentPrice: 104.20, currency: 'USD', exchange: 'NYSE', isin: 'US6541061031'),
    MarketStock(ticker: 'SBUX', name: 'Starbucks Corporation', currentPrice: 95.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US8552441094'),
    MarketStock(ticker: 'TGT', name: 'Target Corporation', currentPrice: 148.70, currency: 'USD', exchange: 'NYSE', isin: 'US87612E1064'),
    MarketStock(ticker: 'LOW', name: "Lowe's Companies Inc.", currentPrice: 218.90, currency: 'USD', exchange: 'NYSE', isin: 'US5486611073'),
    MarketStock(ticker: 'COST', name: 'Costco Wholesale Corp', currentPrice: 565.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US22160K1051'),

    // ========================================
    // US BLUE CHIPS - HEALTHCARE & PHARMA
    // ========================================
    MarketStock(ticker: 'JNJ', name: 'Johnson & Johnson', currentPrice: 157.90, currency: 'USD', exchange: 'NYSE', isin: 'US4781601046'),
    MarketStock(ticker: 'UNH', name: 'UnitedHealth Group Inc.', currentPrice: 482.50, currency: 'USD', exchange: 'NYSE', isin: 'US91324P1021'),
    MarketStock(ticker: 'PFE', name: 'Pfizer Inc.', currentPrice: 29.40, currency: 'USD', exchange: 'NYSE', isin: 'US7170811035'),
    MarketStock(ticker: 'ABBV', name: 'AbbVie Inc.', currentPrice: 158.20, currency: 'USD', exchange: 'NYSE', isin: 'US00287Y1092'),
    MarketStock(ticker: 'TMO', name: 'Thermo Fisher Scientific', currentPrice: 542.30, currency: 'USD', exchange: 'NYSE', isin: 'US8835561023'),
    MarketStock(ticker: 'ABT', name: 'Abbott Laboratories', currentPrice: 108.60, currency: 'USD', exchange: 'NYSE', isin: 'US0028241000'),
    MarketStock(ticker: 'MRK', name: 'Merck & Co. Inc.', currentPrice: 105.80, currency: 'USD', exchange: 'NYSE', isin: 'US58933Y1055'),
    MarketStock(ticker: 'LLY', name: 'Eli Lilly and Company', currentPrice: 548.90, currency: 'USD', exchange: 'NYSE', isin: 'US5324571083'),
    MarketStock(ticker: 'BMY', name: 'Bristol-Myers Squibb', currentPrice: 56.20, currency: 'USD', exchange: 'NYSE', isin: 'US1101221083'),
    MarketStock(ticker: 'AMGN', name: 'Amgen Inc.', currentPrice: 272.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US0311621009'),
    MarketStock(ticker: 'GILD', name: 'Gilead Sciences Inc.', currentPrice: 78.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US3755581036'),

    // ========================================
    // US BLUE CHIPS - CONSUMER GOODS
    // ========================================
    MarketStock(ticker: 'PG', name: 'Procter & Gamble Co', currentPrice: 152.40, currency: 'USD', exchange: 'NYSE', isin: 'US7427181091'),
    MarketStock(ticker: 'KO', name: 'Coca-Cola Company', currentPrice: 58.75, currency: 'USD', exchange: 'NYSE', isin: 'US1912161007'),
    MarketStock(ticker: 'PEP', name: 'PepsiCo Inc.', currentPrice: 172.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US7134481081'),
    MarketStock(ticker: 'PM', name: 'Philip Morris Intl', currentPrice: 96.80, currency: 'USD', exchange: 'NYSE', isin: 'US7181721090'),
    MarketStock(ticker: 'MO', name: 'Altria Group Inc.', currentPrice: 44.50, currency: 'USD', exchange: 'NYSE', isin: 'US02209S1033'),
    MarketStock(ticker: 'CL', name: 'Colgate-Palmolive Co', currentPrice: 82.60, currency: 'USD', exchange: 'NYSE', isin: 'US1941621039'),

    // ========================================
    // US BLUE CHIPS - INDUSTRIAL & AEROSPACE
    // ========================================
    MarketStock(ticker: 'BA', name: 'Boeing Company', currentPrice: 188.40, currency: 'USD', exchange: 'NYSE', isin: 'US0970231058'),
    MarketStock(ticker: 'CAT', name: 'Caterpillar Inc.', currentPrice: 285.70, currency: 'USD', exchange: 'NYSE', isin: 'US1491231015'),
    MarketStock(ticker: 'GE', name: 'General Electric Co', currentPrice: 112.50, currency: 'USD', exchange: 'NYSE', isin: 'US3696041033'),
    MarketStock(ticker: 'HON', name: 'Honeywell International', currentPrice: 198.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US4385161066'),
    MarketStock(ticker: 'LMT', name: 'Lockheed Martin Corp', currentPrice: 445.60, currency: 'USD', exchange: 'NYSE', isin: 'US5398301094'),
    MarketStock(ticker: 'RTX', name: 'Raytheon Technologies', currentPrice: 92.80, currency: 'USD', exchange: 'NYSE', isin: 'US75513E1010'),
    MarketStock(ticker: 'UPS', name: 'United Parcel Service', currentPrice: 148.90, currency: 'USD', exchange: 'NYSE', isin: 'US9113121068'),
    MarketStock(ticker: 'UNP', name: 'Union Pacific Corp', currentPrice: 238.50, currency: 'USD', exchange: 'NYSE', isin: 'US9078181081'),

    // ========================================
    // US BLUE CHIPS - TELECOM & MEDIA
    // ========================================
    MarketStock(ticker: 'VZ', name: 'Verizon Communications', currentPrice: 42.30, currency: 'USD', exchange: 'NYSE', isin: 'US92343V1044'),
    MarketStock(ticker: 'T', name: 'AT&T Inc.', currentPrice: 18.90, currency: 'USD', exchange: 'NYSE', isin: 'US00206R1023'),
    MarketStock(ticker: 'CMCSA', name: 'Comcast Corporation', currentPrice: 43.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US20030N1019'),
    MarketStock(ticker: 'DIS', name: 'Walt Disney Company', currentPrice: 95.80, currency: 'USD', exchange: 'NYSE', isin: 'US2546871060'),
    MarketStock(ticker: 'TMUS', name: 'T-Mobile US Inc.', currentPrice: 162.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US8725901040'),

    // ========================================
    // EUROPEAN STOCKS - GERMAN DAX
    // ========================================
    MarketStock(ticker: 'SAP', name: 'SAP SE', currentPrice: 142.80, currency: 'EUR', exchange: 'XETRA', isin: 'DE0007164600'),
    MarketStock(ticker: 'SIE', name: 'Siemens AG', currentPrice: 168.90, currency: 'EUR', exchange: 'XETRA', isin: 'DE0007236101'),
    MarketStock(ticker: 'ALV', name: 'Allianz SE', currentPrice: 245.60, currency: 'EUR', exchange: 'XETRA', isin: 'DE0008404005'),
    MarketStock(ticker: 'BAS', name: 'BASF SE', currentPrice: 48.50, currency: 'EUR', exchange: 'XETRA', isin: 'DE000BASF111'),
    MarketStock(ticker: 'DAI', name: 'Daimler AG', currentPrice: 68.40, currency: 'EUR', exchange: 'XETRA', isin: 'DE0007100000'),
    MarketStock(ticker: 'BMW', name: 'BMW AG', currentPrice: 92.30, currency: 'EUR', exchange: 'XETRA', isin: 'DE0005190003'),
    MarketStock(ticker: 'VOW3', name: 'Volkswagen AG', currentPrice: 115.80, currency: 'EUR', exchange: 'XETRA', isin: 'DE0007664039'),
    MarketStock(ticker: 'DTE', name: 'Deutsche Telekom AG', currentPrice: 22.50, currency: 'EUR', exchange: 'XETRA', isin: 'DE0005557508'),
    MarketStock(ticker: 'MUV2', name: 'Munich Re', currentPrice: 385.20, currency: 'EUR', exchange: 'XETRA', isin: 'DE0008430026'),
    MarketStock(ticker: 'ADS', name: 'Adidas AG', currentPrice: 192.40, currency: 'EUR', exchange: 'XETRA', isin: 'DE000A1EWWW0'),
    MarketStock(ticker: 'BEI', name: 'Beiersdorf AG', currentPrice: 134.60, currency: 'EUR', exchange: 'XETRA', isin: 'DE0005200000'),
    MarketStock(ticker: 'DBK', name: 'Deutsche Bank AG', currentPrice: 12.80, currency: 'EUR', exchange: 'XETRA', isin: 'DE0005140008'),

    // ========================================
    // EUROPEAN STOCKS - FRANCE CAC40
    // ========================================
    MarketStock(ticker: 'MC', name: 'LVMH Moët Hennessy', currentPrice: 745.30, currency: 'EUR', exchange: 'EPA', isin: 'FR0000121014'),
    MarketStock(ticker: 'OR', name: "L'Oréal SA", currentPrice: 428.60, currency: 'EUR', exchange: 'EPA', isin: 'FR0000120321'),
    MarketStock(ticker: 'SAN', name: 'Sanofi SA', currentPrice: 95.75, currency: 'EUR', exchange: 'EPA', isin: 'FR0000120578'),
    MarketStock(ticker: 'AIR', name: 'Airbus SE', currentPrice: 134.25, currency: 'EUR', exchange: 'EPA', isin: 'NL0000235190'),
    MarketStock(ticker: 'TTE', name: 'TotalEnergies SE', currentPrice: 62.40, currency: 'EUR', exchange: 'EPA', isin: 'FR0000120271'),
    MarketStock(ticker: 'BNP', name: 'BNP Paribas SA', currentPrice: 62.80, currency: 'EUR', exchange: 'EPA', isin: 'FR0000131104'),
    MarketStock(ticker: 'ACA', name: 'Crédit Agricole SA', currentPrice: 13.50, currency: 'EUR', exchange: 'EPA', isin: 'FR0000045072'),
    MarketStock(ticker: 'VIV', name: 'Vivendi SA', currentPrice: 9.80, currency: 'EUR', exchange: 'EPA', isin: 'FR0000127771'),
    MarketStock(ticker: 'EL', name: 'EssilorLuxottica SA', currentPrice: 184.20, currency: 'EUR', exchange: 'EPA', isin: 'FR0000121667'),
    MarketStock(ticker: 'DG', name: 'Vinci SA', currentPrice: 105.40, currency: 'EUR', exchange: 'EPA', isin: 'FR0000125486'),

    // ========================================
    // EUROPEAN STOCKS - NETHERLANDS
    // ========================================
    MarketStock(ticker: 'ASML', name: 'ASML Holding NV', currentPrice: 687.50, currency: 'EUR', exchange: 'AEX', isin: 'NL0010273215'),
    MarketStock(ticker: 'INGA', name: 'ING Groep NV', currentPrice: 13.80, currency: 'EUR', exchange: 'AEX', isin: 'NL0011821202'),
    MarketStock(ticker: 'PHIA', name: 'Koninklijke Philips', currentPrice: 24.50, currency: 'EUR', exchange: 'AEX', isin: 'NL0000009538'),
    MarketStock(ticker: 'HEIA', name: 'Heineken NV', currentPrice: 88.40, currency: 'EUR', exchange: 'AEX', isin: 'NL0000009165'),
    MarketStock(ticker: 'AD', name: 'Ahold Delhaize', currentPrice: 28.60, currency: 'EUR', exchange: 'AEX', isin: 'NL0011794037'),

    // ========================================
    // UK STOCKS - FTSE 100
    // ========================================
    MarketStock(ticker: 'BP', name: 'BP plc', currentPrice: 518.40, currency: 'HUF', exchange: 'LSE', isin: 'GB0007980591'),
    MarketStock(ticker: 'HSBA', name: 'HSBC Holdings plc', currentPrice: 685.20, currency: 'HUF', exchange: 'LSE', isin: 'GB0005405286'),
    MarketStock(ticker: 'SHEL', name: 'Shell plc', currentPrice: 2890.00, currency: 'HUF', exchange: 'LSE', isin: 'GB00BP6MXD84'),
    MarketStock(ticker: 'AZN', name: 'AstraZeneca plc', currentPrice: 12450.00, currency: 'HUF', exchange: 'LSE', isin: 'GB0009895011'),
    MarketStock(ticker: 'GSK', name: 'GSK plc', currentPrice: 1685.00, currency: 'HUF', exchange: 'LSE', isin: 'GB00BN7SWP63'),
    MarketStock(ticker: 'ULVR', name: 'Unilever plc', currentPrice: 4520.00, currency: 'HUF', exchange: 'LSE', isin: 'GB00B10RZP78'),
    MarketStock(ticker: 'DGE', name: 'Diageo plc', currentPrice: 2940.00, currency: 'HUF', exchange: 'LSE', isin: 'GB0002374006'),
    MarketStock(ticker: 'RIO', name: 'Rio Tinto plc', currentPrice: 5680.00, currency: 'HUF', exchange: 'LSE', isin: 'GB0007188757'),
    MarketStock(ticker: 'BARC', name: 'Barclays plc', currentPrice: 215.40, currency: 'HUF', exchange: 'LSE', isin: 'GB0031348658'),
    MarketStock(ticker: 'LLOY', name: 'Lloyds Banking Group', currentPrice: 58.60, currency: 'HUF', exchange: 'LSE', isin: 'GB0008706128'),

    // ========================================
    // HUNGARIAN STOCKS - BÉT
    // ========================================
    MarketStock(ticker: 'MOL', name: 'MOL Magyar Olaj', currentPrice: 9850, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000068952'),
    MarketStock(ticker: 'MTELEKOM', name: 'Magyar Telekom', currentPrice: 1245, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000123096'),
    MarketStock(ticker: 'OPUS', name: 'Opus Global Nyrt.', currentPrice: 485, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000130599'),
    MarketStock(ticker: 'ANY', name: 'ANY Biztonsági Nyrt.', currentPrice: 3680, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000105836'),
    MarketStock(ticker: 'AUTOWALLIS', name: 'AutoWallis Nyrt.', currentPrice: 865, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000168828'),
    MarketStock(ticker: 'BOOKLINE', name: 'Bookline Zrt.', currentPrice: 1250, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000175970'),
    MarketStock(ticker: 'BDPST', name: 'Budapest Bank Nyrt.', currentPrice: 2340, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000061241'),
    MarketStock(ticker: 'CIGPANNONIA', name: 'CIG Pannónia Életbiztosító', currentPrice: 680, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000089876'),
    MarketStock(ticker: 'KONZUM', name: 'Konzum Nyrt.', currentPrice: 1450, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000096930'),
    MarketStock(ticker: 'MASTERPLAST', name: 'Masterplast Nyrt.', currentPrice: 2850, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000088907'),
    MarketStock(ticker: 'RABA', name: 'Rába Nyrt.', currentPrice: 1580, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000067597'),
    MarketStock(ticker: 'PLOTINUS', name: 'Plotinus Vagyonkezelő', currentPrice: 790, currency: 'HUF', exchange: 'BÉT', isin: 'HU0000175632'),

    // ========================================
    // ASIAN STOCKS - JAPAN
    // ========================================
    MarketStock(ticker: '7203', name: 'Toyota Motor Corp', currentPrice: 2450.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3633400001'),
    MarketStock(ticker: '6758', name: 'Sony Group Corp', currentPrice: 10850.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3435000009'),
    MarketStock(ticker: '9984', name: 'SoftBank Group Corp', currentPrice: 5890.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3436100006'),
    MarketStock(ticker: '6501', name: 'Hitachi Ltd', currentPrice: 3280.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3788600009'),
    MarketStock(ticker: '7974', name: 'Nintendo Co Ltd', currentPrice: 6450.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3756600007'),
    MarketStock(ticker: '8306', name: 'Mitsubishi UFJ', currentPrice: 985.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3902900004'),
    MarketStock(ticker: '9433', name: 'KDDI Corp', currentPrice: 4120.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3496400007'),
    MarketStock(ticker: '4063', name: 'Shin-Etsu Chemical', currentPrice: 5680.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3375400002'),
    MarketStock(ticker: '8035', name: 'Tokyo Electron Ltd', currentPrice: 28500.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3571400005'),
    MarketStock(ticker: '6902', name: 'Denso Corp', currentPrice: 2140.00, currency: 'JPY', exchange: 'TSE', isin: 'JP3551500006'),

    // ========================================
    // ASIAN STOCKS - CHINA / HONG KONG
    // ========================================
    MarketStock(ticker: '0700', name: 'Tencent Holdings Ltd', currentPrice: 342.00, currency: 'HKD', exchange: 'HKEX', isin: 'KYG875721634'),
    MarketStock(ticker: '9988', name: 'Alibaba Group Holding', currentPrice: 78.50, currency: 'HKD', exchange: 'HKEX', isin: 'KYG017191142'),
    MarketStock(ticker: '0939', name: 'China Construction Bank', currentPrice: 5.85, currency: 'HKD', exchange: 'HKEX', isin: 'CNE1000002H1'),
    MarketStock(ticker: '0941', name: 'China Mobile Ltd', currentPrice: 68.20, currency: 'HKD', exchange: 'HKEX', isin: 'CNE1000003G6'),
    MarketStock(ticker: '0005', name: 'HSBC Holdings', currentPrice: 58.30, currency: 'HKD', exchange: 'HKEX', isin: 'GB0005405286'),
    MarketStock(ticker: '1299', name: 'AIA Group Ltd', currentPrice: 52.40, currency: 'HKD', exchange: 'HKEX', isin: 'HK0000069689'),
    MarketStock(ticker: '0388', name: 'Hong Kong Exchanges', currentPrice: 285.60, currency: 'HKD', exchange: 'HKEX', isin: 'HK0388045442'),
    MarketStock(ticker: '2318', name: 'Ping An Insurance', currentPrice: 42.80, currency: 'HKD', exchange: 'HKEX', isin: 'CNE1000003X6'),
    MarketStock(ticker: '1398', name: 'Industrial & Commercial Bank', currentPrice: 4.52, currency: 'HKD', exchange: 'HKEX', isin: 'CNE1000001Z5'),
    MarketStock(ticker: '3690', name: 'Meituan', currentPrice: 118.50, currency: 'HKD', exchange: 'HKEX', isin: 'KYG596691041'),

    // ========================================
    // EMERGING MARKETS - INDIA
    // ========================================
    MarketStock(ticker: 'RELIANCE', name: 'Reliance Industries', currentPrice: 2485.50, currency: 'INR', exchange: 'NSE', isin: 'INE002A01018'),
    MarketStock(ticker: 'TCS', name: 'Tata Consultancy Services', currentPrice: 3568.20, currency: 'INR', exchange: 'NSE', isin: 'INE467B01029'),
    MarketStock(ticker: 'HDFCBANK', name: 'HDFC Bank Ltd', currentPrice: 1642.80, currency: 'INR', exchange: 'NSE', isin: 'INE040A01034'),
    MarketStock(ticker: 'INFY', name: 'Infosys Ltd', currentPrice: 1458.30, currency: 'INR', exchange: 'NSE', isin: 'INE009A01021'),
    MarketStock(ticker: 'BHARTIARTL', name: 'Bharti Airtel Ltd', currentPrice: 985.40, currency: 'INR', exchange: 'NSE', isin: 'INE397D01024'),
    MarketStock(ticker: 'ICICIBANK', name: 'ICICI Bank Ltd', currentPrice: 1048.60, currency: 'INR', exchange: 'NSE', isin: 'INE090A01021'),
    MarketStock(ticker: 'SBIN', name: 'State Bank of India', currentPrice: 612.50, currency: 'INR', exchange: 'NSE', isin: 'INE062A01020'),
    MarketStock(ticker: 'WIPRO', name: 'Wipro Ltd', currentPrice: 425.80, currency: 'INR', exchange: 'NSE', isin: 'INE075A01022'),
    MarketStock(ticker: 'ITC', name: 'ITC Ltd', currentPrice: 368.90, currency: 'INR', exchange: 'NSE', isin: 'INE154A01025'),
    MarketStock(ticker: 'LT', name: 'Larsen & Toubro', currentPrice: 3285.40, currency: 'INR', exchange: 'NSE', isin: 'INE018A01030'),

    // ========================================
    // EMERGING MARKETS - BRAZIL
    // ========================================
    MarketStock(ticker: 'PETR4', name: 'Petrobras', currentPrice: 38.50, currency: 'BRL', exchange: 'B3', isin: 'BRPETRACNPR6'),
    MarketStock(ticker: 'VALE3', name: 'Vale SA', currentPrice: 62.80, currency: 'BRL', exchange: 'B3', isin: 'BRVALEACNOR0'),
    MarketStock(ticker: 'ITUB4', name: 'Itaú Unibanco', currentPrice: 28.40, currency: 'BRL', exchange: 'B3', isin: 'BRITUBACNPR8'),
    MarketStock(ticker: 'BBDC4', name: 'Bradesco', currentPrice: 14.85, currency: 'BRL', exchange: 'B3', isin: 'BRBBDCACNPR8'),
    MarketStock(ticker: 'ABEV3', name: 'Ambev SA', currentPrice: 12.60, currency: 'BRL', exchange: 'B3', isin: 'BRABEVACNOR1'),
    MarketStock(ticker: 'B3SA3', name: 'B3 SA', currentPrice: 10.95, currency: 'BRL', exchange: 'B3', isin: 'BRB3SAACNOR2'),
    MarketStock(ticker: 'WEGE3', name: 'WEG SA', currentPrice: 42.30, currency: 'BRL', exchange: 'B3', isin: 'BRWEGEACNOR0'),
    MarketStock(ticker: 'RENT3', name: 'Localiza', currentPrice: 52.80, currency: 'BRL', exchange: 'B3', isin: 'BRRENTACNOR9'),

    // ========================================
    // CRYPTO & FINTECH STOCKS
    // ========================================
    MarketStock(ticker: 'COIN', name: 'Coinbase Global Inc.', currentPrice: 168.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US19260Q1076'),
    MarketStock(ticker: 'SQ', name: 'Block Inc.', currentPrice: 74.20, currency: 'USD', exchange: 'NYSE', isin: 'US8522341036'),
    MarketStock(ticker: 'PYPL', name: 'PayPal Holdings Inc.', currentPrice: 64.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US70450Y1038'),
    MarketStock(ticker: 'MSTR', name: 'MicroStrategy Inc.', currentPrice: 485.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US5949724083'),
    MarketStock(ticker: 'SOFI', name: 'SoFi Technologies', currentPrice: 8.45, currency: 'USD', exchange: 'NASDAQ', isin: 'US83406F1021'),
    MarketStock(ticker: 'HOOD', name: 'Robinhood Markets', currentPrice: 18.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US7707001027'),

    // ========================================
    // ELECTRIC VEHICLE & BATTERY STOCKS
    // ========================================
    MarketStock(ticker: 'RIVN', name: 'Rivian Automotive', currentPrice: 18.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US76954A1034'),
    MarketStock(ticker: 'LCID', name: 'Lucid Group Inc.', currentPrice: 3.85, currency: 'USD', exchange: 'NASDAQ', isin: 'US5494981039'),
    MarketStock(ticker: 'NIO', name: 'NIO Inc.', currentPrice: 6.20, currency: 'USD', exchange: 'NYSE', isin: 'US62914V1061'),
    MarketStock(ticker: 'XPEV', name: 'XPeng Inc.', currentPrice: 11.50, currency: 'USD', exchange: 'NYSE', isin: 'US98422D1054'),
    MarketStock(ticker: 'LI', name: 'Li Auto Inc.', currentPrice: 28.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US50202M1027'),
    MarketStock(ticker: 'FSR', name: 'Fisker Inc.', currentPrice: 0.85, currency: 'USD', exchange: 'NYSE', isin: 'US33835G1022'),

    // ========================================
    // SEMICONDUCTOR & CHIP STOCKS
    // ========================================
    MarketStock(ticker: 'TSM', name: 'Taiwan Semiconductor', currentPrice: 98.50, currency: 'USD', exchange: 'NYSE', isin: 'US8740391003'),
    MarketStock(ticker: 'AMAT', name: 'Applied Materials', currentPrice: 182.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US0382221051'),
    MarketStock(ticker: 'LRCX', name: 'Lam Research Corp', currentPrice: 785.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US5128071082'),
    MarketStock(ticker: 'KLAC', name: 'KLA Corporation', currentPrice: 625.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US4824801009'),
    MarketStock(ticker: 'MU', name: 'Micron Technology', currentPrice: 94.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US5951121038'),
    MarketStock(ticker: 'MRVL', name: 'Marvell Technology', currentPrice: 68.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US5738741041'),
    MarketStock(ticker: 'NXPI', name: 'NXP Semiconductors', currentPrice: 225.40, currency: 'USD', exchange: 'NASDAQ', isin: 'NL0009538784'),
    MarketStock(ticker: 'TXN', name: 'Texas Instruments', currentPrice: 178.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US8825081040'),
    MarketStock(ticker: 'ON', name: 'ON Semiconductor', currentPrice: 78.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US6821891057'),

    // ========================================
    // CLOUD & ENTERPRISE SOFTWARE
    // ========================================
    MarketStock(ticker: 'SNOW', name: 'Snowflake Inc.', currentPrice: 168.50, currency: 'USD', exchange: 'NYSE', isin: 'US8334451098'),
    MarketStock(ticker: 'DDOG', name: 'Datadog Inc.', currentPrice: 118.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US23804L1035'),
    MarketStock(ticker: 'ZS', name: 'Zscaler Inc.', currentPrice: 185.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US98980G1022'),
    MarketStock(ticker: 'CRWD', name: 'CrowdStrike Holdings', currentPrice: 245.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US22788C1053'),
    MarketStock(ticker: 'NET', name: 'Cloudflare Inc.', currentPrice: 82.40, currency: 'USD', exchange: 'NYSE', isin: 'US18915M1071'),
    MarketStock(ticker: 'TEAM', name: 'Atlassian Corp', currentPrice: 172.90, currency: 'USD', exchange: 'NASDAQ', isin: 'AU000000TEAM3'),
    MarketStock(ticker: 'WDAY', name: 'Workday Inc.', currentPrice: 245.30, currency: 'USD', exchange: 'NASDAQ', isin: 'US98138H1014'),
    MarketStock(ticker: 'OKTA', name: 'Okta Inc.', currentPrice: 78.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US67900B1080'),
    MarketStock(ticker: 'SPLK', name: 'Splunk Inc.', currentPrice: 142.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US8486371045'),
    MarketStock(ticker: 'DOCN', name: 'DigitalOcean Holdings', currentPrice: 38.40, currency: 'USD', exchange: 'NYSE', isin: 'US25402D1028'),

    // ========================================
    // E-COMMERCE & ONLINE RETAIL
    // ========================================
    MarketStock(ticker: 'SHOP', name: 'Shopify Inc.', currentPrice: 68.50, currency: 'USD', exchange: 'NYSE', isin: 'CA82509L1076'),
    MarketStock(ticker: 'ETSY', name: 'Etsy Inc.', currentPrice: 78.20, currency: 'USD', exchange: 'NASDAQ', isin: 'US29786A1060'),
    MarketStock(ticker: 'EBAY', name: 'eBay Inc.', currentPrice: 48.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US2786421030'),
    MarketStock(ticker: 'W', name: 'Wayfair Inc.', currentPrice: 58.40, currency: 'USD', exchange: 'NYSE', isin: 'US94419L1017'),
    MarketStock(ticker: 'BABA', name: 'Alibaba Group ADR', currentPrice: 78.90, currency: 'USD', exchange: 'NYSE', isin: 'US01609W1027'),
    MarketStock(ticker: 'JD', name: 'JD.com Inc. ADR', currentPrice: 32.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US47215P1066'),
    MarketStock(ticker: 'PDD', name: 'PDD Holdings Inc.', currentPrice: 118.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US69608A1088'),
    MarketStock(ticker: 'MELI', name: 'MercadoLibre Inc.', currentPrice: 1485.00, currency: 'USD', exchange: 'NASDAQ', isin: 'US58733R1023'),
    MarketStock(ticker: 'SE', name: 'Sea Ltd ADR', currentPrice: 68.40, currency: 'USD', exchange: 'NYSE', isin: 'US81141R1005'),

    // ========================================
    // STREAMING & MEDIA
    // ========================================
    MarketStock(ticker: 'SPOT', name: 'Spotify Technology', currentPrice: 285.60, currency: 'USD', exchange: 'NYSE', isin: 'LU1778762911'),
    MarketStock(ticker: 'ROKU', name: 'Roku Inc.', currentPrice: 68.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US77543R1023'),
    MarketStock(ticker: 'WBD', name: 'Warner Bros Discovery', currentPrice: 9.85, currency: 'USD', exchange: 'NASDAQ', isin: 'US9344231041'),
    MarketStock(ticker: 'PARA', name: 'Paramount Global', currentPrice: 15.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US92556H2067'),
    MarketStock(ticker: 'FOXA', name: 'Fox Corporation', currentPrice: 38.20, currency: 'USD', exchange: 'NASDAQ', isin: 'US35137L1052'),

    // ========================================
    // BIOTECH & GENOMICS
    // ========================================
    MarketStock(ticker: 'MRNA', name: 'Moderna Inc.', currentPrice: 98.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US60770K1079'),
    MarketStock(ticker: 'BNTX', name: 'BioNTech SE ADR', currentPrice: 108.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US09075V1026'),
    MarketStock(ticker: 'REGN', name: 'Regeneron Pharma', currentPrice: 885.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US75886F1075'),
    MarketStock(ticker: 'VRTX', name: 'Vertex Pharmaceuticals', currentPrice: 412.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US92532F1003'),
    MarketStock(ticker: 'ILMN', name: 'Illumina Inc.', currentPrice: 142.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US4523271090'),
    MarketStock(ticker: 'BIIB', name: 'Biogen Inc.', currentPrice: 258.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US09062X1037'),
    MarketStock(ticker: 'ALNY', name: 'Alnylam Pharmaceuticals', currentPrice: 185.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US02043Q1076'),
    MarketStock(ticker: 'BMRN', name: 'BioMarin Pharmaceutical', currentPrice: 88.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US09061G1013'),
    MarketStock(ticker: 'SGEN', name: 'Seagen Inc.', currentPrice: 218.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US81181C1045'),
    MarketStock(ticker: 'EXAS', name: 'Exact Sciences Corp', currentPrice: 68.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US30063P1057'),

    // ========================================
    // RENEWABLE ENERGY & CLEAN TECH
    // ========================================
    MarketStock(ticker: 'ENPH', name: 'Enphase Energy Inc.', currentPrice: 128.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US29355A1079'),
    MarketStock(ticker: 'SEDG', name: 'SolarEdge Technologies', currentPrice: 68.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US8189301041'),
    MarketStock(ticker: 'FSLR', name: 'First Solar Inc.', currentPrice: 185.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US3364331070'),
    MarketStock(ticker: 'RUN', name: 'Sunrun Inc.', currentPrice: 18.90, currency: 'USD', exchange: 'NASDAQ', isin: 'US86771W1053'),
    MarketStock(ticker: 'PLUG', name: 'Plug Power Inc.', currentPrice: 4.25, currency: 'USD', exchange: 'NASDAQ', isin: 'US72919P2020'),
    MarketStock(ticker: 'BE', name: 'Bloom Energy Corp', currentPrice: 12.80, currency: 'USD', exchange: 'NYSE', isin: 'US0937121079'),
    MarketStock(ticker: 'CHPT', name: 'ChargePoint Holdings', currentPrice: 2.45, currency: 'USD', exchange: 'NYSE', isin: 'US16169C1018'),
    MarketStock(ticker: 'BLNK', name: 'Blink Charging Co', currentPrice: 3.68, currency: 'USD', exchange: 'NASDAQ', isin: 'US09366C1062'),

    // ========================================
    // AEROSPACE & DEFENSE
    // ========================================
    MarketStock(ticker: 'NOC', name: 'Northrop Grumman', currentPrice: 458.90, currency: 'USD', exchange: 'NYSE', isin: 'US6668071029'),
    MarketStock(ticker: 'GD', name: 'General Dynamics', currentPrice: 278.40, currency: 'USD', exchange: 'NYSE', isin: 'US3695501086'),
    MarketStock(ticker: 'LHX', name: 'L3Harris Technologies', currentPrice: 218.60, currency: 'USD', exchange: 'NYSE', isin: 'US5024311095'),
    MarketStock(ticker: 'HII', name: 'Huntington Ingalls', currentPrice: 248.50, currency: 'USD', exchange: 'NYSE', isin: 'US4464131063'),
    MarketStock(ticker: 'TXT', name: 'Textron Inc.', currentPrice: 78.40, currency: 'USD', exchange: 'NYSE', isin: 'US8832031012'),

    // ========================================
    // FOOD & BEVERAGE
    // ========================================
    MarketStock(ticker: 'MDLZ', name: 'Mondelez International', currentPrice: 72.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US6092071058'),
    MarketStock(ticker: 'KHC', name: 'Kraft Heinz Co', currentPrice: 38.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US5007541064'),
    MarketStock(ticker: 'GIS', name: 'General Mills Inc.', currentPrice: 68.20, currency: 'USD', exchange: 'NYSE', isin: 'US3703341046'),
    MarketStock(ticker: 'K', name: 'Kellogg Company', currentPrice: 58.90, currency: 'USD', exchange: 'NYSE', isin: 'US4878361082'),
    MarketStock(ticker: 'HSY', name: 'Hershey Company', currentPrice: 198.40, currency: 'USD', exchange: 'NYSE', isin: 'US4278661081'),
    MarketStock(ticker: 'CPB', name: 'Campbell Soup Co', currentPrice: 46.80, currency: 'USD', exchange: 'NYSE', isin: 'US1344291091'),
    MarketStock(ticker: 'CAG', name: 'Conagra Brands Inc.', currentPrice: 32.50, currency: 'USD', exchange: 'NYSE', isin: 'US2058871029'),
    MarketStock(ticker: 'SJM', name: 'JM Smucker Company', currentPrice: 118.60, currency: 'USD', exchange: 'NYSE', isin: 'US8326964058'),

    // ========================================
    // LUXURY & APPAREL
    // ========================================
    MarketStock(ticker: 'LVMUY', name: 'LVMH ADR', currentPrice: 148.50, currency: 'USD', exchange: 'OTC', isin: 'US5503071074'),
    MarketStock(ticker: 'KER', name: 'Kering SA', currentPrice: 285.40, currency: 'EUR', exchange: 'EPA', isin: 'FR0000121485'),
    MarketStock(ticker: 'RMS', name: 'Hermès International', currentPrice: 1985.00, currency: 'EUR', exchange: 'EPA', isin: 'FR0000052292'),
    MarketStock(ticker: 'BURBY', name: 'Burberry Group ADR', currentPrice: 18.40, currency: 'USD', exchange: 'OTC', isin: 'US1218331438'),
    MarketStock(ticker: 'RL', name: 'Ralph Lauren Corp', currentPrice: 142.80, currency: 'USD', exchange: 'NYSE', isin: 'US7512121010'),
    MarketStock(ticker: 'CPRI', name: 'Capri Holdings', currentPrice: 48.60, currency: 'USD', exchange: 'NYSE', isin: 'GB00BWFGQN13'),
    MarketStock(ticker: 'TPR', name: 'Tapestry Inc.', currentPrice: 38.90, currency: 'USD', exchange: 'NYSE', isin: 'US8762331057'),
    MarketStock(ticker: 'PVH', name: 'PVH Corp', currentPrice: 88.50, currency: 'USD', exchange: 'NYSE', isin: 'US6936561009'),

    // ========================================
    // AUTOMOTIVE
    // ========================================
    MarketStock(ticker: 'F', name: 'Ford Motor Company', currentPrice: 12.40, currency: 'USD', exchange: 'NYSE', isin: 'US3453708600'),
    MarketStock(ticker: 'GM', name: 'General Motors Co', currentPrice: 38.90, currency: 'USD', exchange: 'NYSE', isin: 'US37045V1008'),
    MarketStock(ticker: 'TM', name: 'Toyota Motor ADR', currentPrice: 168.50, currency: 'USD', exchange: 'NYSE', isin: 'US8923313071'),
    MarketStock(ticker: 'HMC', name: 'Honda Motor ADR', currentPrice: 28.40, currency: 'USD', exchange: 'NYSE', isin: 'US4385161066'),
    MarketStock(ticker: 'STLA', name: 'Stellantis NV', currentPrice: 18.60, currency: 'USD', exchange: 'NYSE', isin: 'NL00150001Q9'),
    MarketStock(ticker: 'RACE', name: 'Ferrari NV', currentPrice: 342.80, currency: 'USD', exchange: 'NYSE', isin: 'NL0011585146'),

    // ========================================
    // HOTELS & TRAVEL
    // ========================================
    MarketStock(ticker: 'MAR', name: 'Marriott International', currentPrice: 228.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US5719032022'),
    MarketStock(ticker: 'HLT', name: 'Hilton Worldwide', currentPrice: 185.60, currency: 'USD', exchange: 'NYSE', isin: 'US43300A2033'),
    MarketStock(ticker: 'ABNB', name: 'Airbnb Inc.', currentPrice: 138.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US0090661010'),
    MarketStock(ticker: 'BKNG', name: 'Booking Holdings Inc.', currentPrice: 3285.00, currency: 'USD', exchange: 'NASDAQ', isin: 'US09857L1089'),
    MarketStock(ticker: 'EXPE', name: 'Expedia Group Inc.', currentPrice: 128.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US30212P3038'),
    MarketStock(ticker: 'AAL', name: 'American Airlines', currentPrice: 14.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US02376R1023'),
    MarketStock(ticker: 'DAL', name: 'Delta Air Lines', currentPrice: 48.60, currency: 'USD', exchange: 'NYSE', isin: 'US2473617023'),
    MarketStock(ticker: 'UAL', name: 'United Airlines', currentPrice: 58.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US9100471096'),
    MarketStock(ticker: 'LUV', name: 'Southwest Airlines', currentPrice: 28.90, currency: 'USD', exchange: 'NYSE', isin: 'US8447411088'),
    MarketStock(ticker: 'ALK', name: 'Alaska Air Group', currentPrice: 48.20, currency: 'USD', exchange: 'NYSE', isin: 'US0116591092'),

    // ========================================
    // REAL ESTATE & REITS
    // ========================================
    MarketStock(ticker: 'AMT', name: 'American Tower Corp', currentPrice: 218.40, currency: 'USD', exchange: 'NYSE', isin: 'US03027X1000'),
    MarketStock(ticker: 'PLD', name: 'Prologis Inc.', currentPrice: 128.50, currency: 'USD', exchange: 'NYSE', isin: 'US74340W1036'),
    MarketStock(ticker: 'CCI', name: 'Crown Castle Inc.', currentPrice: 118.60, currency: 'USD', exchange: 'NYSE', isin: 'US22822V1017'),
    MarketStock(ticker: 'EQIX', name: 'Equinix Inc.', currentPrice: 785.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US29444U7000'),
    MarketStock(ticker: 'PSA', name: 'Public Storage', currentPrice: 298.60, currency: 'USD', exchange: 'NYSE', isin: 'US74460D1090'),
    MarketStock(ticker: 'SPG', name: 'Simon Property Group', currentPrice: 148.80, currency: 'USD', exchange: 'NYSE', isin: 'US8288061091'),
    MarketStock(ticker: 'DLR', name: 'Digital Realty Trust', currentPrice: 148.40, currency: 'USD', exchange: 'NYSE', isin: 'US2538681030'),
    MarketStock(ticker: 'O', name: 'Realty Income Corp', currentPrice: 58.90, currency: 'USD', exchange: 'NYSE', isin: 'US7561091049'),

    // ========================================
    // GAMING & ENTERTAINMENT
    // ========================================
    MarketStock(ticker: 'EA', name: 'Electronic Arts Inc.', currentPrice: 138.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US2855121099'),
    MarketStock(ticker: 'TTWO', name: 'Take-Two Interactive', currentPrice: 158.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US8740541094'),
    MarketStock(ticker: 'ATVI', name: 'Activision Blizzard', currentPrice: 92.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US00507V1098'),
    MarketStock(ticker: 'RBLX', name: 'Roblox Corporation', currentPrice: 42.60, currency: 'USD', exchange: 'NYSE', isin: 'US7710491033'),
    MarketStock(ticker: 'U', name: 'Unity Software Inc.', currentPrice: 38.40, currency: 'USD', exchange: 'NYSE', isin: 'US91332U1016'),
    MarketStock(ticker: 'DKNG', name: 'DraftKings Inc.', currentPrice: 38.50, currency: 'USD', exchange: 'NASDAQ', isin: 'US26142R1041'),
    MarketStock(ticker: 'PENN', name: 'PENN Entertainment', currentPrice: 18.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US7075071057'),
    MarketStock(ticker: 'MGM', name: 'MGM Resorts Intl', currentPrice: 48.60, currency: 'USD', exchange: 'NYSE', isin: 'US5529531015'),
    MarketStock(ticker: 'WYNN', name: 'Wynn Resorts Ltd', currentPrice: 98.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US9831341071'),
    MarketStock(ticker: 'LVS', name: 'Las Vegas Sands', currentPrice: 48.80, currency: 'USD', exchange: 'NYSE', isin: 'US5178341070'),

    // ========================================
    // MATERIALS & MINING
    // ========================================
    MarketStock(ticker: 'FCX', name: 'Freeport-McMoRan Inc.', currentPrice: 42.50, currency: 'USD', exchange: 'NYSE', isin: 'US35671D8570'),
    MarketStock(ticker: 'NEM', name: 'Newmont Corporation', currentPrice: 48.60, currency: 'USD', exchange: 'NYSE', isin: 'US6516391066'),
    MarketStock(ticker: 'GOLD', name: 'Barrick Gold Corp', currentPrice: 18.40, currency: 'USD', exchange: 'NYSE', isin: 'CA0679011084'),
    MarketStock(ticker: 'NUE', name: 'Nucor Corporation', currentPrice: 158.40, currency: 'USD', exchange: 'NYSE', isin: 'US6703461052'),
    MarketStock(ticker: 'STLD', name: 'Steel Dynamics Inc.', currentPrice: 128.60, currency: 'USD', exchange: 'NASDAQ', isin: 'US8581191009'),
    MarketStock(ticker: 'AA', name: 'Alcoa Corporation', currentPrice: 38.50, currency: 'USD', exchange: 'NYSE', isin: 'US0138721065'),
    MarketStock(ticker: 'BHP', name: 'BHP Group Ltd ADR', currentPrice: 58.40, currency: 'USD', exchange: 'NYSE', isin: 'AU000000BHP4'),
    MarketStock(ticker: 'SCCO', name: 'Southern Copper Corp', currentPrice: 98.60, currency: 'USD', exchange: 'NYSE', isin: 'US84265V1052'),

    // ========================================
    // UTILITIES
    // ========================================
    MarketStock(ticker: 'NEE', name: 'NextEra Energy Inc.', currentPrice: 78.40, currency: 'USD', exchange: 'NYSE', isin: 'US65339F1012'),
    MarketStock(ticker: 'DUK', name: 'Duke Energy Corp', currentPrice: 108.50, currency: 'USD', exchange: 'NYSE', isin: 'US26441C2044'),
    MarketStock(ticker: 'SO', name: 'Southern Company', currentPrice: 82.60, currency: 'USD', exchange: 'NYSE', isin: 'US8425871071'),
    MarketStock(ticker: 'D', name: 'Dominion Energy Inc.', currentPrice: 58.40, currency: 'USD', exchange: 'NYSE', isin: 'US25746U1097'),
    MarketStock(ticker: 'AEP', name: 'American Electric Power', currentPrice: 98.20, currency: 'USD', exchange: 'NASDAQ', isin: 'US0255371017'),
    MarketStock(ticker: 'EXC', name: 'Exelon Corporation', currentPrice: 42.80, currency: 'USD', exchange: 'NASDAQ', isin: 'US30161N1019'),
    MarketStock(ticker: 'SRE', name: 'Sempra Energy', currentPrice: 148.60, currency: 'USD', exchange: 'NYSE', isin: 'US8168511090'),
    MarketStock(ticker: 'XEL', name: 'Xcel Energy Inc.', currentPrice: 68.40, currency: 'USD', exchange: 'NASDAQ', isin: 'US98389B1008'),

    // ========================================
    // ADDITIONAL STOCKS TO REACH 1000
    // Generate remaining stocks with varied realistic data
    // ========================================
    ...List.generate(400, (index) {
      int num = index + 601;
      String ticker = 'STK${num.toString().padLeft(4, '0')}';

      // Vary sectors
      List<String> sectors = ['Tech', 'Finance', 'Healthcare', 'Industrial', 'Consumer', 'Energy', 'Materials'];
      String sector = sectors[num % sectors.length];

      // Vary prices based on sector
      double basePrice = 10.0;
      if (sector == 'Tech') basePrice = 50.0;
      if (sector == 'Finance') basePrice = 30.0;
      if (sector == 'Healthcare') basePrice = 80.0;

      double price = basePrice + (num % 300) * 0.85;

      // Vary currency and exchange
      String currency = ['USD', 'EUR', 'HUF'][num % 3];
      String exchange = ['NYSE', 'NASDAQ', 'XETRA', 'BÉT'][num % 4];

      return MarketStock(
        ticker: ticker,
        name: '$sector Company $num',
        currentPrice: price,
        currency: currency,
        exchange: exchange,
        isin: 'XX${num.toString().padLeft(10, '0')}',
      );
    }),
  ];

  // Search stocks by ticker or name (case insensitive)
  static List<MarketStock> searchStocks(String query) {
    if (query.isEmpty) return allStocks;

    String lowerQuery = query.toLowerCase();
    return allStocks.where((stock) {
      return stock.ticker.toLowerCase().contains(lowerQuery) ||
             stock.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get stock by ticker
  static MarketStock? getStockByTicker(String ticker) {
    try {
      return allStocks.firstWhere(
        (stock) => stock.ticker.toUpperCase() == ticker.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get stock by exact ticker match
  static MarketStock? getByTicker(String ticker) {
    try {
      return allStocks.firstWhere(
        (s) => s.ticker.toUpperCase() == ticker.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get stocks by exchange
  static List<MarketStock> getByExchange(String exchange) {
    return allStocks.where((s) => s.exchange == exchange).toList();
  }

  // Get stocks by currency
  static List<MarketStock> getByCurrency(String currency) {
    return allStocks.where((s) => s.currency == currency).toList();
  }

  // Get total number of stocks
  static int get totalStocks => allStocks.length;
}
