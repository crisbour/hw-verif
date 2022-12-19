package uvm_colors;
  import uvm_pkg::*;

  typedef enum {BLACK, BROWN, GREEN, YELLOW, BLUE, MAGENTA, CYAN, GRAY, RED, WHITE} color_t;

  string font_format[color_t] = '{BLACK:"\033[30m%s\033[0m", BROWN:"\033[31m%s\033[0m", GREEN:"\033[32m%s\033[0m", YELLOW:"\033[33m%s\033[0m", BLUE:"\033[34m%s\033[0m", MAGENTA:"\033[35m%s\033[0m", CYAN:"\033[36m%s\033[0m", GRAY:"\033[37m%s\033[0m", RED:"\033[38m%s\033[0m"};

  string bg_format[color_t] = '{BLACK:"\033[40m%s\033[0m", BROWN:"\033[41m%s\033[0m", GREEN:"\033[42m%s\033[0m", YELLOW:"\033[43m%s\033[0m", BLUE:"\033[44m%s\033[0m", MAGENTA:"\033[45m%s\033[0m", CYAN:"\033[46m%s\033[0m", GRAY:"\033[47m%s\033[0m", RED:"\033[48m%s\033[0m", WHITE:"\033[49m%s\033[0m"};


  class msg_formatter extends uvm_report_catcher;
    local string format_string;

    function new(string name="msg_formatter", color_t font_color, color_t bg_color);
      super.new(name);
      $sformat(format_string, bg_format[bg_color], font_format[font_color]);
    endfunction

    //This example demotes "MY_ID" errors to an info message
    function action_e catch();
      string msg = get_message();
      $sformat(msg, format_string, msg);
      set_message(msg);
      return THROW;
    endfunction
  endclass

  class colored_env extends uvm_env;
    
    color_t font_color = BLACK;
    color_t bg_color = WHITE;

    local msg_formatter formatter;
    
    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);

      void'(uvm_config_db#(color_t)::get(this, "", "font_color", font_color));
      void'(uvm_config_db#(color_t)::get(this, "", "bg_color", bg_color));

      formatter = new("formatter", font_color, bg_color);
      uvm_report_cb::add_by_name("*", formatter, this);
    endfunction
  endclass;
endpackage

