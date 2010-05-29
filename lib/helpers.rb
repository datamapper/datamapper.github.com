module GlobalHelpers
  def body_id
    if @item_rep.path == "/"
      "home"
    else
      @item_rep.path.match(%r{^/(\w+)})[1]
    end
  end

  def nav_entry(text, url, title)
    if url == "/"
      @item_rep.path == url ? current_entry(text, url, title) : standard_entry(text, url, title)
    elsif @item_rep.path.match(url)
      current_entry(text, url, title)
    else
      standard_entry(text, url, title)
    end
  end

  def current_entry(text, url, title)
    "<a href='#{url}' title='#{title}' class='current'>#{text}</a>"
  end

  def standard_entry(text, url, title)
    "<a href='#{url}' title='#{title}'>#{text}</a>"
  end
end

include GlobalHelpers
