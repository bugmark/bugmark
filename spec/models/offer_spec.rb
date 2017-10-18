require 'rails_helper'

RSpec.describe Offer, type: :model do
  def valid_params(extras = {})
    {
      user_id: user.id                                      ,
      maturation_period: Time.now-1.week..Time.now+1.week   ,
      status:  'open'                                       ,
    }.merge(extras)
  end

  def offer3(extras) klas.new(valid_params(extras)) end
  let(:offer2) { klas.new(valid_params)  }
  let(:user)   { FG.create(:user)        }
  let(:klas)   { described_class         }
  subject      { klas.new(valid_params)  }

  describe "Associations" do
    it { should respond_to(:user)               }
    it { should respond_to(:bug)                }
    it { should respond_to(:repo)               }
    it { should respond_to(:position)           }
  end

  describe "Attributes" do
    it { should respond_to :exref               }
    it { should respond_to :uuref               }
  end

  describe "Instance Methods" do
    it { should respond_to(:match_bugs) }
  end

  describe "Object Creation" do
    it { should be_valid }

    it 'saves the object to the database' do
      subject.save
      expect(subject).to be_valid
    end
  end

  describe "Scopes" do
    it 'has scope methods' do
      expect(klas).to respond_to :base_scope
      expect(klas).to respond_to :by_id
      expect(klas).to respond_to :by_repoid
      expect(klas).to respond_to :by_title
      expect(klas).to respond_to :by_status
      expect(klas).to respond_to :by_labels
    end
  end

  describe ".by_id" do
    before(:each) { subject.save}

    it 'returns a matching record' do
      expect(klas.by_id(subject.id).count).to eq(1)
    end
  end

  describe ".match" do
    before(:each) { subject.save}

    it 'matches id' do
      expect(subject).to_not be_nil
      expect(klas.count).to eq(1)
      expect(klas.match({id: subject.id}).length).to eq(1)
    end
  end

  describe ".by_overlap_maturation_period" do
    before(:each) { subject.save }

    it "returns a range search" do
      result = klas.by_overlap_maturation_period(Time.now..Time.now+1.minute)
      expect(result.length).to eq(1)
    end

    it "returns zero when there is a miss" do
      result = klas.by_overlap_maturation_period(Time.now-2.years..Time.now-1.year)
      expect(result.length).to eq(0)
    end
  end

  describe ".by_overlap_maturation_date" do
    before(:each) { subject.save }

    it "returns a date search" do
      result = klas.by_overlap_maturation_date(Time.now)
      expect(result.length).to eq(1)
    end

    it "returns zero when there is a miss" do
      result = klas.by_overlap_maturation_date(Time.now-2.years)
      expect(result.length).to eq(0)
    end
  end

  describe ".open" do
    it "works" do
      subject.save
      expect(Offer.open.count).to eq(1)
      expect(Offer.not_open.count).to eq(0)
    end

  end

  describe "#overlap_offers" do
    before(:each) { subject.save }

    it "returns one with alternate offer" do
      result = offer2.overlap_offers
      expect(result.count).to eq(1)
    end

    it "returns zero with base offer" do
      result = subject.overlap_offers
      expect(result.count).to eq(0)
    end
  end

  describe "#cross_offers" do
    before(:each) { subject.save }

    it "returns none" do
      result = subject.cross_offers
      expect(result.count).to eq(0)
    end

    it "returns one with high price" do
      obj = offer3(price: 0.9)
      result = obj.cross_offers
      expect(result.count).to eq(1)
    end

    it "returns zero with low price" do
      obj = offer3(price: 0.1)
      result = obj.cross_offers
      expect(result.count).to eq(0)
    end
  end

  describe "#uuref" do
    it 'generates a string' do
      subject.save
      expect(subject.uuref).to be_a(String)
    end

    it 'generates a 36-character string' do
      subject.save
      expect(subject.uuref.length).to eq(36)
    end
  end
end

# == Schema Information
#
# Table name: offers
#
#  id                  :integer          not null, primary key
#  type                :string
#  repo_type           :string
#  user_id             :integer
#  parent_id           :integer
#  position_id         :integer
#  counter_id          :integer
#  volume              :integer          default(1)
#  price               :float            default(0.5)
#  poolable            :boolean          default(TRUE)
#  aon                 :boolean          default(FALSE)
#  status              :string
#  offer_expiration    :datetime
#  contract_maturation :datetime
#  maturation_period   :tsrange
#  jfields             :jsonb            not null
#  exref               :string
#  uuref               :string
#  stm_bug_id          :integer
#  stm_repo_id         :integer
#  stm_title           :string
#  stm_status          :string
#  stm_labels          :string
#  stm_xfields         :hstore           not null
#  stm_jfields         :jsonb            not null
#
