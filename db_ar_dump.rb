
# Loops through specified tables and converts them to ActiveRecord create queries
# Allows us to create a new seed data file from a currently existing db dump
class DbArDump
  EXCLUDE_LIST = [
    "SchemaMigration",
    "Session",
    "DelayedJob"
  ]
  class << self

    # Builds a string of attribute key/value pairs for a passed Active Record object
    def build_attr_string obj
      str = ""
      obj.attributes.each do |k, v|
        str += "#{k}: \"#{v.to_s.gsub(/"/,"")}\"," unless k == 'id' || k == 'type' || v.nil?
      end
      str.gsub! /,$/, ""
    end

    def build_non_mass_assignable obj, var
      str = ""
      str += (obj.id ? "#{var}.id = #{obj.id};" : "")
      str += (obj.respond_to?('type') ? "o.type = \"#{obj.type}\";" : "")
      str += "#{var}.save"
    end

    def tables_array
      tables = ActiveRecord::Base.connection.tables.map {|t| t.singularize.camelize }
      (tables - EXCLUDE_LIST)
    end

    def run
      seed_str = ""
      tables_array.each do |t|
        var = t.first.downcase
        seed_str += "#{t}.destroy_all\n"
        Class::const_get(t).find_each do |obj|
          seed_str += "#{var} = #{t}.new(#{build_attr_string obj}); #{build_non_mass_assignable obj, var}\n"
        end
      end

      ActiveRecord::Base.connection.tables.each do |t|
        seed_str += "ActiveRecord::Base.connection.reset_pk_sequence!('#{t}')\n"
      end
      seed_str
    end

    def build_seed_file seed_str
      file_name = "#{Time.now.strftime('%m%d%Y%H%M%S')}_seed.rb"
      File.open(file_name, 'w') do |f|
        f.write seed_str
      end
    end

  end
end

DbArDump.run
