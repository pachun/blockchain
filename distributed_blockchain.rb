# case study: cryptocurrency
#
# each block's "stuff" will be an array of transcations
#
# every "node"/"miner" is running it's own server:

require 'sinatra'
require 'json'
require 'pp'
require './blockchain.rb'

blockchain = [Block.genesis]
blockchain.first.proof_of_work = 1

# exchange currency: create transaction
this_nodes_transactions = []
post "/transaction" do
  transaction_json = JSON.parse(request.body.read)
  this_nodes_transactions << {
    from: transaction_json["from"],
    to: transaction_json["to"],
    amount: transaction_json["amount"].to_f,
  }
  this_nodes_transactions.to_s + "\n"
end

# curl -H "Content-Type: application/json" -X POST -d '{"from":"sam","to":"nick","amount":"50"}' http://localhost:4567/transaction

def proof_of_work(blockchain)
  proof_of_work = blockchain.last.proof_of_work + 1

  loop do
    break if (proof_of_work % 9 == 0) && (proof_of_work % blockchain.last.proof_of_work == 0)
    proof_of_work += 1
  end

  proof_of_work
end

# issue currency: create currency (/mine)
get "/mine" do

  # blocks execution
  nonce = proof_of_work(blockchain)

  this_nodes_transactions << {
    from: "network",
    to: "nick",
    amount: 1.0,
  }

  next_block = blockchain.last.next(stuff: this_nodes_transactions)
  next_block.proof_of_work = nonce
  blockchain << next_block

  this_nodes_transactions = []

  pp blockchain
  blockchain.to_json
end

# curl http://localhost:4567/mine
# lsof -ti:4567 | kill

# keeping nodes in sync... understanding fades < -- you are here

peer_nodes = []
get "/blocks" do
  other_nodes_chains = find_new_chains

  consensus = find_consensus(other_nodes_chains)
  blockchain = consensus

  consensus.to_json
end

def find_new_chains
  peer_nodes.map { |peer_address| Net::HTTP.get(peer_address, "/blocks") }
end

def find_consensus(blockchains)
  longest = blockchain
  blockchains.each do |other_nodes_blockchain|
    if other_nodes_blockchain.length > blockchain.length
      longest = other_nodes_blockchain
    end
  end

  longest
end
