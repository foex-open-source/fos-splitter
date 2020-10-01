

create or replace package body com_fos_splitter
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
-- =============================================================================

g_in_error_handling_callback boolean := false;

--------------------------------------------------------------------------------
-- private function to include the apex error handling function, if one is
-- defined on application or page level
--------------------------------------------------------------------------------
function error_function_callback
  ( p_error in apex_error.t_error
  )  return apex_error.t_error_result
is
  c_cr constant varchar2(1) := chr(10);

  l_error_handling_function apex_application_pages.error_handling_function%type;
  l_statement               varchar2(32767);
  l_result                  apex_error.t_error_result;

  procedure log_value (
      p_attribute_name in varchar2,
      p_old_value      in varchar2,
      p_new_value      in varchar2 )
  is
  begin
      if   p_old_value <> p_new_value
        or (p_old_value is not null and p_new_value is null)
        or (p_old_value is null     and p_new_value is not null)
      then
          apex_debug.info('%s: %s', p_attribute_name, p_new_value);
      end if;
  end log_value;
begin
  if not g_in_error_handling_callback
  then
    g_in_error_handling_callback := true;

    begin
      select /*+ result_cache */
             coalesce(p.error_handling_function, f.error_handling_function)
        into l_error_handling_function
        from apex_applications f,
             apex_application_pages p
       where f.application_id     = apex_application.g_flow_id
         and p.application_id (+) = f.application_id
         and p.page_id        (+) = apex_application.g_flow_step_id;
    exception when no_data_found then
        null;
    end;
  end if;

  if l_error_handling_function is not null
  then

    l_statement := 'declare'||c_cr||
                       'l_error apex_error.t_error;'||c_cr||
                   'begin'||c_cr||
                       'l_error := apex_error.g_error;'||c_cr||
                       'apex_error.g_error_result := '||l_error_handling_function||' ('||c_cr||
                           'p_error => l_error );'||c_cr||
                   'end;';

    apex_error.g_error := p_error;

    begin
        apex_exec.execute_plsql (
            p_plsql_code      => l_statement );
    exception when others then
        apex_debug.error('error in error handler: %s', sqlerrm);
        apex_debug.error('backtrace: %s', dbms_utility.format_error_backtrace);
    end;

    l_result := apex_error.g_error_result;

    if l_result.message is null
    then
        l_result.message          := nvl(l_result.message,          p_error.message);
        l_result.additional_info  := nvl(l_result.additional_info,  p_error.additional_info);
        l_result.display_location := nvl(l_result.display_location, p_error.display_location);
        l_result.page_item_name   := nvl(l_result.page_item_name,   p_error.page_item_name);
        l_result.column_alias     := nvl(l_result.column_alias,     p_error.column_alias);
    end if;
  else
    l_result.message          := p_error.message;
    l_result.additional_info  := p_error.additional_info;
    l_result.display_location := p_error.display_location;
    l_result.page_item_name   := p_error.page_item_name;
    l_result.column_alias     := p_error.column_alias;
  end if;

  if l_result.message = l_result.additional_info
  then
    l_result.additional_info := null;
  end if;

  g_in_error_handling_callback := false;

  return l_result;

exception
  when others then
    l_result.message             := 'custom apex error handling function failed !!';
    l_result.additional_info     := null;
    l_result.display_location    := apex_error.c_on_error_page;
    l_result.page_item_name      := null;
    l_result.column_alias        := null;
    g_in_error_handling_callback := false;
    return l_result;

end error_function_callback;
--
-- helper function for getting the preference key based on the region id
function get_preference_key
    ( p_region_id varchar2
    )
return varchar2
as
begin
    return 'F' || V('APP_ID') || '_' || p_region_id || '_SPLITTER_STATE';
end;

-- helper function for getting the preference value based on the region id
function get_preference
    ( p_region_id varchar2
    )
return varchar2
as
begin
    return apex_util.get_preference(get_preference_key(p_region_id));
end;

-- helper function for storing the preference
procedure set_preference
    ( p_region_id varchar2
    , p_position  varchar2
    , p_collapsed varchar2
    )
as
    l_preference varchar2(100);

    function is_numeric
        ( p_str varchar2
        )
    return boolean
    as
        l_number number := p_str;
    begin
        return true;
    exception
        when others then
            return false;
    end;
begin
    if is_numeric(p_position) and p_collapsed in ('true', 'false')
    then
        l_preference := p_position || ':' || p_collapsed;
        apex_util.set_preference(get_preference_key(p_region_id), l_preference);
        apex_debug.info
            ( p_message => 'Splitter preference for region %s set to %s:%s'
            , p0        => p_region_id
            , p1        => p_position
            , p2        => p_collapsed
            );
    else
        apex_debug.warn
            ( p_message => 'Splitter preference for region %s is expected as nnn:[true|false] but received %s:%s'
            , p0        => p_region_id
            , p1        => p_position
            , p2        => p_collapsed
            );
    end if;
end;

-- helper function for getting the title, collapse and restore messages
function get_message
    ( p_type      varchar2 -- in [collapse | restore]
    , p_attribute varchar2
    )
return varchar2
as
    l_collapse_text_msg varchar2(100) := 'APEX.SPLITTER.COLLAPSE_TEXT';
    l_restore_text_msg  varchar2(100) := 'APEX.SPLITTER.RESTORE_TEXT';

    l_message varchar2(1000);
begin
    if p_type = 'collapse' then
        l_message := nvl(p_attribute, apex_lang.message(l_collapse_text_msg));
        if l_message = l_collapse_text_msg then
            l_message := 'Collapse';
        end if;
    elsif p_type = 'restore' then
        l_message := nvl(p_attribute, apex_lang.message(l_restore_text_msg));
        if l_message = l_restore_text_msg then
            l_message := 'Restore';
        end if;
    end if;

    return l_message;
end;

-- main plug-in entry point
function render
    ( p_region              apex_plugin.t_region
    , p_plugin              apex_plugin.t_plugin
    , p_is_printer_friendly boolean
    )
return apex_plugin.t_region_render_result
as
    l_result            apex_plugin.t_region_render_result;

    -- attributes
    l_orientation       p_region.attribute_01%type := p_region.attribute_01;
    l_direction         p_region.attribute_02%type := p_region.attribute_02;

    -- position specific attributes
    l_pos           p_region.attribute_03%type := p_region.attribute_03;
    l_pos_fn        p_region.attribute_04%type := 'function(){ return ' || p_region.attribute_04 || '; }';

    -- preference specific attributes
    l_pos_pref      apex_t_varchar2  := apex_string.split(get_preference(p_region.id), ':');
    l_has_pref      boolean          := l_pos_pref.count = 2;
    l_pos_pref_pos  number  := case when l_has_pref then l_pos_pref(1)          else null end;
    l_pos_pref_col  boolean := case when l_has_pref then l_pos_pref(2) = 'true' else null end;

    l_min_size      number  := p_region.attribute_05;
    l_height_fn     p_region.attribute_06%type := 'function(){ return ' || p_region.attribute_06 || '; }';

    -- options
    l_options            apex_t_varchar2 := apex_string.split(p_region.attribute_10, ':');

    l_persist_state_pref  boolean := 'persist-state'         member of l_options;
    l_persist_state_local boolean := 'persist-state-local'   member of l_options;
    l_continuous_resize   boolean := 'continuous-resize'     member of l_options;
    l_can_collapse        boolean := 'can-collapse'          member of l_options;
    l_drag_collapse       boolean := 'drag-collapse'         member of l_options;
    l_contains_iframe     boolean := 'contains-iframe'       member of l_options;
    l_lazy_render         boolean := 'lazy-render'           member of l_options;
    l_resize_jet_charts   boolean := 'responsive-jet-charts' member of l_options;

    -- advanced options
    l_advanced_options  boolean := nvl(p_region.attribute_15, 'N') = 'Y';

    l_custom_selector   p_region.attribute_16%type := p_region.attribute_16;
    l_step_size         number := p_region.attribute_17;
    l_key_step_size     number := p_region.attribute_18;

    -- title messages
    l_title             p_region.attribute_19%type := p_region.attribute_19;
    l_title_collapse    p_region.attribute_20%type := get_message('collapse',p_region.attribute_20);
    l_title_restore     p_region.attribute_21%type := get_message('restore', p_region.attribute_21);

    l_change_function   p_region.attribute_22%type := nvl(p_region.attribute_22, 'function(){}');

    l_padding_first     number := nvl(p_region.attribute_23, 16);
    l_padding_second    number := nvl(p_region.attribute_24, 16);

    l_region_id         p_region.static_id%type := p_region.static_id;

    -- Javascript Initialization Code
    l_init_js_fn           varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_region.init_javascript_code), 'undefined');
begin

    --debug
    if apex_application.g_debug
    then
        apex_plugin_util.debug_region
            ( p_plugin => p_plugin
            , p_region => p_region
            );
    end if;

    apex_json.initialize_clob_output;

    apex_json.open_object;

    apex_json.write('regionId', l_region_id);
    apex_json.write('orientation', l_orientation);
    apex_json.write('direction', l_direction);

    -- either position+collapsed, positionCode or positionFunction must be provided
    if l_persist_state_pref and l_has_pref then
        apex_json.write('position', l_pos_pref_pos);
        apex_json.write('collapsed', l_pos_pref_col);
    else
        if l_pos != 'custom' then
            apex_json.write('positionCode', l_pos);
        else
            apex_json.write_raw('positionFunction', l_pos_fn);
        end if;
    end if;

    apex_json.write('minSize', l_min_size);
    apex_json.write_raw('heightFunction', l_height_fn);
    apex_json.write('persistStatePref', l_persist_state_pref);
    apex_json.write('persistStateLocal', l_persist_state_local);

    -- the AJAX identifier is only passed along if we persist the position on the server
    if l_persist_state_pref then
        apex_json.write('ajaxIdentifier', apex_plugin.get_ajax_identifier);
    end if;

    apex_json.write('continuousResize'  , l_continuous_resize);
    apex_json.write('canCollapse'       , l_can_collapse);
    apex_json.write('dragCollapse'      , l_drag_collapse);
    apex_json.write('containsIframe'    , l_contains_iframe);
    apex_json.write('lazyRender'        , l_lazy_render);
    apex_json.write('resizeJetCharts'   , l_resize_jet_charts);

    apex_json.write('customSelector'    , l_custom_selector);
    apex_json.write('stepSize'          , l_step_size);
    apex_json.write('keyStepSize'       , l_key_step_size);

    apex_json.write('title', l_title);
    apex_json.write('titleCollapse'     , l_title_collapse);
    apex_json.write('titleRestore'      , l_title_restore);

    apex_json.write_raw('changeFunction', l_change_function);

    apex_json.write('paddingFirst'      , l_padding_first);
    apex_json.write('paddingSecond'     , l_padding_second);

    apex_json.close_object;

    apex_javascript.add_onload_code(p_code => 'FOS.splitter(' || apex_json.get_clob_output|| ', '|| l_init_js_fn || ');');

    apex_json.free_output;

    return l_result;
end;

-- ajax callback for storing the current splitter position as a user preference
function ajax
    ( p_region apex_plugin.t_region
    , p_plugin apex_plugin.t_plugin
    )
return apex_plugin.t_region_ajax_result
as
    -- error handling
    l_apex_error   apex_error.t_error;
    l_result       apex_error.t_error_result;
    -- return type
    l_return       apex_plugin.t_region_ajax_result;
begin
    --debug
    if apex_application.g_debug
    then
        apex_plugin_util.debug_region
            ( p_plugin => p_plugin
            , p_region => p_region
            );
    end if;

    set_preference
        ( p_region_id => p_region.id
        , p_position  => apex_application.g_x01
        , p_collapsed => apex_application.g_x02
        );

    htp.p('{"status": "success"}');

    return l_return;
exception
    when others then
        apex_json.initialize_output;
        l_apex_error.message             := sqlerrm;
        --l_apex_error.additional_info     := ;
        --l_apex_error.display_location    := ;
        --l_apex_error.association_type    := ;
        --l_apex_error.page_item_name      := ;
        l_apex_error.region_id           := p_region.id;
        --l_apex_error.column_alias        := ;
        --l_apex_error.row_num             := ;
        --l_apex_error.is_internal_error   := ;
        --l_apex_error.apex_error_code     := ;
        l_apex_error.ora_sqlcode         := sqlcode;
        l_apex_error.ora_sqlerrm         := sqlerrm;
        l_apex_error.error_backtrace     := dbms_utility.format_error_backtrace;
        --l_apex_error.component           := ;
        --
        l_result := error_function_callback(l_apex_error);

        apex_json.open_object;
        apex_json.write('status'          , 'error');
        apex_json.write('message'         , l_result.message);
        apex_json.write('additional_info' , l_result.additional_info);
        apex_json.write('display_location', l_result.display_location);
        apex_json.write('page_item_name'  , l_result.page_item_name);
        apex_json.write('column_alias'    , l_result.column_alias);
        apex_json.close_object;
        return l_return;
end;

end;
/




