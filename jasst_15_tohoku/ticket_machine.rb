#!/bin/env ruby

# author: nikonikopinfu
# ruby 1.9.3p125 (2012-02-16) [i386-mingw32]
# で動作確認しています

#
# 券売機
#
class TicketMachine

  # 初期化
  def initialize()
    @total = {}
    @sales = 0
  end

  # 投入
  # 使えないお金の場合はnilが返る
  def put(money)
    return unless valid_money.include?(money)
    @total[money] ||= 0
    @total[money] += 1
  end

  # 総計
  def total
    @total.inject(0) { |t, m| t + (m[0] * m[1]) }
  end

  # 払戻
  def refund
    back = @total.clone
    @total.clear
    back
  end

  # 購入
  # 買えた場合は[切符の値段, お釣り]が返る
  # 買えない場合はnilが返る
  def get(price)
    return unless tickets.include?(price)

    change = total - price
    return if change < 0

    @sales += price
    @total.clear

    [price, to_change(change)]
  end

  def valid_money
    [1000, 500, 100, 50, 10]
  end

  def tickets
    [200, 250, 300]
  end

  # 売上
  attr_accessor :sales

  private
  # sumをお金毎のお釣りに変換
  def to_change(sum)
    change = {}
    valid_money.each do |m|
      change[m] = sum / m
      sum %= m
    end
    change.select { |m| change[m] != 0 }
  end

end

# ここからデモ
if __FILE__ == $0

  Signal.trap(:INT) {
    puts
    exit(1)
  }

  puts("券売機デモ")

  machine = TicketMachine.new

  loop do
    puts  "p:投入, t:総計, r:払戻, g:購入, s:売上,   e:終了"
    print "入力>"
    STDOUT.flush

    case STDIN.gets.split(" ").first
    when 'p'
      puts "お金を入れて下さい"
      print "使えるお金(#{machine.valid_money.join(', ')})>"
      STDOUT.flush

      money = STDIN.gets.split(' ').first
      puts "使えないお金です" if machine.put(money.to_i).nil?

    when 't'
      puts "総計: #{machine.total}円"

    when 'r'
      change = machine.refund
      puts "お釣: #{change.inject(0) { |t, m| t + (m[0] * m[1]) }}円"
      change_string = change.keys.sort.map { |m| "#{m}円 × #{change[m]}" }
      puts "      (#{change_string.join(', ')})" unless change_string.empty?

    when 'g'
      puts "買いたい切符の金額を入力して下さい"
      print "切符(#{machine.tickets.join(', ')})>"
      STDOUT.flush

      price = STDIN.gets.split(' ').first
      ticket, change = machine.get(price.to_i)

      if ticket.nil?
        puts "買えませんでした"
      else
        puts "切符: #{ticket}円区間"
        puts "お釣: #{change.inject(0) { |t, m| t + (m[0] * m[1]) }}円"
        change_string = change.keys.sort.map { |m| "#{m}円 × #{change[m]}" }
        puts "      (#{change_string.join(', ')})" unless change_string.empty?
      end

    when 's'
      puts "売上: #{machine.sales}円"

    when 'e'
      exit(0)

    else
      puts "無効な入力です"

    end

    puts

  end

end
