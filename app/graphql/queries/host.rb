module Queries
  Host = GraphQL::ObjectType.define do

    field :host, Types::Exchange::HostType do
      description 'Host Info'
      resolve ->(_obj, _args, _ctx) do
        Types::Exchange::HostKlas.new
      end
    end

  end
end
