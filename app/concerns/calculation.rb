# -*- encoding : utf-8 -*-
module Calculation

 
 # Calculate the royalties earned for this book at a particular date
 # (doesn't take account of advances or previous payments)
 def calculate_book_royalties(book, cutoff_date, start_date='1900-01-01', basis, exclude)       
   initialize_roy_calc_arrays
   sales                  = Sale.find_sales_date_ordered(self, cutoff_date, start_date, exclude)
   sales_by_masterchannel = sales.group_by(&:masterchannel) # sales are kept in their correct order
   sales_by_channel       = sales.group_by(&:channel_id)
   process_sales(sales_by_masterchannel)    
   masterchannel_for_royalty_statement(sales_by_masterchannel) # Provides a way for the view to show sales by masterchannel
   channel_for_royalty_statement(sales_by_channel) # Provides a way for the view to show sales by channel
   break_sales_into_bands(sales_by_channel, basis)
   sales
 end

 def initialize_roy_calc_arrays
   @master_channel_sales_qty          = []
   @master_channel_sales_net_receipts = []
   @channel_sales_qty                 = []
   @channel_sales_net_receipts        = []
   @rates                             = []    
 end

 #Provides a way for the royalty statement view to show sales by masterchannel
 def masterchannel_for_royalty_statement(sales_by_masterchannel)
   sales_by_masterchannel.each do |ch_id, sale_array|
     masterchannel_name = Masterchannel.find_by_id(ch_id).masterchannel_name unless Masterchannel.find_by_id(ch_id).nil?
     @master_channel_sales_qty           << {masterchannel_name => sale_array.sum(&:sale_quantity )}
     @master_channel_sales_net_receipts  << {masterchannel_name => sale_array.sum(&:sale_value    )}
   end
 end

 #Provides a way for the view to show sales by channel
 def channel_for_royalty_statement(sales_by_channel)
   sales_by_channel.each do |channel, sales_array|
     channel_name = Channel.find_by_id(channel).channel_name
     @channel_sales_qty          << {channel_name => sales_array.sum(&:sale_quantity)}
     @channel_sales_net_receipts << {channel_name => sales_array.sum(&:sale_value   )}
   end
 end
   
 # Hands each sale to Masterchannel to process  
 def process_sales(sales_by_masterchannel)
   sales_by_masterchannel.each do |mc, sale_array|
     mc.process_sale(sale_array, self) unless mc.nil?
   end
 end  
 
 # Set @rates to be the rates for the book in the current contract
 # If no rates are found for a sale, the rates array is set in the initialize_roy_calc_arrays method to empty, which avoids the array being set to its previous value.
 def get_rates(rule, masterrule)
   unless rule.nil? || masterrule.nil?
     @rates = rule.rates
   end
 end

 def set_rule_variables(channel)           
   @masterchannel = Channeltype.find_by_channel_id_and_client_id(channel, self.client_id).try(:masterchannel_id)
   @masterrule    = Masterrule.find_by_book_id_and_masterchannel_id(self.id, @masterchannel)
   @rule          = Rule.find_by_channel_id_and_masterrule_id(channel, @masterrule)
   @reserve       = @rule.reserve_rate unless @rule.nil? || @masterrule.nil?
 end

 # for each sale, update the value by band.
 def update_sales_bands(sales_array, basis)
   sales_array.each do |sale|
     # Make sure each sale object knows the sales value which falls into each royalty band:
     sale.update_value_by_band
     royalty_and_reserve_by_band(@rates, @reserve, basis, sale)
   end
 end

 def royalty_and_reserve_by_band(rates, reserve, basis, sale)
   unless rates.nil?
     rates.each_with_index do |rate, index|
       if basis == "Net receipts"
         sale.royalty_by_band[index] += (rate.to_f/100) * sale.value_by_band[index]
         sale.reserve_by_band[index] += (rate.to_f/100) * sale.value_by_band[index] * reserve/100 unless reserve.nil?
       else
         sale.royalty_by_band[index] += (rate.to_f/100) * sale.quantities_by_band[index] * self.default_price_amount.to_f
         # puts "sale.royalty_by_band[index] is #{sale.royalty_by_band[index]} where rate is #{(rate.to_f/100)} and qty is #{sale.quantities_by_band[index]} and price is #{self.default_price_amount.to_f}  "
         sale.reserve_by_band[index] += ((rate.to_f/100) * sale.quantities_by_band[index] * self.default_price_amount.to_f) * reserve/100 unless reserve.nil?
       end
     end
   end
 end

 def break_sales_into_bands(sales_by_channel, basis)
   sales_by_channel.each do |channel, sales_array| 
     set_rule_variables(channel)           
     get_rates(@rule, @masterrule)
     update_sales_bands(sales_array, basis)
   end
 end

 # A method which calls the royalty calculation. Defaults to run from the beginning of time through to the end of the current period.
 # If it's passed startdate as an argument, though, it'll run to the beginning of the period.
 def book_sales(period='enddate', basis, exclude)
   royalty_period = Period.where(["currentperiod = ? and client_id = ?", true, self.client_id])
   if period == 'startdate'
     self.calculate_book_royalties(self, royalty_period.first.enddate, royalty_period.first.startdate, basis, exclude)
   else #if period isn't 'startdate'
     self.calculate_book_royalties(self, royalty_period.first.enddate, "1900-01-01", basis, exclude)
   end
 end

 # Method to produce the summed royalty for this Book. Defaults to running the method for the cumulative period, and on net receipts (1)
 def book_royalty(period='enddate', basis="Net receipts")
   royarray = []
   sales    = self.book_sales(period, basis, false) # this calls the royalty calculation for net receipts
   sales.each do |sale|
     royarray << sale.royalty_by_band.inject(0) { |sum, i| sum + i.to_f unless i.nan? || i.nil? }
   end
   book_royalty = royarray.inject(0) { |sum, i| sum +i.to_f }
 end

 def book_reserve(period='enddate', basis="Net receipts")
   resarray =[]
   sales    = self.book_sales(period, basis, false) # this calls the royalty calculation for net receipts
   sales.each do |sale|
       resarray << sale.reserve_by_band.inject(0) { |sum, i| sum + i unless i.nan? or i.nil? }
       
   end
   book_reserve = resarray.inject(0) { |sum, i| sum +i.to_f }
 end

 # Method to produce the summed quantity for this Book
 def book_quantity(period='enddate', basis, exclude)
   volarray = []
   sales    = self.book_sales(period, basis, exclude)
   sales.each do |sale|
     volarray << sale.quantities_by_band.inject(0) { |sum, i| sum + i }
   end
   book_quantity = volarray.inject(0) { |sum, i| sum +i.to_f }
 end

 # Method to produce the summed value for this Book
 def book_value(period='enddate', basis, exclude)
   salearray = []
   sales     = self.book_sales(period, basis, exclude)
   sales.each do |sale|
     salearray << sale.value_by_band.inject(0) { |sum, i| sum + i.to_f unless i.nan? or i.nil? }
   end
   book_value =salearray.inject(0) { |sum, i| sum +i.to_f }
 end

 # used in the profit csv export
 def average_value_per_unit(book)
   if  book.book_value(period='enddate', 1, 'true') == 0 || book.book_quantity(period='enddate', 1, 'true') ==0
     return "-"
   else
     book.book_value(period='enddate', 1, 'true') / book.book_quantity(period='enddate', 1, 'true')
   end
 end


end
