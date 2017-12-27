require 'rails_helper'

RSpec.describe Offer::Sell, type: :model do

  def soff_params(user = {})
    {
      salable_position_id: pos1.id
    }
  end

  def position_params(opts = {})
    {
      user_id:  user.id       ,
      offer_id: boff.id       ,
    }.merge(opts)
  end

  let(:user)   { FB.create(:user).user                            }
  let(:pos1)   { Position.create(position_params)                 }
  let(:boff)   { FB.create(:offer_bu, user_uuid: user.uuid).offer }
  let(:soff)   { Offer::Sell::Unfixed.create(soff_params)         }

  let(:klas)   { described_class                              }
  subject      { klas.new(soff_params)                        }

  describe "Associations", USE_VCR do
    it { should respond_to(:salable_position)        }
    it { should respond_to(:transfer)                }
  end

  describe "Object Creation", USE_VCR do
    it { should be_valid }

    it 'saves the object to the database' do
      subject.save
      expect(subject).to be_valid
    end
  end

  describe "Associations", USE_VCR do
    before(:each) do hydrate(soff) end

    it "finds the user" do
      expect(soff.salable_position).to eq(pos1)
    end
  end
end

# == Schema Information
#
# Table name: offers
#
#  id                    :integer          not null, primary key
#  type                  :string
#  repo_type             :string
#  user_id               :integer
#  user_uuid             :string
#  prototype_id          :integer
#  prototype_uuid        :string
#  amendment_id          :integer
#  amendment_uuid        :string
#  reoffer_parent_id     :integer
#  reoffer_parent_uuid   :string
#  salable_position_id   :integer
#  salable_position_uuid :string
#  volume                :integer
#  price                 :float
#  value                 :float
#  poolable              :boolean          default(FALSE)
#  aon                   :boolean          default(FALSE)
#  status                :string
#  expiration            :datetime
#  maturation_range      :tsrange
#  xfields               :hstore           not null
#  jfields               :jsonb            not null
#  exid                  :string
#  uuid                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stm_bug_id            :integer
#  stm_bug_uuid          :string
#  stm_repo_id           :integer
#  stm_repo_uuid         :string
#  stm_title             :string
#  stm_status            :string
#  stm_labels            :string
#  stm_xfields           :hstore           not null
#  stm_jfields           :jsonb            not null
#
