package example;
  import uvm_pkg::*;
  import uvm_colors::*;
  `include "uvm_macros.svh"

  class internal_comp extends uvm_component;
    `uvm_component_utils(internal_comp)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction    

    task run_phase(uvm_phase phase);
      uvm_report_info("bla", get_full_name());
    endtask
  endclass

  class internal_env extends colored_env;
    `uvm_component_utils(internal_env)

     internal_comp cmp1;

    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction  

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      cmp1 = internal_comp::type_id::create("cmp1", this);      
    endfunction    

    task run_phase(uvm_phase phase);
      uvm_report_info("bla", get_full_name());
    endtask
  endclass

  class external_env extends colored_env;
    `uvm_component_utils(external_env)

    internal_env env1, env2;
    internal_comp cmp1;

    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction    

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  
      env1 = internal_env::type_id::create("env1", this);      
      env2 = internal_env::type_id::create("env2", this);      
      cmp1 = internal_comp::type_id::create("cmp1", this);      
    endfunction  
    
    task run_phase(uvm_phase phase);
      uvm_report_info("bla", get_full_name());
    endtask
  endclass

  class test extends uvm_test;
    `uvm_component_utils(test)

    external_env top;

    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction    

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      top = external_env::type_id::create("top", this);

      uvm_config_db#(color_t)::set(this, "top.env1", "font_color", BLACK);
      uvm_config_db#(color_t)::set(this, "top.env1", "bg_color", CYAN);
      uvm_config_db#(color_t)::set(this, "top.env2", "font_color", CYAN);
      uvm_config_db#(color_t)::set(this, "top", "font_color", MAGENTA);  
    endfunction
  endclass
   
endpackage

module top();
  import uvm_pkg::*;
  import example::*;

  initial
    run_test("test");
endmodule
