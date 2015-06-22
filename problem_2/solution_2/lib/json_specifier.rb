
# module to aid in abstraction of fields to produce 
# desired result from data derrived from json parse
module JsonSpecifier
  
  # top level fields need to be specified here
  def fields(fieldMap)
    @fldMap = fieldMap
    @have_specification = true
  end
  
  # subfields are of a defined type and 
  # as well as fields for that type. 
  # currently only arrays of these types are supported and assumed.
  
  def subfields(typ, fields)
    @subfieldMap ||= {}
    @subfieldMap[typ] = fields
  end
  
  # convert the data to basic types in the definition or to subfield
  # types. Fields that are not found in the defintion or that 
  # have the wrong type are ignored.
  
  def json_data_convert(map, json_data)
    result = {}
    json_data.each_pair do |ky,val|
      typ = map[ky.to_sym]
      if @subfieldMap[typ]
        data = val
        if data.class.eql?(Array)
          data_ar = []
          data.each do |dat|
            data_ar << json_data_convert(@subfieldMap[typ], dat)
          end  
          result[ky.to_s] = data_ar
        end
      elsif typ
        result[ky.to_s] = val
        if typ.eql?(:int_ar)
          if val.class.eql?(Array)
            val.delete_if{|el| el.class != Fixnum}
          else   
            result.delete(ky.to_s)
          end
        elsif typ.eql?(:boolean)
          result[ky.to_s] = '' if ![TrueClass, FalseClass].include? val.class
        elsif typ.eql?(:int)  
          result[ky.to_s] = '' if !val.class.eql?(Fixnum)
        elsif typ.eql?(:str)
          result[ky.to_s] = '' if !val.class.eql?(String)  
        end 
      end
    end
    result
  end
  
  def get_subfieldMap
    @subfieldMap
  end

  def get_fieldMap
    @fldMap
  end

  
  def convert_from_json(json_data)
    result = json_data_convert(@fldMap, json_data)
    result
  end
  
end
