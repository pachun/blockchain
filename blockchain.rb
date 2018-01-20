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

genesis = Block.new(
  position: 0,
  stuff: "genesis",
  parent_id: "¯\_(ツ)_/¯"
)

blockchain = [genesis]

5.times do |position|
  blockchain << next_block(
    parent: blockchain.last,
    stuff: RandomWord.adjs.next,
  )
end

puts "BLOCKCHAIN"
puts "=========="
blockchain.each do |block|
  puts "#{block.stuff} (block id: #{block.id})"
end
puts "\n"
