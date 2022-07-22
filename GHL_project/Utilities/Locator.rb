module Utilities
  class Locator
    attr_accessor :how
    attr_accessor :what
    attr_accessor :element
    attr_accessor :scroll

    def initialize(how, what, scroll = true, element=nil)
      @how = how
      @what = what
      @element = element
      @scroll = scroll
    end

    def get_how
      @how
    end

    def get_what
      @what
    end

    def element
      @exception_count = 0
      begin
        if @element.nil?
          element = $driver.find_element(@how, @what)
          # @element = element
        else
          element = @element
        end
        scroll_script = "var viewPortHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);" +
        "var elementTop = arguments[0].getBoundingClientRect().top;" +
        "window.scrollBy(0, elementTop-(viewPortHeight/2));"
        view_port_script = "var elem = arguments[0], " +
          "box = elem.getBoundingClientRect()," +
          "cx = box.left + box.width / 2," +
          "cy = box.top + box.height / 2," +
          "e = document.elementFromPoint(cx, cy); " +
          "for (; e; e = e.parentElement) { " +
          "if (e === elem) " +
          "    return true;" +
          "}  " +
          "return false;"
        available_in_view_port = $driver.execute_script(view_port_script, element)
        $driver.execute_script(scroll_script, element) unless available_in_view_port
        element
      rescue => e
        @exception_count += 1
        sleep 1
        retry if @exception_count < 2
      end
    end

  end
end