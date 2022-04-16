require 'date'

class PeopleController
  def initialize(params)
    @params = params
  end

  def normalize
    crowd_list(transform_crowd)
  end

  private

  attr_reader :params

  def transform_crowd
    crowd = []

    crowd_with_dollar = @params[:dollar_format].split("\n").drop(1)
    crowd_with_percent = @params[:percent_format].split("\n").drop(1)

    header_dfields = data_header(@params[:dollar_format].split("\n")[0], " $ ")
    header_pfields = data_header(@params[:percent_format].split("\n")[0], " % ")

    get_indexes(header_dfields, header_pfields)

    dollar_info = crowd_info(crowd_with_dollar, @dollar_name_index, @dollar_city_index, @dollar_date_index, " $ ")
    crowd.push(dollar_info)
    
    percent_info = crowd_info(crowd_with_percent, @percent_name_index, @percent_city_index, @percent_date_index, " % ")
    crowd.push(percent_info)
    
    return sort_by_name(crowd.flatten)
  end

  def crowd_info(data_bunch, name_index, city_index, date_index, format)
    data_bunch.map do |record|
      record = record.split(format)
      {
        first_name: record[name_index],
        city: city_name(record[city_index]),
        birthdate: Date.parse(record[date_index]).strftime("%-m/%-d/%Y")
      }
    end
  end

  def field_index(keys, attr_name)
    keys.index(attr_name)
  end

  def data_header(record, format_type)
    record.split(format_type)
  end

  def city_name(city)
    case city
    when "LA"
      return "Los Angeles"
    when "NYC"
      return "New York City"
    else
      return city
    end
	end

  def get_indexes(dollar_header, percent_header)
    @dollar_city_index = field_index(dollar_header, "city")
    @dollar_name_index = field_index(dollar_header, "first_name")
    @dollar_date_index = field_index(dollar_header, "birthdate")
    @percent_city_index = field_index(percent_header, "city")
    @percent_name_index = field_index(percent_header, "first_name")
    @percent_date_index = field_index(percent_header, "birthdate")
  end

  def sort_by_name(crowd_result)
    crowd_result.sort_by do |data|
      data[:first_name] 
    end
  end 
  
  def crowd_list(crowd)
    person_list = crowd.map do |someone|
      "#{someone[:first_name]}, #{someone[:city]}, #{someone[:birthdate]}"
    end
  end
end
