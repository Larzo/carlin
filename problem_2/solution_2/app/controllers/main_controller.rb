
require 'json_specifier'


class MainController < ApplicationController
  extend JsonSpecifier
  
  
  # define the specification for the expected fields and field types
  
  def self.set_specification
    # set up the main top level fields,
    # rec_ar is a special case, defined as a subfield
    self.fields({:id => :int, :name => :str, :active => :boolean, 
           :count => :int, :address_ids => :int_ar,
           :accounts => :acct_ar})
    # defined the subfields for the account as of type acct_ar      
    self.subfields(:acct_ar, {:id => :int, :name => :str})        
  end
  
  def self.set_specifier
    set_specification unless @have_specification
  end
  
  def index
  end
  
  def save
    self.class.set_specifier
    
    # we need the field maps because the subfields
    # will be rendered seperately in different table(s)
    subfieldMap = self.class.get_subfieldMap
    fieldMap = self.class.get_fieldMap
    
    json = ActiveSupport::JSON.decode(params[:json_content])
    convertedResult = self.class.convert_from_json(json)
    
    # build the hash tables used for rendering
    basicKeys = convertedResult.keys.find_all do |k| 
      !subfieldMap[fieldMap[k.to_sym]] 
    end
    subfieldKeys = convertedResult.keys.find_all do |k| 
      subfieldMap[fieldMap[k.to_sym]] 
    end  
    @basicResult = {}
    @subfieldResult = {}
    basicKeys.each{|ky| @basicResult[ky] = convertedResult[ky]}
    subfieldKeys.each{|ky| @subfieldResult[ky] = convertedResult[ky]}
  end
    
end
