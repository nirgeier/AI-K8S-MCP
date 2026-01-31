#### Step 00 - Prerequisites data files

=== "capitals.csv"

    ```csv
    country,capital
    Afghanistan,Kabul
    Albania,Tirana
    Algeria,Algiers
    Andorra,Andorra la Vella
    Angola,Luanda
    Antigua and Barbuda,Saint John's
    Argentina,Buenos Aires
    Armenia,Yerevan
    Australia,Canberra
    Austria,Vienna
    Azerbaijan,Baku
    Bahamas,Nassau
    Bahrain,Manama
    Bangladesh,Dhaka
    Barbados,Bridgetown
    Belarus,Minsk
    Belgium,Brussels
    Belize,Belmopan
    Benin,Porto-Novo
    Bhutan,Thimphu
    Bolivia,Sucre
    Bosnia and Herzegovina,Sarajevo
    Botswana,Gaborone
    Brazil,Brasília
    Brunei,Bandar Seri Begawan
    Bulgaria,Sofia
    Burkina Faso,Ouagadougou
    Burundi,Gitega
    Cabo Verde,Praia
    Cambodia,Phnom Penh
    Cameroon,Yaoundé
    Canada,Ottawa
    Central African Republic,Bangui
    Chad,N'Djamena
    Chile,Santiago
    China,Beijing
    Colombia,Bogotá
    Comoros,Moroni
    Congo,Brazzaville
    Costa Rica,San José
    Côte d'Ivoire,Yamoussoukro
    Croatia,Zagreb
    Cuba,Havana
    Cyprus,Nicosia
    Czechia,Prague
    Denmark,Copenhagen
    Djibouti,Djibouti
    Dominica,Roseau
    Dominican Republic,Santo Domingo
    DRC,Kinshasa
    Ecuador,Quito
    Egypt,Cairo
    El Salvador,San Salvador
    Equatorial Guinea,Malabo
    Eritrea,Asmara
    Estonia,Tallinn
    Eswatini,Mbabane
    Ethiopia,Addis Ababa
    Fiji,Suva
    Finland,Helsinki
    France,Paris
    Gabon,Libreville
    Gambia,Banjul
    Georgia,Tbilisi
    Germany,Berlin
    Ghana,Accra
    Greece,Athens
    Grenada,Saint George's
    Guatemala,Guatemala City
    Guinea,Conakry
    Guinea-Bissau,Bissau
    Guyana,Georgetown
    Haiti,Port-au-Prince
    Honduras,Tegucigalpa
    Hungary,Budapest
    Iceland,Reykjavík
    India,New Delhi
    Indonesia,Jakarta
    Iran,Tehran
    Iraq,Baghdad
    Ireland,Dublin
    Israel,Jerusalem
    Italy,Rome
    Jamaica,Kingston
    Japan,Tokyo
    Jordan,Amman
    Kazakhstan,Astana
    Kenya,Nairobi
    Kiribati,Tarawa
    Kuwait,Kuwait City
    Kyrgyzstan,Bishkek
    Laos,Vientiane
    Latvia,Riga
    Lebanon,Beirut
    Lesotho,Maseru
    Liberia,Monrovia
    Libya,Tripoli
    Liechtenstein,Vaduz
    Lithuania,Vilnius
    Luxembourg,Luxembourg
    Madagascar,Antananarivo
    Malawi,Lilongwe
    Malaysia,Kuala Lumpur
    Maldives,Malé
    Mali,Bamako
    Malta,Valletta
    Marshall Islands,Majuro
    Mauritania,Nouakchott
    Mauritius,Port Louis
    Mexico,Mexico City
    Micronesia,Palikir
    Moldova,Chisinau
    Monaco,Monaco
    Mongolia,Ulaanbaatar
    Montenegro,Podgorica
    Morocco,Rabat
    Mozambique,Maputo
    Myanmar,Naypyidaw
    Namibia,Windhoek
    Nauru,Yaren
    Nepal,Kathmandu
    Netherlands,Amsterdam
    New Zealand,Wellington
    Nicaragua,Managua
    Niger,Niamey
    Nigeria,Abuja
    North Korea,Pyongyang
    North Macedonia,Skopje
    Norway,Oslo
    Oman,Muscat
    Pakistan,Islamabad
    Palau,Ngerulmud
    Panama,Panama City
    Papua New Guinea,Port Moresby
    Paraguay,Asunción
    Peru,Lima
    Philippines,Manila
    Poland,Warsaw
    Portugal,Lisbon
    Qatar,Doha
    Romania,Bucharest
    Russia,Moscow
    Rwanda,Kigali
    Saint Kitts and Nevis,Basseterre
    Saint Lucia,Castries
    Saint Vincent and the Grenadines,Kingstown
    Samoa,Apia
    San Marino,San Marino
    São Tomé and Príncipe,São Tomé
    Saudi Arabia,Riyadh
    Senegal,Dakar
    Serbia,Belgrade
    Seychelles,Victoria
    Sierra Leone,Freetown
    Singapore,Singapore
    Slovakia,Bratislava
    Slovenia,Ljubljana
    Solomon Islands,Honiara
    Somalia,Mogadishu
    South Africa,Pretoria
    South Korea,Seoul
    South Sudan,Juba
    Spain,Madrid
    Sri Lanka,Sri Jayawardenepura Kotte
    Sudan,Khartoum
    Suriname,Paramaribo
    Sweden,Stockholm
    Switzerland,Bern
    Syria,Damascus
    Taiwan,Taipei
    Tajikistan,Dushanbe
    Tanzania,Dodoma
    Thailand,Bangkok
    Timor-Leste,Dili
    Togo,Lomé
    Tonga,Nuku'alofa
    Trinidad and Tobago,Port of Spain
    Tunisia,Tunis
    Turkey,Ankara
    Turkmenistan,Ashgabat
    Tuvalu,Funafuti
    Uganda,Kampala
    Ukraine,Kyiv
    United Arab Emirates,Abu Dhabi
    United Kingdom,London
    United States,Washington D.C.
    Uruguay,Montevideo
    Uzbekistan,Tashkent
    Vanuatu,Port Vila
    Venezuela,Caracas
    Vietnam,Hanoi
    Yemen,Sana'a
    Zambia,Lusaka
    Zimbabwe,Harare
    ```

=== "foundation_year.csv"

    ```csv
    country,foundation_year
    Afghanistan,1919
    Albania,1912
    Algeria,1962
    Andorra,1278
    Angola,1975
    Antigua and Barbuda,1981
    Argentina,1816
    Armenia,1991
    Australia,1901
    Austria,1955
    Azerbaijan,1991
    Bahamas,1973
    Bahrain,1971
    Bangladesh,1971
    Barbados,1966
    Belarus,1991
    Belgium,1830
    Belize,1981
    Benin,1960
    Bhutan,1907
    Bolivia,1825
    Bosnia and Herzegovina,1992
    Botswana,1966
    Brazil,1822
    Brunei,1984
    Bulgaria,1908
    Burkina Faso,1960
    Burundi,1962
    Cabo Verde,1975
    Cambodia,1953
    Cameroon,1960
    Canada,1867
    Central African Republic,1960
    Chad,1960
    Chile,1818
    China,1949
    Colombia,1810
    Comoros,1975
    Congo,1960
    Costa Rica,1821
    Côte d'Ivoire,1960
    Croatia,1991
    Cuba,1902
    Cyprus,1960
    Czechia,1993
    Denmark,1849
    Djibouti,1977
    Dominica,1978
    Dominican Republic,1844
    DRC,1960
    Ecuador,1830
    Egypt,1922
    El Salvador,1821
    Equatorial Guinea,1968
    Eritrea,1993
    Estonia,1991
    Eswatini,1968
    Ethiopia,-100
    Fiji,1970
    Finland,1917
    France,843
    Gabon,1960
    Gambia,1965
    Georgia,1991
    Germany,1871
    Ghana,1957
    Greece,1821
    Grenada,1974
    Guatemala,1821
    Guinea,1958
    Guinea-Bissau,1973
    Guyana,1966
    Haiti,1804
    Honduras,1821
    Hungary,1000
    Iceland,1944
    India,1947
    Indonesia,1945
    Iran,1501
    Iraq,1932
    Ireland,1921
    Israel,1948
    Italy,1861
    Jamaica,1962
    Japan,660
    Jordan,1946
    Kazakhstan,1991
    Kenya,1963
    Kiribati,1979
    Kuwait,1961
    Kyrgyzstan,1991
    Laos,1953
    Latvia,1991
    Lebanon,1943
    Lesotho,1966
    Liberia,1847
    Libya,1951
    Liechtenstein,1719
    Lithuania,1990
    Luxembourg,1890
    Madagascar,1960
    Malawi,1964
    Malaysia,1957
    Maldives,1965
    Mali,1960
    Malta,1964
    Marshall Islands,1986
    Mauritania,1960
    Mauritius,1968
    Mexico,1821
    Micronesia,1986
    Moldova,1991
    Monaco,1297
    Mongolia,1921
    Montenegro,2006
    Morocco,1956
    Mozambique,1975
    Myanmar,1948
    Namibia,1990
    Nauru,1968
    Nepal,1768
    Netherlands,1581
    New Zealand,1907
    Nicaragua,1821
    Niger,1960
    Nigeria,1960
    North Korea,1948
    North Macedonia,1991
    Norway,1905
    Oman,1650
    Pakistan,1947
    Palau,1994
    Panama,1903
    Papua New Guinea,1975
    Paraguay,1811
    Peru,1821
    Philippines,1898
    Poland,1918
    Portugal,1143
    Qatar,1971
    Romania,1859
    Russia,1991
    Rwanda,1962
    Saint Kitts and Nevis,1983
    Saint Lucia,1979
    Saint Vincent and the Grenadines,1979
    Samoa,1962
    San Marino,301
    São Tomé and Príncipe,1975
    Saudi Arabia,1932
    Senegal,1960
    Serbia,2006
    Seychelles,1976
    Sierra Leone,1961
    Singapore,1965
    Slovakia,1993
    Slovenia,1991
    Solomon Islands,1978
    Somalia,1960
    South Africa,1910
    South Korea,1948
    South Sudan,2011
    Spain,1469
    Sri Lanka,1948
    Sudan,1956
    Suriname,1975
    Sweden,1523
    Switzerland,1291
    Syria,1946
    Taiwan,1949
    Tajikistan,1991
    Tanzania,1961
    Thailand,1238
    Timor-Leste,2002
    Togo,1960
    Tonga,1839
    Trinidad and Tobago,1962
    Tunisia,1956
    Turkey,1923
    Turkmenistan,1991
    Tuvalu,1978
    Uganda,1962
    Ukraine,1991
    United Arab Emirates,1971
    United Kingdom,1066
    United States,1776
    Uruguay,1825
    Uzbekistan,1991
    Vanuatu,1980
    Venezuela,1811
    Vietnam,1945
    Yemen,1990
    Zambia,1964
    Zimbabwe,1980
    ```

=== "height.csv"

    ```csv
    country,height
    Afghanistan,1884
    Albania,708
    Algeria,800
    Andorra,1996
    Angola,1112
    Antigua and Barbuda,65
    Argentina,595
    Armenia,1792
    Australia,330
    Austria,910
    Azerbaijan,384
    Bahamas,13
    Bahrain,35
    Bangladesh,85
    Barbados,180
    Belarus,160
    Belgium,181
    Belize,173
    Benin,273
    Bhutan,3280
    Bolivia,1192
    Bosnia and Herzegovina,500
    Botswana,1013
    Brazil,320
    Brunei,478
    Bulgaria,472
    Burkina Faso,297
    Burundi,1504
    Cabo Verde,450
    Cambodia,126
    Cameroon,667
    Canada,487
    Central African Republic,635
    Chad,543
    Chile,1871
    China,1840
    Colombia,593
    Comoros,719
    Congo,430
    Costa Rica,746
    Côte d'Ivoire,250
    Croatia,331
    Cuba,108
    Cyprus,91
    Czechia,433
    Denmark,34
    Djibouti,430
    Dominica,572
    Dominican Republic,424
    DRC,726
    Ecuador,1117
    Egypt,321
    El Salvador,442
    Equatorial Guinea,577
    Eritrea,853
    Estonia,61
    Eswatini,305
    Ethiopia,1330
    Fiji,132
    Finland,164
    France,375
    Gabon,377
    Gambia,34
    Georgia,1431
    Germany,263
    Ghana,190
    Greece,498
    Grenada,260
    Guatemala,759
    Guinea,472
    Guinea-Bissau,70
    Guyana,207
    Haiti,470
    Honduras,684
    Hungary,143
    Iceland,557
    India,160
    Indonesia,367
    Iran,1308
    Iraq,312
    Ireland,118
    Israel,508
    Italy,538
    Jamaica,253
    Japan,438
    Jordan,812
    Kazakhstan,387
    Kenya,762
    Kiribati,2
    Kuwait,108
    Kyrgyzstan,2988
    Laos,710
    Latvia,87
    Lebanon,1250
    Lesotho,2161
    Liberia,243
    Libya,423
    Liechtenstein,1706
    Lithuania,110
    Luxembourg,325
    Madagascar,615
    Malawi,779
    Malaysia,538
    Maldives,2
    Mali,343
    Malta,91
    Marshall Islands,2
    Mauritania,276
    Mauritius,370
    Mexico,1111
    Micronesia,107
    Moldova,147
    Monaco,63
    Mongolia,1528
    Montenegro,1086
    Morocco,909
    Mozambique,345
    Myanmar,702
    Namibia,1141
    Nauru,21
    Nepal,3265
    Netherlands,30
    New Zealand,388
    Nicaragua,298
    Niger,474
    Nigeria,380
    North Korea,440
    North Macedonia,741
    Norway,460
    Oman,310
    Pakistan,900
    Palau,63
    Panama,360
    Papua New Guinea,667
    Paraguay,178
    Peru,1555
    Philippines,442
    Poland,173
    Portugal,372
    Qatar,28
    Romania,414
    Russia,600
    Rwanda,1598
    Saint Kitts and Nevis,261
    Saint Lucia,301
    Saint Vincent and the Grenadines,390
    Samoa,109
    San Marino,749
    São Tomé and Príncipe,204
    Saudi Arabia,665
    Senegal,69
    Serbia,442
    Seychelles,284
    Sierra Leone,279
    Singapore,15
    Slovakia,458
    Slovenia,492
    Solomon Islands,458
    Somalia,410
    South Africa,1033
    South Korea,282
    South Sudan,422
    Spain,660
    Sri Lanka,228
    Sudan,568
    Suriname,246
    Sweden,320
    Switzerland,1350
    Syria,514
    Taiwan,1121
    Tajikistan,3186
    Tanzania,1018
    Thailand,287
    Timor-Leste,552
    Togo,236
    Tonga,72
    Trinidad and Tobago,83
    Tunisia,246
    Turkey,1132
    Turkmenistan,230
    Tuvalu,2
    Uganda,1100
    Ukraine,175
    United Arab Emirates,149
    United Kingdom,162
    United States,760
    Uruguay,109
    Uzbekistan,450
    Vanuatu,646
    Venezuela,450
    Vietnam,398
    Yemen,999
    Zambia,1138
    Zimbabwe,961
    ```

    === "population.csv"

    ```csv
    country,population
    Afghanistan,40000000
    Albania,2800000
    Algeria,45000000
    Andorra,80000
    Angola,35000000
    Antigua and Barbuda,100000
    Argentina,46000000
    Armenia,3000000
    Australia,26000000
    Austria,9000000
    Azerbaijan,10000000
    Bahamas,400000
    Bahrain,1800000
    Bangladesh,170000000
    Barbados,300000
    Belarus,9200000
    Belgium,11600000
    Belize,400000
    Benin,13000000
    Bhutan,800000
    Bolivia,12000000
    Bosnia and Herzegovina,3200000
    Botswana,2400000
    Brazil,216000000
    Brunei,450000
    Bulgaria,6400000
    Burkina Faso,23000000
    Burundi,13000000
    Cabo Verde,600000
    Cambodia,17000000
    Cameroon,28000000
    Canada,39000000
    Central African Republic,5000000
    Chad,18000000
    Chile,20000000
    China,1412000000
    Colombia,52000000
    Comoros,900000
    Congo,6000000
    Costa Rica,5200000
    Côte d'Ivoire,29000000
    Croatia,3800000
    Cuba,11100000
    Cyprus,1300000
    Czechia,10700000
    Denmark,5900000
    Djibouti,1100000
    Dominica,72000
    Dominican Republic,11000000
    DRC,100000000
    Ecuador,18000000
    Egypt,110000000
    El Salvador,6500000
    Equatorial Guinea,1700000
    Eritrea,3700000
    Estonia,1300000
    Eswatini,1200000
    Ethiopia,125000000
    Fiji,900000
    Finland,5600000
    France,68000000
    Gabon,2400000
    Gambia,2700000
    Georgia,3700000
    Germany,83000000
    Ghana,34000000
    Greece,10200000
    Grenada,120000
    Guatemala,19000000
    Guinea,14000000
    Guinea-Bissau,2100000
    Guyana,800000
    Haiti,11700000
    Honduras,11000000
    Hungary,9600000
    Iceland,380000
    India,1418000000
    Indonesia,280000000
    Iran,89000000
    Iraq,44000000
    Ireland,5200000
    Israel,9700000
    Italy,59000000
    Jamaica,3000000
    Japan,124000000
    Jordan,11000000
    Kazakhstan,20000000
    Kenya,57000000
    Kiribati,130000
    Kuwait,4300000
    Kyrgyzstan,6800000
    Laos,7500000
    Latvia,1800000
    Lebanon,5500000
    Lesotho,2300000
    Liberia,5300000
    Libya,7200000
    Liechtenstein,39000
    Lithuania,2700000
    Luxembourg,660000
    Madagascar,30000000
    Malawi,21000000
    Malaysia,34000000
    Maldives,600000
    Mali,23000000
    Malta,570000
    Marshall Islands,42000
    Mauritania,4900000
    Mauritius,1300000
    Mexico,128000000
    Micronesia,110000
    Moldova,2500000
    Monaco,40000
    Mongolia,3400000
    Montenegro,620000
    Morocco,38000000
    Mozambique,33000000
    Myanmar,55000000
    Namibia,2600000
    Nauru,11000
    Nepal,31000000
    Netherlands,17800000
    New Zealand,5200000
    Nicaragua,6900000
    Niger,27000000
    Nigeria,230000000
    North Korea,26000000
    North Macedonia,1800000
    Norway,5500000
    Oman,5500000
    Pakistan,240000000
    Palau,18000
    Panama,4500000
    Papua New Guinea,10000000
    Paraguay,7200000
    Peru,34000000
    Philippines,117000000
    Poland,38000000
    Portugal,10200000
    Qatar,2900000
    Romania,19000000
    Russia,144000000
    Rwanda,14000000
    Saint Kitts and Nevis,54000
    Saint Lucia,180000
    Saint Vincent and the Grenadines,110000
    Samoa,225000
    San Marino,34000
    São Tomé and Príncipe,230000
    Saudi Arabia,37000000
    Senegal,18000000
    Serbia,6600000
    Seychelles,100000
    Sierra Leone,8600000
    Singapore,6000000
    Slovakia,5500000
    Slovenia,2100000
    Solomon Islands,720000
    Somalia,18000000
    South Africa,62000000
    South Korea,52000000
    South Sudan,13000000
    Spain,48000000
    Sri Lanka,22000000
    Sudan,48000000
    Suriname,620000
    Sweden,10500000
    Switzerland,8800000
    Syria,23000000
    Taiwan,23600000
    Tajikistan,10000000
    Tanzania,65000000
    Thailand,72000000
    Timor-Leste,1400000
    Togo,9000000
    Tonga,110000
    Trinidad and Tobago,1400000
    Tunisia,12400000
    Turkey,86000000
    Turkmenistan,6500000
    Tuvalu,12000
    Uganda,49000000
    Ukraine,36000000
    United Arab Emirates,10000000
    United Kingdom,68000000
    United States,345000000
    Uruguay,3500000
    Uzbekistan,36000000
    Vanuatu,320000
    Venezuela,28000000
    Vietnam,99000000
    Yemen,32000000
    Zambia,20000000
    Zimbabwe,16000000
    ```

=== "population.csv"

    ```csv
    country,population
    Afghanistan,40000000
    Albania,2800000
    Algeria,45000000
    Andorra,80000
    Angola,35000000
    Antigua and Barbuda,100000
    Argentina,46000000
    Armenia,3000000
    Australia,26000000
    Austria,9000000
    Azerbaijan,10000000
    Bahamas,400000
    Bahrain,1800000
    Bangladesh,170000000
    Barbados,300000
    Belarus,9200000
    Belgium,11600000
    Belize,400000
    Benin,13000000
    Bhutan,800000
    Bolivia,12000000
    Bosnia and Herzegovina,3200000
    Botswana,2400000
    Brazil,216000000
    Brunei,450000
    Bulgaria,6400000
    Burkina Faso,23000000
    Burundi,13000000
    Cabo Verde,600000
    Cambodia,17000000
    Cameroon,28000000
    Canada,39000000
    Central African Republic,5000000
    Chad,18000000
    Chile,20000000
    China,1412000000
    Colombia,52000000
    Comoros,900000
    Congo,6000000
    Costa Rica,5200000
    Côte d'Ivoire,29000000
    Croatia,3800000
    Cuba,11100000
    Cyprus,1300000
    Czechia,10700000
    Denmark,5900000
    Djibouti,1100000
    Dominica,72000
    Dominican Republic,11000000
    DRC,100000000
    Ecuador,18000000
    Egypt,110000000
    El Salvador,6500000
    Equatorial Guinea,1700000
    Eritrea,3700000
    Estonia,1300000
    Eswatini,1200000
    Ethiopia,125000000
    Fiji,900000
    Finland,5600000
    France,68000000
    Gabon,2400000
    Gambia,2700000
    Georgia,3700000
    Germany,83000000
    Ghana,34000000
    Greece,10200000
    Grenada,120000
    Guatemala,19000000
    Guinea,14000000
    Guinea-Bissau,2100000
    Guyana,800000
    Haiti,11700000
    Honduras,11000000
    Hungary,9600000
    Iceland,380000
    India,1418000000
    Indonesia,280000000
    Iran,89000000
    Iraq,44000000
    Ireland,5200000
    Israel,9700000
    Italy,59000000
    Jamaica,3000000
    Japan,124000000
    Jordan,11000000
    Kazakhstan,20000000
    Kenya,57000000
    Kiribati,130000
    Kuwait,4300000
    Kyrgyzstan,6800000
    Laos,7500000
    Latvia,1800000
    Lebanon,5500000
    Lesotho,2300000
    Liberia,5300000
    Libya,7200000
    Liechtenstein,39000
    Lithuania,2700000
    Luxembourg,660000
    Madagascar,30000000
    Malawi,21000000
    Malaysia,34000000
    Maldives,600000
    Mali,23000000
    Malta,570000
    Marshall Islands,42000
    Mauritania,4900000
    Mauritius,1300000
    Mexico,128000000
    Micronesia,110000
    Moldova,2500000
    Monaco,40000
    Mongolia,3400000
    Montenegro,620000
    Morocco,38000000
    Mozambique,33000000
    Myanmar,55000000
    Namibia,2600000
    Nauru,11000
    Nepal,31000000
    Netherlands,17800000
    New Zealand,5200000
    Nicaragua,6900000
    Niger,27000000
    Nigeria,230000000
    North Korea,26000000
    North Macedonia,1800000
    Norway,5500000
    Oman,5500000
    Pakistan,240000000
    Palau,18000
    Panama,4500000
    Papua New Guinea,10000000
    Paraguay,7200000
    Peru,34000000
    Philippines,117000000
    Poland,38000000
    Portugal,10200000
    Qatar,2900000
    Romania,19000000
    Russia,144000000
    Rwanda,14000000
    Saint Kitts and Nevis,54000
    Saint Lucia,180000
    Saint Vincent and the Grenadines,110000
    Samoa,225000
    San Marino,34000
    São Tomé and Príncipe,230000
    Saudi Arabia,37000000
    Senegal,18000000
    Serbia,6600000
    Seychelles,100000
    Sierra Leone,8600000
    Singapore,6000000
    Slovakia,5500000
    Slovenia,2100000
    Solomon Islands,720000
    Somalia,18000000
    South Africa,62000000
    South Korea,52000000
    South Sudan,13000000
    Spain,48000000
    Sri Lanka,22000000
    Sudan,48000000
    Suriname,620000
    Sweden,10500000
    Switzerland,8800000
    Syria,23000000
    Taiwan,23600000
    Tajikistan,10000000
    Tanzania,65000000
    Thailand,72000000
    Timor-Leste,1400000
    Togo,9000000
    Tonga,110000
    Trinidad and Tobago,1400000
    Tunisia,12400000
    Turkey,86000000
    Turkmenistan,6500000
    Tuvalu,12000
    Uganda,49000000
    Ukraine,36000000
    United Arab Emirates,10000000
    United Kingdom,68000000
    United States,345000000
    Uruguay,3500000
    Uzbekistan,36000000
    Vanuatu,320000
    Venezuela,28000000
    Vietnam,99000000
    Yemen,32000000
    Zambia,20000000
    Zimbabwe,16000000
    ```

=== "requirements.txt"

    ```plaintext
    mcp>=0.1.0
    ollama>=0.1.0
    pandas>=1.3.0
    requests>=2.25.0
    ```
