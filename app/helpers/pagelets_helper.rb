module PageletsHelper
  def virtual_path
    @virtual_path
  end

  def pagelets_for(mountpoint)
    result = ["#{controller_name}/#{action_name}", virtual_path].uniq.map do |key|
      Pagelets::Manager.pagelets_at(key, mountpoint, filter: filter_opts)
    end
    result.flatten.sort
  end

  def render_pagelets_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      result += render_pagelet(pagelet, opts)
    end
    result.html_safe
  end

  def render_tab_content_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      next unless pagelet.onlyif.call(opts[:subject], self)
      result += "<div id='#{pagelet.id}' class='tab-pane'>"
      result += render_pagelet(pagelet, opts)
      result += "</div>"
    end
    result.html_safe
  end

  def render_tab_header_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      next unless pagelet.onlyif.call(opts[:subject], self)
      result += "<li><a href='##{pagelet.id}' data-toggle='tab'>#{_(pagelet.name)}</a></li>"
    end
    result.html_safe
  end

  def render_pagelet(pagelet, opts = {})
    if pagelet.onlyif.call(opts[:subject], self)
      render(pagelet.partial, opts.merge!(
        {
          :pagelet => pagelet,
          controller_name.singularize.to_sym => opts[:subject],
          :subject => opts[:subject],
        }
      )).html_safe
    else
      "".html_safe
    end
  end

  def html_attributes(th_or_td, subject)
    #                      Allowed HTML attributes
    attrs = th_or_td.slice(:width, :class)
                    .map { |(k, v)| "#{k}=\"#{v}\"" }
    attrs_from_callbacks = (th_or_td[:attr_callbacks] || {}).map { |(k, v)| "#{k}=\"#{instance_exec(subject, &v)}\"" }
    (attrs + attrs_from_callbacks).join(' ').html_safe
  end

  def th_content(col)
    return if col[:callback]
    return col[:label] unless col[:sortable]

    sort col[:key], as: col[:label], default: col[:default_sort] || 'ASC'
  end

  def mount_column_selector
    url = "#{api_users_path}/#{User.current[:id]}/table_preferences"
    has_preference = !@selected_columns.nil?
    columns = columns_view
    react_component("ColumnSelector", data:
      {
        url: url,
        controller: controller_name,
        columns: columns,
        initialColumns: columns,
        hasPreference: has_preference,
      }
    )
  end

  private

  def defined_columns
    Pagelets::Manager.pagelets_at('hosts/_list', :hosts_table_column_header).map do |pt|
      next unless pt.opts[:key]
      {
        key: pt.opts[:key],
        label: pt.opts[:label],
        profiles: pt.profiles.map { |pr| pr.id },
        checked: @selected_columns ? @selected_columns.include?(pt.opts[:key].to_s) : pt.profiles.any? { |profile| profile.default? },
      }
    end.compact
  end

  def defined_categories(columns)
    columns.map { |col| col[:profiles] }.flatten.uniq
  end

  def all_checked?(category)
    return true if category.all? { |column| column[:checkProps][:checked] }
    category.any? { |column| column[:checkProps][:checked] } ? nil : false
  end

  def columns_view
    categories = []
    columns = defined_columns
    defined_categories(columns).each do |category|
      categories << {
        name: category.capitalize,
        key: category,
        defaultExpanded: category == 'general',
        checkProps: {},
        children: [],
      }
      category = categories.find { |c| c[:key] == category }
      columns.each do |column|
        if column[:profiles].first == category[:key]
          category[:children] << {
            name: column[:label],
            key: column[:key],
            checkProps: { checked: column[:checked] },
          }
        end
      end
      category[:checkProps][:checked] = all_checked?(category[:children])
    end
    categories
  end

  def filter_opts(opts = {})
    opts.merge(
      {
        selected: @selected_columns,
      }
    )
  end
end
