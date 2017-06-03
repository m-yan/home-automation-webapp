FactoryGirl.define do
  factory :house do
    hgw_id "hgw1"
    name "HGW1"
    ip_address "192.168.0.1"
    factory :house_2 do
      name "HGW2"
    end
  end
end
