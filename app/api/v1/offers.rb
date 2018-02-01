require 'time'

module V1
  class Offers < V1::App

    resource :offers do

      # ---------- list all contracts ----------
      desc "List all offers", {
        is_array: true ,
        success: Entities::OfferOverview
      }
      params do
        optional :type   , type: String  , desc: "type"
        optional :status , type: String  , desc: "status"
        optional :limit  , type: Integer , desc: "limit"
      end
      get do
        scope = Offer.all
        scope = scope.where("type like ?", "%#{params[:type]}%") if params[:type]
        scope = scope.where(status: params[:status]) if params[:status]
        scope = scope.limit(params[:limit]) if params[:limit]
        present(scope.all, with: Entities::OfferOverview)
      end

      # ---------- list offer detail ----------
      desc "Show offer detail", {
        success: Entities::OfferDetail
      }
      get ':uuid' do
        offer = Offer.find_by_uuid(params[:uuid])
        offer ? offer_details(offer) : error!("Not found", 404)
      end

      # ---------- create buy offer ----------
      desc "Create a buy offer", {
        success:  Entities::OfferCreated    ,
        consumes: ['multipart/form-data']
      }
      params do
        requires :side       , type: String  , desc: "fixed or unfixed"   , values: %w(fixed unfixed)
        requires :volume     , type: Integer , desc: "number of positions"#, values: ->(x){x > 0}
        requires :price      , type: Float   , desc: "between 0.0 and 1.0", values: 0.00..1.00
        requires :issue      , type: String  , desc: "issue UUID"
        optional :maturation , type: String  , desc: "YYMMDD_HHMM (default now + 1.week)"
        optional :expiration , type: String  , desc: "YYMMDD_HHMM (default now + 1.day)"
        optional :poolable   , type: Boolean , desc: "poolable? (default false)"   , default: false
        optional :aon        , type: Boolean , desc: "all-or-none? (default false)", default: false
      end
      post '/buy' do
        side = case params[:side]
          when "fixed" then :offer_bf
          when "unfixed" then :offer_bu
          else "NA"
        end
        matur = params[:maturation] ? Time.parse(params[:maturation]) : Time.now + 1.week
        expir = params[:expiration] ? Time.parse(params[:expiration]) : Time.now + 1.day
        opts  = {
          user_uuid:      current_user.uuid          ,
          price:          params[:price]             ,
          volume:         params[:volume]            ,
          stm_issue_uuid: params[:issue]             ,
          stm_status:     "closed"                   ,
          poolable:       params[:poolable] || false ,
          aon:            params[:aon] || false      ,
          maturation:     matur                      ,
          expiration:     expir
        }
        cmd = OfferCmd::CreateBuy.new(side, opts)
        if cmd.valid?
          result = cmd.project
          {status: "OK", event_uuid: result.events[:offer].event_uuid, offer_uuid: result.offer.uuid}
        else
          error!({status: "ERROR", message: "INVALID OFFER"}, 404)
        end
      end

    end
  end
end
