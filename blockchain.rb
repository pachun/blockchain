require 'digest'
require 'random-word'

class Block
  def initialize(index:, stuff:, parent_id:)
    @index     = index
    @time      = Time.new
    @stuff     = stuff
    @parent_id = parent_id
    @id        = identity
  end

  def to_s
    "Block #{@index} (#{@id}): #{@stuff}"
  end

  def next(next_stuff)
    Block.new(
      index: @index + 1,
      stuff: next_stuff,
      parent_id: @id,
    )
  end

  def self.genesis
    Block.new(
      index: 0,
      stuff: "genesis",
      parent_id: "¯\_(ツ)_/¯",
    )
  end

  private

  def identity
    Digest::SHA1.hexdigest("#{@index}#{@time}#{@stuff}#{@parent_id}")
  end
end

blockchain = [Block.genesis]

4.times do |number|
  blockchain << blockchain.last.next("#{RandomWord.adjs.next}")
end

puts
puts blockchain
puts
