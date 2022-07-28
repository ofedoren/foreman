module SelectableColumnsHelper
  def render_selected_column_ths
    result = ""
    @selected_columns.each do |column|
      result += render(
        'common/selectable_column_th',
        attributes: attributes(column[:th]),
        th_content: th_content(column),
        callback: column[:th][:callback]
      )
    end
    result.html_safe
  end

  def render_selected_column_tds(record)
    result = ""
    @selected_columns.each do |column|
      result += render(
        'common/selectable_column_td',
        attributes: attributes(column[:td]),
        attr_callbacks: column[:td][:attr_callbacks],
        subject: record,
        callback: column[:td][:callback]
      )
    end
    result.html_safe
  end

  def attr_from_callbacks(callbacks, subject)
    return unless callbacks

    callbacks.map { |(k, v)| "#{k}=\"#{instance_exec(subject, &v)}\"" }
             .join(' ')
             .html_safe
  end

  private

  def attributes(th_or_td)
    th_or_td.except(:callback, :sortable, :default_sort, :attr_callbacks, :label)
            .map { |(k, v)| "#{k}=\"#{v}\"" }
            .join(' ')
            .html_safe
  end

  def th_content(col)
    return if col[:th][:callback]
    return col[:th][:label] unless col[:th][:sortable]

    sort col[:key], as: col[:th][:label], default: col[:th][:default_sort] || 'ASC'
  end
end
