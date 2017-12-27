class Amendment::Transfer < Amendment

end

# == Schema Information
#
# Table name: amendments
#
#  id            :integer          not null, primary key
#  type          :string
#  sequence      :integer
#  contract_id   :integer
#  contract_uuid :string
#  xfields       :hstore           not null
#  jfields       :jsonb            not null
#  exid          :string
#  uuid          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
