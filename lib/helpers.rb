module GlobalHelpers
  def body_id
    if @page.url == "/"
      "home"
    else
      @page.url.match(%r{^/(\w+)})[1]
    end
  end
  
  def nav_entry(text, url, title)
    if url == "/"
      @page.url == url ? current_entry(text, url, title) : standard_entry(text, url, title)
    elsif @page.url.match(url)
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

Webby::Helpers.register(GlobalHelpers)
