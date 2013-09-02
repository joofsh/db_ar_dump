
# Loops through specified tables and converts them to ActiveRecord create queries
# Allows us to create a new seed data file from a currently existing db dump
class DbArDump
  class << self

    # Builds a string of attribute key/value pairs for a passed Active Record object
    def build_attr_string obj
      str = ""
      obj.attributes.each do |k, v|
        str += "#{k}: \"#{v.to_s.gsub(/"/,"")}\"," unless k == 'id' || k == 'type' || v.nil?
      end
      str.gsub! /,$/, ""
    end

    def build_non_mass_assignable obj
      str = ""
      str += (ENV['full_db'] == 'true' && obj.id ? "o.id = #{obj.id};" : "")
      str += (obj.respond_to?('type') ? "o.type = \"#{obj.type}\";" : "")
      str += "o.save"
    end

    def run
      tables = ActiveRecord::Base.connection.tables.map {|t| t.singularize.camelize }
      seed_str = ""
      tables.each do |t|
        seed_str += "#{t}.destroy_all\n"
        Class::const_get(t).all.each do |obj|
          unless EXCLUDE_LIST[t] && EXCLUDE_LIST[t].include?(obj.id)
            seed_str += "o = #{t}.new(#{build_attr_string obj}); #{build_non_mass_assignable obj}\n"
          end
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
