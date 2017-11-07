module Core
  class FullOffersController < ApplicationController

    layout 'core'

    def index
      @bids = Unfixed.unassigned
      @asks = Fixed.unassigned
    end

    # def cross
    #   ask_id = params["id"]
    #   result = ContractCmd::Cross.new(ask_id).save_event.project
    #   if result
    #     redirect_to "/rewards/#{result.id}"
    #   else
    #     redirect_to "/rewards"
    #   end
    # end
  end
end