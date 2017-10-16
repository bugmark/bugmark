module Core
  class BidsController < ApplicationController

    layout 'core'

    before_action :authenticate_user!, :except => [:index, :show]

    # bug_id (optional)
    def index
      @bug = @repo = nil
      @timestamp = Time.now.strftime("%H:%M:%S")
      case
        when bug_id = params["bug_id"]&.to_i
          @bug = Bug.find(bug_id)
          @bids = Offer::Buy::Bid.where(bug_id: bug_id)
        when repo_id = params["repo_id"]&.to_i
          @repo = Repo.find(repo_id)
          @bids = Offer::Buy::Bid.where(repo_id: repo_id)
        else
          @bids = Offer::Buy::Bid.all
      end
    end

    def show
      @bid = Offer::Buy::Bid.find(params["id"])
    end

    def new
      @bid = BidBuyCmd::Create.new(new_opts(params))
    end

    # id (contract ID)
    def edit
      # @bid = ContractCmd::Take.find(params[:id], with_counterparty: current_user)
    end

    def create
      opts = params["bid_buy_cmd_create"]
      @bid = BidBuyCmd::Create.new(valid_params(opts))
      if @bid.save_event.project
        redirect_to("/core/bids/#{@bid.id}")
      else
        render 'core/bids/new'
      end
    end

    def update
      # opts = params["contract_cmd_take"]
      # @bid = ContractCmd::Take.find(opts["id"], with_counterparty: current_user)
      # if @bid.save_event.project
      #   redirect_to("/bids/#{@bid.id}")
      # else
      #   render 'bids/new'
      # end
    end

    private

    def valid_params(params)
      fields = Offer::Buy::Bid.attribute_names.map(&:to_sym)
      params.permit(fields)
    end

    def new_opts(params)
      opts = {
        price:       0.50                     ,
        volume:      5                        ,
        user_id:     current_user.id          ,
        status:      "open"                   ,
        bug_status:  "closed"                 ,
        maturation_date: Time.now + 3.minutes ,
      }
      key = "bug_id" if params["bug_id"]
      key = "repo_id" if params["repo_id"]
      id = params["bug_id"] || params["repo_id"]
      opts.merge({key => id}).without_blanks
    end
  end
end
