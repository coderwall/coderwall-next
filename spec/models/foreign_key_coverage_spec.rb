require 'rails_helper'

describe 'Foreign Key coverage' do
  # https://viget.com/extend/identifying-foreign-key-dependencies-from-activerecordbase-classes
  Association = Struct.new(:association) do
    delegate :foreign_key, to: :association

    def klass
      association.klass unless polymorphic?
    end

    def name
      association.options[:class_name] || association.name
    end

    def polymorphic?
      !!association.options[:polymorphic]
    end

    def polymorphic_dependencies
      return [] unless polymorphic?
      @polymorphic_dependencies ||= ActiveRecord::Base.subclasses.select { |model| polymorphic_match? model }
    end

    def polymorphic_match?(model)
      model.reflect_on_all_associations(:has_many).any? do |has_many_association|
        has_many_association.options[:as] == association.name
      end
    end

    def dependencies(include_polymorphic=true)
      polymorphic? ? (include_polymorphic ? polymorphic_dependencies : []) : Array(klass)
    end

    def polymorphic_type
      association.foreign_type if polymorphic?
    end
  end

  it 'is complete' do
    # to ignore an entire table, add the table name symbol as the key with value :all
    # to ignore specific columns, add the table name symbol as the key with an array of column name symbols as the value
    ignore = {
      users_roles: %i( left_side_id ),
      version_associations: :all # PaperTrail's models declare some relations to missing tables, so this is necessary even though we have no version_associations table.
    }

    abc = ActiveRecord::Base.connection

    Rails.application.eager_load!

    # enumerate active record models
    ActiveRecord::Base.subclasses.each do |model|
      ignore_columns = ignore.fetch(model.table_name.to_sym, [])
      next if ignore_columns == :all

      existing_foreign_keys = abc.foreign_keys(model.table_name).each_with_object([]) do |foreign_key, keys|
        keys.push "#{ foreign_key.from_table }.#{ foreign_key.options[:column] } => #{ foreign_key.to_table }.#{ foreign_key.options[:primary_key] }"
      end

      model.reflect_on_all_associations(:belongs_to).each do |association|
        Association.new(association).dependencies(false).each do |dependency|
          next if ignore_columns.include?(association.foreign_key.to_sym)
          key = "#{ model.table_name }.#{ association.foreign_key } => #{ dependency.table_name }.#{ dependency.primary_key }"
          expect(existing_foreign_keys).to include(key), "Missing foreign key #{ key }"
        end
      end
    end
  end
end
