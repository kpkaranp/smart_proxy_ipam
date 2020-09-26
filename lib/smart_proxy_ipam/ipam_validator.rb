# Module containing validation methods for use by all External IPAM provider implementations
module Proxy::Ipam::IpamValidator
  include ::Proxy::Validations

  def validate_required_params!(required_params, params)
    err = []
    required_params.each do |param|
      unless params[param.to_sym]
        err.push errors[param.to_sym]
      end
    end
    raise Proxy::Validations::Error, err unless err.empty?
  end

  def validate_ip!(ip)
    IPAddr.new(ip).to_s
  rescue IPAddr::InvalidAddressError => e
    raise Proxy::Validations::Error, e.to_s
  end

  def validate_cidr!(address, prefix)
    cidr = "#{address}/#{prefix}"
    network = IPAddr.new(cidr).to_s
    if IPAddr.new(cidr).to_s != IPAddr.new(address).to_s
      raise Proxy::Validations::Error, "Network address #{address} should be #{network} with prefix #{prefix}"
    end
    cidr
  rescue IPAddr::Error => e
    raise Proxy::Validations::Error, e.to_s
  end

  def validate_ip_in_cidr!(ip, cidr)
    unless IPAddr.new(cidr).include?(IPAddr.new(ip))
      raise Proxy::Validations::Error.new, "IP #{ip} is not in #{cidr}"
    end
  end

  def validate_mac!(mac)
    unless mac.match(/^([0-9a-fA-F]{2}[:]){5}[0-9a-fA-F]{2}$/i)
      raise Proxy::Validations::Error.new, 'Mac address is not valid'
    end
    mac
  end
end
