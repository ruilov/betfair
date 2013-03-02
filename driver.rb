require "rubygems"
require "net/http"
require "uri"
require 'nokogiri'

uri = URI.parse("http://www.betfair.com/exchange/football/event?id=26967072")
# puts uri.path
http = Net::HTTP.new(uri.host)
res = http.get(uri.path)
puts res

# uri = URI.parse("http://www.anp.gov.br/preco/prc/Resumo_Semanal_Tipologia.asp")
# 
# (700..710).each do |week|
  # res = Net::HTTP.post_form(uri, {
      # # "selSemana" => "710*de 20/01/2013 a 26/01/2013",
      # "selSemana" => "#{week}*",
      # # "desc_Semana" => "de 20/01/2013 a 26/01/2013",
      # # "cod_Semana" => "710",
      # "tipo" => "2",
      # "rdResumo" => "4",
      # "selEstado" => "AC*ACRE",
      # "selCombustivel" => "487*Gasolina"
  # })
#   
  # print "#{week}|"
  # doc = Nokogiri::HTML(res.body)
  # rows = doc.xpath("//table//tr")
  # (3...(rows.length)).each do |ri|
    # row = rows[ri]
    # cols = row.xpath(".//td")
#     
    # city = cols[0].content
    # consumer_avg = cols[3].content.gsub(",",".").to_f
    # distrib_avg = cols[8].content.gsub(",",".").to_f
    # print "#{consumer_avg}|#{distrib_avg}|"
  # end
  # puts ""
# end