class Escrow::Resolve < Escrow

end

# == Schema Information
#
# Table name: escrows
#
#  id            :integer          not null, primary key
#  type          :string
#  sequence      :integer
#  contract_id   :integer
#  amendment_id  :integer
#  fixed_value   :float            default(0.0)
#  unfixed_value :float            default(0.0)
#  exref         :string
#  uuref         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
