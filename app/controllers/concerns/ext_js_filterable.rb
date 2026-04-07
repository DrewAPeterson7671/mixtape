# frozen_string_literal: true

module ExtJsFilterable
  extend ActiveSupport::Concern

  private

  # Main entry point — applies column filters and text search to an AR scope.
  # Controllers define FILTER_CONFIG (Hash) and SEARCH_FIELDS (Hash) as constants.
  def apply_ext_filters(scope)
    scope = apply_column_filters(scope) if params[:filter].present?
    scope = apply_text_search(scope)    if params[:search].present?
    scope
  end

  # ── Column filters (from Ext JS gridfilters plugin) ────────────────────

  def apply_column_filters(scope)
    filters = parse_filters
    return scope if filters.empty?

    config = self.class::FILTER_CONFIG

    filters.each do |f|
      col_config = config[f["property"]&.to_sym]
      next unless col_config

      scope = apply_single_filter(scope, col_config, f)
    end

    scope
  end

  def parse_filters
    raw = params[:filter]
    return raw if raw.is_a?(Array)

    JSON.parse(raw)
  rescue JSON::ParserError, TypeError
    []
  end

  def apply_single_filter(scope, config, filter)
    case config[:kind]
    when :string      then apply_string_filter(scope, config, filter)
    when :number      then apply_number_filter(scope, config, filter)
    when :boolean     then apply_boolean_filter(scope, config, filter)
    when :list        then apply_list_filter(scope, config, filter)
    when :habtm_string then apply_habtm_string_filter(scope, config, filter)
    when :habtm_list  then apply_habtm_list_filter(scope, config, filter)
    else scope
    end
  end

  # ── Individual filter kinds ────────────────────────────────────────────

  def apply_string_filter(scope, config, filter)
    value = filter["value"].to_s
    return scope if value.blank?

    scope.where("#{config[:column]} ILIKE ?", "%#{sanitize_like(value)}%")
  end

  def apply_number_filter(scope, config, filter)
    operator = filter["operator"] || filter["comparison"] || "eq"
    value    = filter["value"]
    return scope if value.nil?

    column = config[:column]
    case operator.to_s
    when "gt" then scope.where("#{column} > ?", value)
    when "lt" then scope.where("#{column} < ?", value)
    when "eq" then scope.where("#{column} = ?", value)
    else scope
    end
  end

  def apply_boolean_filter(scope, config, filter)
    scope.where(config[:column] => ActiveModel::Type::Boolean.new.cast(filter["value"]))
  end

  # List filter: client sends display names → we look up IDs via the model.
  # Scopes through current_user for UserOwnable lookup models.
  def apply_list_filter(scope, config, filter)
    values = Array(filter["value"])
    return scope if values.empty?

    model = config[:model]
    lookup = if model.reflect_on_association(:user) && respond_to?(:current_user, true)
               model.where(user_id: current_user.id)
             else
               model
             end

    ids = lookup.where(name: values).pluck(:id)
    return scope.none if ids.empty?

    scope.where("#{config[:column]} IN (?)", ids)
  end

  # HABTM string filter using EXISTS subquery (no duplicate rows).
  # Config keys: join_table, join_fk, base_key, assoc_table, assoc_fk, assoc_column
  def apply_habtm_string_filter(scope, config, filter)
    value = filter["value"].to_s
    return scope if value.blank?

    sql = <<~SQL.squish
      EXISTS (
        SELECT 1 FROM #{config[:join_table]}
        JOIN #{config[:assoc_table]}
          ON #{config[:assoc_table]}.id = #{config[:join_table]}.#{config[:assoc_fk]}
        WHERE #{config[:join_table]}.#{config[:join_fk]} = #{config[:base_key]}
          AND #{config[:assoc_table]}.#{config[:assoc_column]} ILIKE ?
      )
    SQL

    scope.where(sql, "%#{sanitize_like(value)}%")
  end

  # HABTM list filter using EXISTS subquery — optionally scoped to current user.
  # Config keys: join_table, join_fk, base_key, assoc_table, assoc_fk, assoc_column,
  #              user_scope (optional SQL fragment)
  def apply_habtm_list_filter(scope, config, filter)
    values = Array(filter["value"])
    return scope if values.empty?

    user_condition = config[:user_scope] ? " AND #{config[:user_scope]}" : ""

    sql = <<~SQL.squish
      EXISTS (
        SELECT 1 FROM #{config[:join_table]}
        JOIN #{config[:assoc_table]}
          ON #{config[:assoc_table]}.id = #{config[:join_table]}.#{config[:assoc_fk]}
        WHERE #{config[:join_table]}.#{config[:join_fk]} = #{config[:base_key]}#{user_condition}
          AND #{config[:assoc_table]}.#{config[:assoc_column]} IN (?)
      )
    SQL

    scope.where(sql, values)
  end

  # ── Text search (toolbar search field) ─────────────────────────────────

  def apply_text_search(scope)
    search = params[:search].to_s.strip
    return scope if search.blank?

    search_config = self.class::SEARCH_FIELDS
    return scope if search_config.blank?

    term = "%#{sanitize_like(search)}%"

    # Apply LEFT JOINs for associated-table search fields
    search_config[:joins]&.each do |join_sql|
      scope = scope.joins(join_sql)
    end

    # Build OR conditions across all searchable fields
    conditions = search_config[:fields].map { |field| "#{field} ILIKE :q" }
    scope.where(conditions.join(" OR "), q: term)
  end

  # ── Helpers ────────────────────────────────────────────────────────────

  def sanitize_like(value)
    value.to_s.gsub(/[%_\\]/) { |m| "\\#{m}" }
  end
end
