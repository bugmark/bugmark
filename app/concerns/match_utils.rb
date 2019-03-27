module MatchUtils
  extend ActiveSupport::Concern

  def match_attrs
    {
      stm_issue_uuid:  self.stm_issue_uuid   ,
      stm_tracker_uuid: self.stm_tracker_uuid  ,
      stm_title:     self.stm_title      ,
      stm_status:    self.stm_status     ,
      stm_labels:    self.stm_labels     ,
    }
  end

  def match()                 Offer.match(match_attrs)            end
  def match_issues()          Issue.match(match_attrs)            end
  def match_contracts()       Contract.match(match_attrs)         end
  def match_offers()          Offer.match(match_attrs)            end

  def match_buy_offers()  Offer::Buy.match(match_attrs)           end
  def match_bu_offers()   Offer::Buy::Unfixed.match(match_attrs)  end
  def match_bf_offers()   Offer::Buy::Fixed.match(match_attrs)    end
  def match_sell_offers() Offer::Sell.match(match_attrs)          end
  def match_su_offers()   Offer::Sell::Unfixed.match(match_attrs) end
  def match_sf_offers()   Offer::Sell::Fixed.match(match_attrs)   end

  module ClassMethods

    # ----- SCOPES -----

    def base_scope
      where(false)
    end

    def by_id(id)
      where(id: id)
    end

    def by_issue_uuid(uuid)
      where(stm_issue_uuid: uuid)
    end

    def by_tracker_uuid(uuid)
      where(stm_tracker_uuid: uuid)
    end

    def by_title(string)
      where("title ilike ?", string)
    end

    def by_status(status)
      where("stm_status ilike ?", status)
    end

    def by_labels(labels)
      # where(labels: labels)
      where(false)
    end

    # -----

    def matches(obj)
      match(obj.match_attrs)
    end

    # this is our core match algorithm
    # it looks at a statement to do a database query
    # this generatres a sql query
    def match(attrs)
      # {:stm_issue_uuid: "sadf", ...}
      # methods that operate on collections (array, hash, stream)
      # - map - transforms each element of the collection [1,2,3] -> [4,5,6]
      # - reduce - returns a single element for the collection [1,2,3] -> 6
      # - select - gives you a subset of elements [2,3,4,5,6] -> [2,4,6]
      # we're generating a sql query
      # base scope is 'select * from "offers"'
      # -select * from offers where stm_issue_id == "value"
      # -select * from offers where stm_issue_id == "value" and stm_title contains "word"
      # -select * from offers where stm_issue_id == "value" and stm_title contains "word" and "..."
      attrs.without_blanks.reduce(base_scope) do |acc, (key, val)|
        scope_for(acc, key, val)
      end
    end

    private

    def scope_for(base, key, val)
      case key
        when :stm_issue_uuid then
          base.by_issue_uuid(val)
        when :stm_tracker_uuid then
          base.by_tracker_uuid(val)
        when :stm_title then
          base.by_title(val)
        when :stm_status then
          base.by_status(val)
        when :stm_labels then
          base.by_labels(val)
        else base
      end
    end
  end
end
