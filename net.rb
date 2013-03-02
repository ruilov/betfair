# THIS IS THE MODULE FOR NETWORK STUFF

require 'net/http' 
require 'uri'

module Net
  
  def Net::http_get(uri,params={})
    path = Net::make_path(uri)
    http = Net::HTTP.new(uri.host)
    res = http.get(path,params)
    # puts res
    # res.each {|key,val| print key,": ",val,"\n"}
    return res
  end
  
  def Net::http_post(uri,params={})
    path = Net::make_path(uri)
    http = Net::HTTP.new(uri.host)
    res = http.post(path,{},params)
    return res
  end
  
  # uri can also just be the string, in which case we'll parse it
  def Net::make_path(uri)
    if uri.is_a?(String)      
      uri = URI.parse(uri)
    end    
    path = uri.path
    if uri.query; path += "?" + uri.query end
    return path
  end
  
  def Net::make_url(domain,path)
    uri = URI.parse(domain)
    return uri.merge(path)
  end
end
