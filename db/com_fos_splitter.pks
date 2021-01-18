create or replace package com_fos_splitter
as

    function render
      ( p_region              in apex_plugin.t_region
      , p_plugin              in apex_plugin.t_plugin
      , p_is_printer_friendly in boolean
      )
    return apex_plugin.t_region_render_result;

    function ajax
      ( p_region in apex_plugin.t_region
      , p_plugin in apex_plugin.t_plugin
      )
    return apex_plugin.t_region_ajax_result;

end;
/


