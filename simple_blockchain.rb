require './blockchain.rb'

blockchain = [Block.genesis]
10.times { blockchain << blockchain.last.next(stuff: "#{RandomWord.adjs.next}") }

puts
puts blockchain
puts
