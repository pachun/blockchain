require 'sinatra'
require 'digest'
require 'random-word'

class Block
  attr_reader :id, :position, :stuff

  def initialize(position:, stuff:, parent_id:)
    @position  = position
    @time      = Time.new
    @stuff     = stuff
    @parent_id = parent_id
    @id        = identity
  end

  def to_s
    "Block #{position}: #{stuff} (#{id})"
  end

  private

  def identity
    Digest::SHA1.hexdigest("#{@position}#{@time}#{@stuff}#{@parent_id}")
  end
end

def next_block(parent:, stuff:)
  Block.new(
    position: parent.position + 1,
    stuff: stuff,
    parent_id: parent.id,
  )
end

def new_transaction(from, to, amount)
  {
    from: from,# RandomWord.adjs.next,
    to: to,# RandomWord.nouns.next,
    amount: amount, # rand(1..10),
  }
end

genesis = Block.new(
  position: 0,
  stuff: "genesis",
  parent_id: "¯\_(ツ)_/¯"
)

blockchain = [genesis]

observed_transactions = []

# create transaction
post "/transaction" do
  transaction_json = JSON.parse(request.body.read)
  observed_transactions << new_transaction(
    transaction_json["from"],
    transaction_json["to"],
    transaction_json["amount"],
  )
  observed_transactions.to_s
end


