
require 'json_specifier'


class MainController < ApplicationController
  extend JsonSpecifier
  
  def self.set_specification
    self.fields({:id => :int, :name => :str, :active => :boolean, 
           :count => :int, :address_ids => :int_ar,
           :accounts => :rec_ar})
    self.subfields(:rec_ar, {:id => :int, :name => :str})        
  end
  
  def self.set_specifier
    set_specification unless @have_specification
  end
  
  def index
  end
  
  def save
    self.class.set_specifier
    subfieldMap = self.class.get_subfieldMap
    fieldMap = self.class.get_fieldMap
    json = ActiveSupport::JSON.decode(params[:json_content])
    @result = self.class.convert_from_json(json)
    
    basicKeys = @result.keys.find_all do |k| 
      !subfieldMap[fieldMap[k.to_sym]] 
    end
    subfieldKeys = @result.keys.find_all do |k| 
      subfieldMap[fieldMap[k.to_sym]] 
    end  
    @basicResult = {}
    @subfieldResult = {}
    basicKeys.each{|ky| @basicResult[ky] = @result[ky]}
    subfieldKeys.each{|ky| @subfieldResult[ky] = @result[ky]}
  end
    
end
