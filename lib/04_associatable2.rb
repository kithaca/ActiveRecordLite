require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_table = "#{through_options.class_name}s"
      source_options = through_options.model_class.assoc_options[source_name]
      source_table = "#{source_options.class_name}s"
      hash = DBConnection.execute(<<-SQL, self.send(through_name).id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.foreign_key} =
          #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.id = ?
        LIMIT
          1
      SQL

      source_options.model_class.parse_all(hash).first
    end
  end
end
