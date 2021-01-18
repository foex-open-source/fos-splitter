prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 61118001090994374
--     PLUGIN: 134108205512926532
--     PLUGIN: 547902228942303344
--     PLUGIN: 168413046168897010
--     PLUGIN: 13235263798301758
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 106296184223956059
--     PLUGIN: 35822631205839510
--     PLUGIN: 2674568769566617
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--     PLUGIN: 56714461465893111
--     PLUGIN: 98648032013264649
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/com_fos_splitter
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(134108205512926532)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.FOS.SPLITTER'
,p_display_name=>'FOS - Splitter'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#libraries/widget.splitter.js',
'#PLUGIN_FILES#js/script#MIN#.js'))
,p_css_file_urls=>'#PLUGIN_FILES#css/style#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'-- =============================================================================',
'',
'g_in_error_handling_callback boolean := false;',
'',
'--------------------------------------------------------------------------------',
'-- private function to include the apex error handling function, if one is',
'-- defined on application or page level',
'--------------------------------------------------------------------------------',
'function error_function_callback',
'  ( p_error in apex_error.t_error',
'  )  return apex_error.t_error_result',
'is',
'  c_cr constant varchar2(1) := chr(10);',
'',
'  l_error_handling_function apex_application_pages.error_handling_function%type;',
'  l_statement               varchar2(32767);',
'  l_result                  apex_error.t_error_result;',
'',
'  procedure log_value (',
'      p_attribute_name in varchar2,',
'      p_old_value      in varchar2,',
'      p_new_value      in varchar2 )',
'  is',
'  begin',
'      if   p_old_value <> p_new_value',
'        or (p_old_value is not null and p_new_value is null)',
'        or (p_old_value is null     and p_new_value is not null)',
'      then',
'          apex_debug.info(''%s: %s'', p_attribute_name, p_new_value);',
'      end if;',
'  end log_value;',
'begin',
'  if not g_in_error_handling_callback ',
'  then',
'    g_in_error_handling_callback := true;',
'',
'    begin',
'      select /*+ result_cache */',
'             coalesce(p.error_handling_function, f.error_handling_function)',
'        into l_error_handling_function',
'        from apex_applications f,',
'             apex_application_pages p',
'       where f.application_id     = apex_application.g_flow_id',
'         and p.application_id (+) = f.application_id',
'         and p.page_id        (+) = apex_application.g_flow_step_id;',
'    exception when no_data_found then',
'        null;',
'    end;',
'  end if;',
'',
'  if l_error_handling_function is not null',
'  then',
'',
'    l_statement := ''declare''||c_cr||',
'                       ''l_error apex_error.t_error;''||c_cr||',
'                   ''begin''||c_cr||',
'                       ''l_error := apex_error.g_error;''||c_cr||',
'                       ''apex_error.g_error_result := ''||l_error_handling_function||'' (''||c_cr||',
'                           ''p_error => l_error );''||c_cr||',
'                   ''end;'';',
'',
'    apex_error.g_error := p_error;',
'',
'    begin',
'        apex_exec.execute_plsql (',
'            p_plsql_code      => l_statement );',
'    exception when others then',
'        apex_debug.error(''error in error handler: %s'', sqlerrm);',
'        apex_debug.error(''backtrace: %s'', dbms_utility.format_error_backtrace);',
'    end;',
'',
'    l_result := apex_error.g_error_result;',
'',
'    if l_result.message is null',
'    then',
'        l_result.message          := nvl(l_result.message,          p_error.message);',
'        l_result.additional_info  := nvl(l_result.additional_info,  p_error.additional_info);',
'        l_result.display_location := nvl(l_result.display_location, p_error.display_location);',
'        l_result.page_item_name   := nvl(l_result.page_item_name,   p_error.page_item_name);',
'        l_result.column_alias     := nvl(l_result.column_alias,     p_error.column_alias);',
'    end if;',
'  else',
'    l_result.message          := p_error.message;',
'    l_result.additional_info  := p_error.additional_info;',
'    l_result.display_location := p_error.display_location;',
'    l_result.page_item_name   := p_error.page_item_name;',
'    l_result.column_alias     := p_error.column_alias;',
'  end if;',
'',
'  if l_result.message = l_result.additional_info',
'  then',
'    l_result.additional_info := null;',
'  end if;',
'',
'  g_in_error_handling_callback := false;',
'',
'  return l_result;',
'',
'exception',
'  when others then',
'    l_result.message             := ''custom apex error handling function failed !!'';',
'    l_result.additional_info     := null;',
'    l_result.display_location    := apex_error.c_on_error_page;',
'    l_result.page_item_name      := null;',
'    l_result.column_alias        := null;',
'    g_in_error_handling_callback := false;',
'    return l_result;',
'',
'end error_function_callback;',
'--',
'-- helper function for getting the preference key based on the region id',
'function get_preference_key',
'    ( p_region_id varchar2',
'    )',
'return varchar2',
'as',
'begin',
'    return ''F'' || V(''APP_ID'') || ''_'' || p_region_id || ''_SPLITTER_STATE'';',
'end;',
'',
'-- helper function for getting the preference value based on the region id',
'function get_preference',
'    ( p_region_id varchar2',
'    )',
'return varchar2',
'as',
'begin',
'    return apex_util.get_preference(get_preference_key(p_region_id));',
'end;',
'',
'-- helper function for storing the preference',
'procedure set_preference',
'    ( p_region_id varchar2',
'    , p_position  varchar2',
'    , p_collapsed varchar2',
'    )',
'as',
'    l_preference varchar2(100);',
'    ',
'    function is_numeric',
'        ( p_str varchar2',
'        )',
'    return boolean',
'    as',
'        l_number number := p_str;',
'    begin',
'        return true;',
'    exception',
'        when others then',
'            return false;',
'    end;',
'begin',
'    if is_numeric(p_position) and p_collapsed in (''true'', ''false'')',
'    then',
'        l_preference := p_position || '':'' || p_collapsed;',
'        apex_util.set_preference(get_preference_key(p_region_id), l_preference);',
'        apex_debug.info',
'            ( p_message => ''Splitter preference for region %s set to %s:%s''',
'            , p0        => p_region_id',
'            , p1        => p_position',
'            , p2        => p_collapsed',
'            );',
'    else',
'        apex_debug.warn',
'            ( p_message => ''Splitter preference for region %s is expected as nnn:[true|false] but received %s:%s''',
'            , p0        => p_region_id',
'            , p1        => p_position',
'            , p2        => p_collapsed',
'            );',
'    end if;',
'end;',
'',
'-- helper function for getting the title, collapse and restore messages',
'function get_message',
'    ( p_type      varchar2 -- in [collapse | restore]',
'    , p_attribute varchar2 ',
'    )',
'return varchar2',
'as',
'    l_collapse_text_msg varchar2(100) := ''APEX.SPLITTER.COLLAPSE_TEXT'';',
'    l_restore_text_msg  varchar2(100) := ''APEX.SPLITTER.RESTORE_TEXT'';',
'    ',
'    l_message varchar2(1000);',
'begin',
'    if p_type = ''collapse'' then',
'        l_message := nvl(p_attribute, apex_lang.message(l_collapse_text_msg));',
'        if l_message = l_collapse_text_msg then',
'            l_message := ''Collapse'';',
'        end if;',
'    elsif p_type = ''restore'' then',
'        l_message := nvl(p_attribute, apex_lang.message(l_restore_text_msg));',
'        if l_message = l_restore_text_msg then',
'            l_message := ''Restore'';',
'        end if;',
'    end if;',
'',
'    return l_message;',
'end;',
'',
'-- main plug-in entry point',
'function render',
'    ( p_region              apex_plugin.t_region',
'    , p_plugin              apex_plugin.t_plugin',
'    , p_is_printer_friendly boolean',
'    )',
'return apex_plugin.t_region_render_result',
'as',
'    l_result            apex_plugin.t_region_render_result;',
'',
'    -- attributes',
'    l_orientation       p_region.attribute_01%type := p_region.attribute_01;',
'    l_direction         p_region.attribute_02%type := p_region.attribute_02;',
'',
'    -- position specific attributes',
'    l_pos           p_region.attribute_03%type := p_region.attribute_03;',
'    l_pos_fn        p_region.attribute_04%type := ''function(){ return '' || p_region.attribute_04 || ''; }'';',
'    ',
'    -- preference specific attributes',
'    l_pos_pref      apex_t_varchar2  := apex_string.split(get_preference(p_region.id), '':'');',
'    l_has_pref      boolean          := l_pos_pref.count = 2;',
'    l_pos_pref_pos  number  := case when l_has_pref then l_pos_pref(1)          else null end;',
'    l_pos_pref_col  boolean := case when l_has_pref then l_pos_pref(2) = ''true'' else null end;',
'    ',
'    l_min_size      number  := p_region.attribute_05;',
'    l_height_fn     p_region.attribute_06%type := ''function(){ return '' || p_region.attribute_06 || ''; }'';',
'',
'    -- options',
'    l_options            apex_t_varchar2 := apex_string.split(p_region.attribute_10, '':'');',
'',
'    l_persist_state_pref  boolean := ''persist-state''         member of l_options;',
'    l_persist_state_local boolean := ''persist-state-local''   member of l_options;',
'    l_continuous_resize   boolean := ''continuous-resize''     member of l_options;',
'    l_can_collapse        boolean := ''can-collapse''          member of l_options;',
'    l_drag_collapse       boolean := ''drag-collapse''         member of l_options;',
'    l_contains_iframe     boolean := ''contains-iframe''       member of l_options;',
'    l_lazy_render         boolean := ''lazy-render''           member of l_options;',
'    l_resize_jet_charts   boolean := ''responsive-jet-charts'' member of l_options;',
'    ',
'    -- advanced options',
'    l_advanced_options  boolean := nvl(p_region.attribute_15, ''N'') = ''Y'';',
'    ',
'    l_custom_selector   p_region.attribute_16%type := p_region.attribute_16;',
'    l_step_size         number := p_region.attribute_17;  ',
'    l_key_step_size     number := p_region.attribute_18;',
'    ',
'    -- title messages',
'    l_title             p_region.attribute_19%type := p_region.attribute_19;',
'    l_title_collapse    p_region.attribute_20%type := get_message(''collapse'',p_region.attribute_20);',
'    l_title_restore     p_region.attribute_21%type := get_message(''restore'', p_region.attribute_21);',
'    ',
'    l_change_function   p_region.attribute_22%type := nvl(p_region.attribute_22, ''function(){}'');',
'    ',
'    l_padding_first     number := nvl(p_region.attribute_23, 16);',
'    l_padding_second    number := nvl(p_region.attribute_24, 16);',
'',
'    l_region_id         p_region.static_id%type := p_region.static_id;',
'    ',
'    -- Javascript Initialization Code',
'    l_init_js_fn           varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_region.init_javascript_code), ''undefined'');',
'begin',
'',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_region',
'            ( p_plugin => p_plugin',
'            , p_region => p_region',
'            );',
'    end if;   ',
'',
'    apex_json.initialize_clob_output;',
'    ',
'    apex_json.open_object;',
'    ',
'    apex_json.write(''regionId'', l_region_id);',
'    apex_json.write(''orientation'', l_orientation);',
'    apex_json.write(''direction'', l_direction);',
'    ',
'    -- either position+collapsed, positionCode or positionFunction must be provided',
'    if l_persist_state_pref and l_has_pref then',
'        apex_json.write(''position'', l_pos_pref_pos);',
'        apex_json.write(''collapsed'', l_pos_pref_col);',
'    else',
'        if l_pos != ''custom'' then',
'            apex_json.write(''positionCode'', l_pos);',
'        else',
'            apex_json.write_raw(''positionFunction'', l_pos_fn);',
'        end if;',
'    end if;',
'    ',
'    apex_json.write(''minSize'', l_min_size);',
'    apex_json.write_raw(''heightFunction'', l_height_fn);',
'    apex_json.write(''persistStatePref'', l_persist_state_pref);',
'    apex_json.write(''persistStateLocal'', l_persist_state_local);',
'    ',
'    -- the AJAX identifier is only passed along if we persist the position on the server',
'    if l_persist_state_pref then',
'        apex_json.write(''ajaxIdentifier'', apex_plugin.get_ajax_identifier);',
'    end if;',
'    ',
'    apex_json.write(''continuousResize''  , l_continuous_resize);',
'    apex_json.write(''canCollapse''       , l_can_collapse);',
'    apex_json.write(''dragCollapse''      , l_drag_collapse);',
'    apex_json.write(''containsIframe''    , l_contains_iframe);',
'    apex_json.write(''lazyRender''        , l_lazy_render);',
'    apex_json.write(''resizeJetCharts''   , l_resize_jet_charts);',
'',
'    apex_json.write(''customSelector''    , l_custom_selector);',
'    apex_json.write(''stepSize''          , l_step_size);',
'    apex_json.write(''keyStepSize''       , l_key_step_size);',
'    ',
'    apex_json.write(''title'', l_title);',
'    apex_json.write(''titleCollapse''     , l_title_collapse);',
'    apex_json.write(''titleRestore''      , l_title_restore);',
'    ',
'    apex_json.write_raw(''changeFunction'', l_change_function);',
'    ',
'    apex_json.write(''paddingFirst''      , l_padding_first);',
'    apex_json.write(''paddingSecond''     , l_padding_second);',
'    ',
'    apex_json.close_object;',
'    ',
'    apex_javascript.add_onload_code(p_code => ''FOS.splitter('' || apex_json.get_clob_output|| '', ''|| l_init_js_fn || '');'');',
'    ',
'    apex_json.free_output;',
'    ',
'    return l_result;',
'end;',
'',
'-- ajax callback for storing the current splitter position as a user preference',
'function ajax',
'    ( p_region apex_plugin.t_region',
'    , p_plugin apex_plugin.t_plugin ',
'    )',
'return apex_plugin.t_region_ajax_result',
'as',
'    -- error handling',
'    l_apex_error   apex_error.t_error;',
'    l_result       apex_error.t_error_result;',
'    -- return type',
'    l_return       apex_plugin.t_region_ajax_result;',
'begin',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_region',
'            ( p_plugin => p_plugin',
'            , p_region => p_region',
'            );',
'    end if;',
'    ',
'    set_preference',
'        ( p_region_id => p_region.id',
'        , p_position  => apex_application.g_x01',
'        , p_collapsed => apex_application.g_x02',
'        );',
'',
'    htp.p(''{"status": "success"}'');',
'    ',
'    return l_return;',
'exception',
'    when others then',
'        apex_json.initialize_output;',
'        l_apex_error.message             := sqlerrm;',
'        --l_apex_error.additional_info     := ;',
'        --l_apex_error.display_location    := ;',
'        --l_apex_error.association_type    := ;',
'        --l_apex_error.page_item_name      := ;',
'        l_apex_error.region_id           := p_region.id;',
'        --l_apex_error.column_alias        := ;',
'        --l_apex_error.row_num             := ;',
'        --l_apex_error.is_internal_error   := ;',
'        --l_apex_error.apex_error_code     := ;',
'        l_apex_error.ora_sqlcode         := sqlcode;',
'        l_apex_error.ora_sqlerrm         := sqlerrm;',
'        l_apex_error.error_backtrace     := dbms_utility.format_error_backtrace;',
'        --l_apex_error.component           := ;',
'        --',
'        l_result := error_function_callback(l_apex_error);',
'',
'        apex_json.open_object;',
'        apex_json.write(''status''          , ''error'');',
'        apex_json.write(''message''         , l_result.message);',
'        apex_json.write(''additional_info'' , l_result.additional_info);',
'        apex_json.write(''display_location'', l_result.display_location);',
'        apex_json.write(''page_item_name''  , l_result.page_item_name);',
'        apex_json.write(''column_alias''    , l_result.column_alias);',
'        apex_json.close_object; ',
'        return l_return;',
'end;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Splitter</strong> plug-in is a region that divides its 2 subregions into 2 panels, separated by a draggable splitter bar. The subregions can be split horizontally or vertically, with numerous other layout options.</p>',
'<p>This region <strong>must</strong> have exactly 2 subregions and it works best with a template without margins or padding, such as Blank With Attributes.</p>',
'<p>This plug-in leverages the Spitter widget that is used in Page Designer. We have included it in this plug-in, as it required a few minor tweaks to support splitters hidden behind tabs, collapsed regions etc.</p>'))
,p_version_identifier=>'20.2.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>649
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139057142383556745)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Region Orientation'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'horizontal'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>A horizontal orientation splits the two sub regions side by side. A vertical orientation splits the two sub regions one on top of the other. The first sub region is always on the left or top.</p>',
'<p><strong>Note:</strong> This option cannot be changed after initialization via Javascript.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139057491194556745)
,p_plugin_attribute_id=>wwv_flow_api.id(139057142383556745)
,p_display_sequence=>10
,p_display_value=>'Horizontal'
,p_return_value=>'horizontal'
,p_help_text=>'Sub regions are side by side'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139058016645556746)
,p_plugin_attribute_id=>wwv_flow_api.id(139057142383556745)
,p_display_sequence=>20
,p_display_value=>'Vertical'
,p_return_value=>'vertical'
,p_help_text=>'Sub regions are stacked'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139058496248556746)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Direction'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'begin'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>This option determines which side the splitter will collapse towards.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139058915770556746)
,p_plugin_attribute_id=>wwv_flow_api.id(139058496248556746)
,p_display_sequence=>10
,p_display_value=>'To Start (left/top)'
,p_return_value=>'begin'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the region orientation is Horizontal, collapse to the left.</p>',
'<p>If the region orientation is Vertical, collapse to the top.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139059342629556746)
,p_plugin_attribute_id=>wwv_flow_api.id(139058496248556746)
,p_display_sequence=>20
,p_display_value=>'To End (right/bottom)'
,p_return_value=>'end'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the region orientation is Horizontal, collapse to the right.</p>',
'<p>If the region orientation is Vertical, collapse to the bottom.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139059870538556747)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Splitter Position'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'1/2'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The initial position of the splitter. The position is always measured from the side that collapses.</p>',
'<p>If Persist State is enabled and a position has already been saved, this value will be overridden.</p>',
'<p><strong>Note:</strong> if the splitter position is not persisted then on window/region resize the splitter position will be repositioned automatically based on this setting.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139062787775556748)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>10
,p_display_value=>'0 (collapsed)'
,p_return_value=>'0'
,p_help_text=>'Collapsed at the side that collapses'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139063249539556748)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>20
,p_display_value=>'1/4'
,p_return_value=>'1/4'
,p_help_text=>'A quarter of the way in'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139060233779556747)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>30
,p_display_value=>'1/3'
,p_return_value=>'1/3'
,p_help_text=>'A third of the way in'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139060732316556747)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>40
,p_display_value=>'1/2 (centered)'
,p_return_value=>'1/2'
,p_help_text=>'Centered'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139061288176556747)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>50
,p_display_value=>'2/3'
,p_return_value=>'2/3'
,p_help_text=>'Two thirds of the way in'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139061748812556747)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>60
,p_display_value=>'3/4'
,p_return_value=>'3/4'
,p_help_text=>'Three quarters of the way in'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139062274905556747)
,p_plugin_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_display_sequence=>80
,p_display_value=>'custom'
,p_return_value=>'custom'
,p_help_text=>'Dynamically calculated in Javascript'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139063831950556748)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'JavaScript Expression Evaluating to Splitter Position in Pixels'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139059870538556747)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'custom'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This can be as simple as a static value:</p>',
'<pre>300</pre>',
'<p>Or a more complex expression that takes into account the actual width of the region:</p>',
'<pre>$(''#my-splitter-region'').width() / 5</pre>'))
,p_help_text=>'<p>Provide the starting position as a Javascript expression that evaluates to a number in pixels.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139064187818556748)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Minimum Panel Size'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'60'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Minimum width/height (depending on orientation) of both panels.</p>',
'<p>Ensure that the total size of the splitter will never be less than twice this value.</p>',
'<p>If not specified, 60 is used.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139064604931556748)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'JavaScript Expression Evaluating to Region Height in Pixels'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_default_value=>'500'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This can be a static value such as <code>500</code> or a more complex expression.</p>',
'<p>For example, if you want the splitter to always take the full height of the viewport, excluding the top navigation bar, you might want to set it to:</p>',
'<pre>$(window).height() - $(''#t_Header'').height()</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>A Javascript expression that evaluates to a number in pixels.</p>',
'<p>This expression will be re-evaluated and reapplied every time the window size changes.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139064976569556748)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'can-collapse:continuous-resize'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The splitter has the following options</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139066344386556749)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>10
,p_display_value=>'Can Collapse'
,p_return_value=>'can-collapse'
,p_help_text=>'Whether the splitter should be collapsable.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139067417799556749)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>20
,p_display_value=>'Continuous Resize'
,p_return_value=>'continuous-resize'
,p_help_text=>'Decides whether the subregions should be resized on each movement of the splitter while dragging or moving with the arrow keys. Otherwise the sub regions are resized only when the splitter stops moving. This should be turned off if the sub regions ar'
||'e computationally expensive to resize.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139066861317556749)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>30
,p_display_value=>'Drag Over Minimum Size to Collapse'
,p_return_value=>'drag-collapse'
,p_help_text=>'If enabled, dragging past the minimum size will collapse the splitter. Otherwise the splitter can only be dragged to the minimum size.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(71942997560844926)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>40
,p_display_value=>'Lazy Render'
,p_return_value=>'lazy-render'
,p_help_text=>'<p>check this option when the splitter is within a hidden region on page load e.g. a non-active tab, hidden by a region display selector etc.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139793585727897919)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>50
,p_display_value=>'Persist State (Local Storage)'
,p_return_value=>'persist-state-local'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Persists the position of the splitter in the browser''s local storage.</p>',
'<p>This option does not require communication to the database, but it also means that the preference is not carried to other devices and is not user specific.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139065344150556749)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>60
,p_display_value=>'Persist State (User Preference)'
,p_return_value=>'persist-state'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Persists the position of the splitter as a user preference.</p>',

'<p>Note that this will require an AJAX call every time the splitter is moved.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(73709263646565452)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>70
,p_display_value=>'Resize Jet Charts to Fit Region'
,p_return_value=>'responsive-jet-charts'
,p_help_text=>'<p>Check this option when you are splitting one or more JET Chart regions and you would like the chart to consume the entire space of the spliced region(s).</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(139065900634556749)
,p_plugin_attribute_id=>wwv_flow_api.id(139064976569556748)
,p_display_sequence=>80
,p_display_value=>'Subregion Contains iframe'
,p_return_value=>'contains-iframe'
,p_help_text=>'Enable if either subregion of the splitter contains an iframe. This ensures to overcome a browser restriction that prohibits dragging an element (the splitter) over an iframe.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139067870689556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Advanced Options'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'<p>Toggle this advanced options to have more control over padding, titles, child region selection etc.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139068282461556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_prompt=>'Custom Selector'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_examples=>'<pre><code>.container</code></pre>'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Optional. A selector that identifies the subelement that contains the two sub regions.</p>',
'<p>The selector will be scoped under the current region.</p>',
'<p>If the selector returns multiple elements, the first will be chosen.</p>',
'<p>This attribute is intended for non-Universal Theme apps where the page markup might be different. If you are using the Universal Theme, then you should leave this attribute empty.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139068724464556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_prompt=>'Step Size'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_unit=>'pixels'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>Optional. The number of pixels the splitter moves in each increment when dragging or with the arrow keys. If not specified the splitter can be dragged with single pixel precision.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139069064653556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_prompt=>'Keyboard Step Size'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'10'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Optional. The number of pixels to move the splitter for each arrow key press. If not specified the default is 10.</p>',
'<p>This value will be overridden by Step Size if provided.</p>'))
);
end;
/
begin
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139069444023556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>190
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>This is the title (tooltip) text for the splitter bar. Providing a title for each splitter is helpful for accessibility especially when there are multiple splitters.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139069903415556750)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>200
,p_prompt=>'Title - Collapse'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>This is the title (tooltip) text for the splitter handle when the splitter is expanded. If not specified a default is provided. This attribute is translatable.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139070321330556751)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>21
,p_display_sequence=>210
,p_prompt=>'Title - Restore'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>This is the title (tooltip) text for the splitter handle when the splitter is collapsed. If not specified a default is provided. This attribute is translatable.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139070640461556751)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>22
,p_display_sequence=>220
,p_prompt=>'Execute Javascript on Splitter Move'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>function(event, info){',
'    console.log(info.collapsed, ui.position, ui.lastPosition);',
'}</pre>'))
,p_help_text=>'<p>Execute a function every time the splitter is moved.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139071091578556751)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>23
,p_display_sequence=>230
,p_prompt=>'Padding - First Panel'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'16'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>The padding of the first subregion in pixels. If no value is provided, the default will be 16.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(139071437626556751)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>24
,p_display_sequence=>240
,p_prompt=>'Padding - Second Panel'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'16'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(139067870689556750)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>The padding of the first subregion in pixels. If no value is provided, the default will be 16.</p>'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(70933406461629853)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h3>Lazy Rendering</h3>',
'<p>You may want to increase the lazy rendering visibility check delay on page load as your page might not be ready e.g. tabs, grids, .etc rendered</p>',
'<code>',
'function(options) {',
'   options.visibilityCheckDelay = 1000; // milliseconds',
'   return options;',
'}',
'</code>'))
,p_help_text=>'<p>You can use this attribute to define a function that will allow you to change/override the plugin settings. This gives you added flexibility of controlling the settings from a single Javascript function defined in a "Static Application File"</p>'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(72657724844199612)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_name=>'fos-splitter-after-render'
,p_display_name=>'FOS - Splitter - After Render'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(72658384966206747)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_name=>'fos-splitter-after-resize'
,p_display_name=>'FOS - Splitter - After Resize'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(72658029621202133)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_name=>'fos-splitter-before-render'
,p_display_name=>'FOS - Splitter - Before Render'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A676C6F62616C20617065782A2F0A2F2A210A2053706C6974746572202D2061206A51756572792055492062617365642077696467657420666F722064796E616D6963616C6C79206469766964696E672074686520617661696C61626C652073706163';
wwv_flow_api.g_varchar2_table(2) := '6520666F722074776F2073756220726567696F6E7320686F72697A6F6E74616C6C79206F7220766572746963616C6C792E0A20436F707972696768742028632920323031302C20323031372C204F7261636C6520616E642F6F722069747320616666696C';
wwv_flow_api.g_varchar2_table(3) := '69617465732E20416C6C207269676874732072657365727665642E0A202A2F0A2F2A2A0A202A204066696C654F766572766965770A202A205468652073706C6974746572206265686176696F72206D6F73746C7920666F6C6C6F777320746865204F7261';
wwv_flow_api.g_varchar2_table(4) := '636C6520524355582067756964656C696E65732061732077656C6C20617320746865205741492D4152494120616E64204448544D4C205374796C652047756964652077696E646F770A202A2073706C69747465722064657369676E207061747465726E2E';
wwv_flow_api.g_varchar2_table(5) := '20446966666572656E6365733A0A202A20202D20484F4D4520616E6420454E44206B657973206E6F7420737570706F7274656420616E6420454E5445522F535041434520657870616E6420616E6420636F6C6C617073652E205741492D4152494120616E';
wwv_flow_api.g_varchar2_table(6) := '64204448544D4C205374796C65204775696465207265636F6D6D656E640A202A2020484F4D4520616E6420454E44206B657973206D6F76652062617220746F206D696E206F72206D617820706F736974696F6E20616E6420454E5445522077696C6C2022';
wwv_flow_api.g_varchar2_table(7) := '726573746F72652073706C697474657220746F2070726576696F757320706F736974696F6E222E0A202A20205243555820646F6573206E6F7420646566696E65207468657365206B6579626F617264206265686176696F727320616E6420746865792064';
wwv_flow_api.g_varchar2_table(8) := '6F206E6F74207365656D20746861742075736566756C20636F6D706172656420746F20657870616E642F636F6C6C617073652E0A202A20202D204379636C65207468726F7567682073706C6974746572732075736573205B53686966742B5D4374726C2B';
wwv_flow_api.g_varchar2_table(9) := '46362066726F6D205741492D4152494120616E64206E6F74204374726C2B416C742B502066726F6D20525543582E0A202A20202D2054686572652069732061206E6F6E20636F6C6C617073696E67206D6F64652074686174205243555820646F65736E27';
wwv_flow_api.g_varchar2_table(10) := '742064657363726962652061732077656C6C2061732064697361626C65642073706C6974746572730A202A20202D205741492D41524941207265636F6D6D656E64732073657474696E6720617269612D636F6E74726F6C7320746F207468652074776F20';
wwv_flow_api.g_varchar2_table(11) := '73756220726567696F6E2069647320627574207468697320636175736564204A41575320746F20726561642065787472610A202A2020696E737472756374696F6E7320746861742070726F7669646564206E6F2062656E656669742E0A202A0A202A2054';
wwv_flow_api.g_varchar2_table(12) := '79706963616C6C7920746865206D61726B757020666F7220612073706C697474657220697320612064697620776974682074776F206368696C6420646976732E204120736570617261746F7220697320696E736572746564206265747765656E20746865';
wwv_flow_api.g_varchar2_table(13) := '2074776F0A202A206469767320746F2073706C6974207468652061726561206F6620746865206F75746572206469762E20546865206F7269656E746174696F6E2028686F72697A6F6E74616C206F7220766572746963616C29207065727461696E732074';
wwv_flow_api.g_varchar2_table(14) := '6F207468652072656C6174696F6E736869700A202A206265747765656E207468652074776F206469767320616E64206E6F7420746865206F7269656E746174696F6E206F662074686520736570617261746F722E20536F20686F72697A6F6E74616C206F';
wwv_flow_api.g_varchar2_table(15) := '7269656E746174696F6E206861732074776F206469767320736964652062790A202A20736964652077697468206120766572746963616C20736570617261746F72206265747765656E207468656D2E20566572746963616C206F7269656E746174696F6E';
wwv_flow_api.g_varchar2_table(16) := '206861732074776F2064697673206F6E65206F6E20746F70206F6620746865206F74686572207769746820610A202A20686F72697A6F6E74616C20736570617261746F72206265747765656E207468656D2E20546865206669727374206368696C642064';
wwv_flow_api.g_varchar2_table(17) := '697620697320616C77617973206F6E20746865206C656674206F7220746F702E0A202A0A202A205768656E207468652077696E646F7720286F722073706C697474657220636F6E7461696E65722920697320726573697A65642074686520657874726120';
wwv_flow_api.g_varchar2_table(18) := '73697A6520697320616464656420746F20286F722072656D6F7665642066726F6D29207468652073756220726567696F6E0A202A206F70706F73697465207468652073696465207468652073706C69747465722062617220697320706F736974696F6E65';
wwv_flow_api.g_varchar2_table(19) := '642066726F6D202853656520706F736974696F6E656446726F6D206F7074696F6E292E0A202A0A202A20546F20637265617465206D6F726520636F6D706C6578207375626469766973696F6E732073706C697474657220776964676574732063616E2062';
wwv_flow_api.g_varchar2_table(20) := '65206E657374656420696E736964652065616368206F746865722E205768656E2073706C69747465727320617265206E65737465640A202A20637265617465207468652073706C6974746572732066726F6D206F7574657220746F20696E6E6572206D6F';
wwv_flow_api.g_varchar2_table(21) := '73742E0A202A0A202A2050657273697374696E67207468652073706C697474657220706F736974696F6E20656974686572206F6E2074686520636C69656E74206F7220736572766572206973206F757473696465207468652073636F7065206F66207468';
wwv_flow_api.g_varchar2_table(22) := '6973207769646765742062757420697320656173696C790A202A20646F6E65206279206C697374656E696E6720746F206368616E6765206576656E74732E0A202A0A202A20526967687420746F206C65667420646972656374696F6E2069732073757070';
wwv_flow_api.g_varchar2_table(23) := '6F727465642E205768656E2074686520646972656374696F6E2069732052544C206120686F72697A6F6E74616C2073706C69747465722077696C6C20706C616365207468652066697273740A202A2073756220726567696F6E20746F2074686520726967';
wwv_flow_api.g_varchar2_table(24) := '6874206F66207468652062617220616E6420746865207365636F6E642073756220726567696F6E20746F20746865206C656674206F6620746865206261722E0A202A0A202A20466F7220626574746572206163636573736962696C697479206974206973';
wwv_flow_api.g_varchar2_table(25) := '207265636F6D6D656E64656420746F2070726F76696465206120776179202870657268617073207669612061206D656E75206974656D2920746F207265736574207468652073706C69747465722873290A202A20746F2074686569722064656661756C74';
wwv_flow_api.g_varchar2_table(26) := '2073657474696E67732E2054686973206973206F757473696465207468652073636F7065206F662074686973207769646765742E0A202A0A202A20544F444F3A0A202A202D20636F6E736964657220696E646570656E64656E7420736E617020746F2063';
wwv_flow_api.g_varchar2_table(27) := '6F6C6C6170736520616E64206D696E2073697A65730A202A202D20636F6E736964657220696E646570656E64656E7420636F6E74726F6C206F766572206D696E2F6D61782073697A650A202A202D20636F6E736964657220636F6E74726F6C206F766572';
wwv_flow_api.g_varchar2_table(28) := '20776869636820736964652067657473206578747261207370616365206F6E20726573697A650A202A202D20636F6E736964657220736176696E672070657263656E746167657320726174686572207468616E2070782076616C75657320666F7220706F';
wwv_flow_api.g_varchar2_table(29) := '736974696F6E202D20636F756C6420626520646F6E652065787465726E616C20746F207769646765740A202A202D206675747572653A20746F75636820737570706F727420686F706566756C6C7920636F6D65732066726F6D206A51756572792055490A';
wwv_flow_api.g_varchar2_table(30) := '202A0A202A20446570656E64733A0A202A202020206A71756572792E75692E636F72652E6A730A202A202020206A71756572792E75692E64656275672E6A730A202A202020206A71756572792E75692E7574696C2E6A730A202A202020206A7175657279';
wwv_flow_api.g_varchar2_table(31) := '2E75692E7769646765742E6A730A202A202020206A71756572792E75692E647261676761626C652E6A730A202A20202020617065782F7574696C2E6A730A202A2F0A2866756E6374696F6E2028242C207574696C2C20646562756729207B0A2020202022';
wwv_flow_api.g_varchar2_table(32) := '75736520737472696374223B0A0A2020202076617220435F53504C4954544552203D2022612D53706C6974746572222C0A202020202020202053454C5F53504C4954544552203D20222E22202B20435F53504C49545445522C0A2020202020202020435F';
wwv_flow_api.g_varchar2_table(33) := '53504C49545445525F48203D2022612D53706C69747465722D62617248222C0A2020202020202020435F53504C49545445525F56203D2022612D53706C69747465722D62617256222C0A202020202020202053454C5F424152203D20222E22202B20435F';
wwv_flow_api.g_varchar2_table(34) := '53504C49545445525F48202B20222C2E22202B20435F53504C49545445525F562C0A2020202020202020435F53504C49545445525F454E44203D2022612D53706C69747465722D2D656E64222C0A2020202020202020435F5448554D42203D2022612D53';
wwv_flow_api.g_varchar2_table(35) := '706C69747465722D7468756D62222C0A202020202020202053454C5F5448554D42203D20222E22202B20435F5448554D422C0A2020202020202020435F52544C203D2022752D52544C222C0A2020202020202020435F464F4355534544203D202269732D';
wwv_flow_api.g_varchar2_table(36) := '666F6375736564222C0A2020202020202020435F414354495645203D202269732D616374697665222C0A2020202020202020435F434F4C4C4150534544203D202269732D636F6C6C6170736564222C0A2020202020202020435F44495341424C4544203D';
wwv_flow_api.g_varchar2_table(37) := '202269732D64697361626C6564222C0A202020202020202053454C5F425554544F4E203D2022627574746F6E223B0A0A20202020766172205449544C45203D20227469746C65223B0A0A20202020242E7769646765742822617065782E73706C69747465';
wwv_flow_api.g_varchar2_table(38) := '72222C207B0A202020202020202076657273696F6E3A2022352E30222C0A20202020202020207769646765744576656E745072656669783A202273706C6974746572222C0A20202020202020206F7074696F6E733A207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(39) := '6F7269656E746174696F6E3A2022686F72697A6F6E74616C222C202F2F206F722022766572746963616C222E2043616E2774206368616E676520616674657220696E697469616C697A6174696F6E0A202020202020202020202020706F736974696F6E65';
wwv_flow_api.g_varchar2_table(40) := '6446726F6D3A2022626567696E222C202F2F206F722022656E64222E20436F6E74726F6C732066726F6D20776869636820736964652074686520706F736974696F6E206973206D6561737572656420616E640A2020202020202020202020202F2F207768';
wwv_flow_api.g_varchar2_table(41) := '6963682073696465207468652073706C69747465722077696C6C20636F6C6C6170736520746F776172642E0A2020202020202020202020202F2F2043616E2774206368616E676520616674657220696E697469616C697A6174696F6E0A20202020202020';
wwv_flow_api.g_varchar2_table(42) := '20202020206D696E53697A653A2036302C202F2F206D696E2077696474682F68656967687420646570656E64696E67206F6E206F7269656E746174696F6E2C206170706C69657320746F20626F7468206368696C6420656C656D656E74730A2020202020';
wwv_flow_api.g_varchar2_table(43) := '202020202020202F2F2061766F6964207665727920736D616C6C206D696E53697A65206275742069742063616E2062652030206966206E6F436F6C6C61707365206973207472756520616E642031206966206E6F436F6C6C617073652069732066616C73';
wwv_flow_api.g_varchar2_table(44) := '650A2020202020202020202020202F2F20616C736F20656E7375726520746861742074686520746F74616C207769647468206F66207468652073706C69747465722077696C6C206E6F74206265206C657373207468616E20747769636520746865206D69';
wwv_flow_api.g_varchar2_table(45) := '6E53697A650A202020202020202020202020706F736974696F6E3A203130302C202F2F20696E697469616C20706F736974696F6E206F662073706C69747465722E20506F736974696F6E20697320616C77617973206D656173757265642066726F6D2074';
wwv_flow_api.g_varchar2_table(46) := '68652073696465207468617420636F6C6C61707365730A2020202020202020202020206E6F436F6C6C617073653A2066616C73652C202F2F2069662074727565207468652073706C69747465722063616E6E6F7420626520636F6C6C61707365642E2043';
wwv_flow_api.g_varchar2_table(47) := '616E2774206368616E676520616674657220696E697469616C697A6174696F6E0A2020202020202020202020202F2F207768656E2074727565206F7074696F6E7320636F6C6C61707365642C20726573746F7265546578742C20636F6C6C617073655465';
wwv_flow_api.g_varchar2_table(48) := '7874206172652069676E6F7265640A20202020202020202020202064726167436F6C6C617073653A20747275652C202F2F20616C6C6F772064726167206F7065726174696F6E20746F20636F6C6C617073650A202020202020202020202020636F6C6C61';
wwv_flow_api.g_varchar2_table(49) := '707365643A2066616C73652C202F2F20696E697469616C20636F6C6C61707365642073746174650A202020202020202020202020736E61703A2066616C73652C202F2F2066616C7365206F72206E756D626572206F6620706978656C7320746F20736E61';
wwv_flow_api.g_varchar2_table(50) := '702074686520736570617261746F7220746F0A202020202020202020202020696E633A2031302C202F2F206E756D626572206F6620706978656C7320746F206D6F7665207768656E207573696E6720746865206B6579626F6172642E2041206E756D6265';
wwv_flow_api.g_varchar2_table(51) := '7220666F7220736E6170206F766572726964657320696E632E0A2020202020202020202020207265616C54696D653A2066616C73652C202F2F206966207472756520726573697A65206368696C6472656E207768696C65206472616767696E670A202020';
wwv_flow_api.g_varchar2_table(52) := '202020202020202020696672616D654669783A2066616C73652C202F2F2073657420746F2074727565206966207468652073706C6974746572206D6F766573206F76657220616E20696672616D650A202020202020202020202020726573746F72655465';
wwv_flow_api.g_varchar2_table(53) := '78743A206E756C6C2C202F2F207469746C65207465787420666F7220627574746F6E2068616E646C65207768656E20636F6C6C61707365640A202020202020202020202020636F6C6C61707365546578743A206E756C6C2C202F2F207469746C65207465';
wwv_flow_api.g_varchar2_table(54) := '787420666F7220627574746F6E2068616E646C65207768656E20657870616E6465640A2020202020202020202020207469746C653A206E756C6C2C202F2F207469746C65207465787420666F7220736570617261746F720A202020202020202020202020';
wwv_flow_api.g_varchar2_table(55) := '6368616E67653A206E756C6C2C202F2F2063616C6C6261636B207768656E2073706C697474657220706F736974696F6E206368616E67657320666E286576656E742C207B20706F736974696F6E3A203C6E3E2C20636F6C6C61707365643A203C626F6F6C';
wwv_flow_api.g_varchar2_table(56) := '3E207D20290A2020202020202020202020206C617A7952656E6465723A2066616C73652C202F2F20636F6E74726F6C732077686574686572207468652073706C69747465722073686F756C6420696E697469616C697A65206F6E206265696E67206D6164';
wwv_flow_api.g_varchar2_table(57) := '652076697369626C6520652E672E20697320626568696E642061207461620A2020202020202020202020206E65656473526573697A653A2066616C73652C202F2F20636F6E74726F6C732077686574686572207468652073706C6974746572206E656564';
wwv_flow_api.g_varchar2_table(58) := '7320746F20626520726573697A6564207768656E206265696E67206D6164652076697369626C650A2020202020202020202020207669736962696C697479436865636B44656C61793A203330302C202F2F206E756D626572206F66206D696C6C7365636F';
wwv_flow_api.g_varchar2_table(59) := '6E647320746F207761697420616674657220617065787265616479656E64206576656E74206265666F726520636865636B696E6720666F72207669736962696C69747920666F72206C617A792072656E646572696E670A20202020202020202020202069';
wwv_flow_api.g_varchar2_table(60) := '6D6D6564696174655669736962696C697479436865636B3A2066616C7365202F2F20636865636B20696D6D6564696174656C792069662073706C697474657220636F6E7461696E65722069732076697369626C650A20202020202020207D2C0A20202020';
wwv_flow_api.g_varchar2_table(61) := '202020206C617374506F733A206E756C6C2C0A2020202020202020626172243A206E756C6C2C0A20202020202020206265666F7265243A206E756C6C2C0A20202020202020206166746572243A206E756C6C2C0A2020202020202020686F72697A3A2074';
wwv_flow_api.g_varchar2_table(62) := '7275652C0A202020202020202066726F6D456E643A2066616C73652C0A202020202020202062617253697A653A20312C0A0A20202020202020205F6372656174653A2066756E6374696F6E202829207B0A2020202020202020202020207661722073656C';
wwv_flow_api.g_varchar2_table(63) := '66203D20746869732C206F203D2073656C662E6F7074696F6E732C0A202020202020202020202020202020206374726C24203D2073656C662E656C656D656E742C0A20202020202020202020202020202020656C203D206374726C245B305D3B0A0A2020';
wwv_flow_api.g_varchar2_table(64) := '20202020202020202020696620286F2E6C617A7952656E64657229207B0A20202020202020202020202020202020617065782E7769646765742E7574696C2E6F6E5669736962696C6974794368616E676528656C2C2066756E6374696F6E202869735669';
wwv_flow_api.g_varchar2_table(65) := '7369626C6529207B0A20202020202020202020202020202020202020206F2E697356697369626C65203D20697356697369626C653B0A202020202020202020202020202020202020202069662028697356697369626C6520262620216F2E72656E646572';
wwv_flow_api.g_varchar2_table(66) := '656429207B0A20202020202020202020202020202020202020202020202073656C662E5F696E6974436F6D706F6E656E7428293B0A2020202020202020202020202020202020202020202020206F2E72656E6465726564203D20747275653B0A20202020';
wwv_flow_api.g_varchar2_table(67) := '202020202020202020202020202020207D0A202020202020202020202020202020202020202069662028697356697369626C65202626206F2E6E65656473526573697A6529207B0A20202020202020202020202020202020202020202020202073656C66';
wwv_flow_api.g_varchar2_table(68) := '2E5F726573697A6528293B0A2020202020202020202020202020202020202020202020206F2E6E65656473526573697A65203D2066616C73653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B';
wwv_flow_api.g_varchar2_table(69) := '0A20202020202020202020202020202020242877696E646F77292E6F6E2827617065787265616479656E64272C2066756E6374696F6E202829207B0A20202020202020202020202020202020202020202F2F2077652061646420617661726961626C6520';
wwv_flow_api.g_varchar2_table(70) := '7265666572656E636520746F2061766F6964206C6F7373206F662073636F70650A202020202020202020202020202020202020202076617220656C203D206374726C245B305D3B0A20202020202020202020202020202020202020202F2F207765206861';
wwv_flow_api.g_varchar2_table(71) := '766520746F20616464206120736C696768742064656C617920746F206D616B65207375726520617065782077696467657473206861766520696E697469616C697A65642073696E6365202873757270726973696E676C7929202261706578726561647965';
wwv_flow_api.g_varchar2_table(72) := '6E6422206973206E6F7420656E6F7567680A202020202020202020202020202020202020202073657454696D656F75742866756E6374696F6E202829207B0A202020202020202020202020202020202020202020202020617065782E7769646765742E75';
wwv_flow_api.g_varchar2_table(73) := '74696C2E7669736962696C6974794368616E676528656C2C2074727565293B0A20202020202020202020202020202020202020207D2C206F2E7669736962696C697479436865636B44656C6179207C7C2031303030293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(74) := '202020207D293B0A202020202020202020202020202020202F2F20636865636B20696D6D6564696174656C790A20202020202020202020202020202020696620286F2E696D6D6564696174655669736962696C697479436865636B29207B0A2020202020';
wwv_flow_api.g_varchar2_table(75) := '202020202020202020202020202020617065782E7769646765742E7574696C2E7669736962696C6974794368616E676528656C2C2074727565293B0A202020202020202020202020202020207D0A2020202020202020202020207D20656C7365207B0A20';
wwv_flow_api.g_varchar2_table(76) := '20202020202020202020202020202073656C662E5F696E6974436F6D706F6E656E7428293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020205F696E6974436F6D706F6E656E743A2066756E6374696F6E20282920';
wwv_flow_api.g_varchar2_table(77) := '7B0A202020202020202020202020766172206C6566742C20746F702C20637572736F722C0A202020202020202020202020202020206B6579496E632C206B65794465632C20706F732C0A2020202020202020202020202020202073656C66203D20746869';
wwv_flow_api.g_varchar2_table(78) := '732C0A202020202020202020202020202020206F203D20746869732E6F7074696F6E732C0A202020202020202020202020202020206374726C24203D20746869732E656C656D656E742C0A202020202020202020202020202020206F7574203D20757469';
wwv_flow_api.g_varchar2_table(79) := '6C2E68746D6C4275696C64657228292C0A202020202020202020202020202020206B657973203D20242E75692E6B6579436F64652C0A2020202020202020202020202020202067726964203D206F2E736E6170203F205B6F2E736E6170202A20312C206F';
wwv_flow_api.g_varchar2_table(80) := '2E736E6170202A20315D203A2066616C73652C0A202020202020202020202020202020206D696E4C696D6974203D206F2E6E6F436F6C6C61707365203F2030203A20312C0A2020202020202020202020202020202074696D65724964203D206E756C6C3B';
wwv_flow_api.g_varchar2_table(81) := '0A0A202020202020202020202020696620286374726C242E6368696C6472656E28292E6C656E67746820213D3D203229207B0A202020202020202020202020202020207468726F77206E6577204572726F72282253706C6974746572206D757374206861';
wwv_flow_api.g_varchar2_table(82) := '76652065786163746C792074776F206368696C6472656E2E22293B0A2020202020202020202020207D0A202020202020202020202020696620286F2E6F7269656E746174696F6E20213D3D2022686F72697A6F6E74616C22202626206F2E6F7269656E74';
wwv_flow_api.g_varchar2_table(83) := '6174696F6E20213D3D2022766572746963616C2229207B0A202020202020202020202020202020207468726F77206E6577204572726F7228224F7269656E746174696F6E206261642076616C756522293B0A2020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(84) := '2020202020202020696620286F2E706F736974696F6E656446726F6D20213D3D2022626567696E22202626206F2E706F736974696F6E656446726F6D20213D3D2022656E642229207B0A202020202020202020202020202020207468726F77206E657720';

wwv_flow_api.g_varchar2_table(85) := '4572726F722822506F736974696F6E656446726F6D206261642076616C756522293B0A2020202020202020202020207D0A0A202020202020202020202020696620286F2E6D696E53697A65203C206D696E4C696D697429207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(86) := '2020202020206F2E6D696E53697A65203D206D696E4C696D69743B0A2020202020202020202020202020202064656275672E7761726E28224F7074696F6E206D696E53697A652061646A757374656422293B0A2020202020202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(87) := '202020202020202020746869732E686F72697A203D206F2E6F7269656E746174696F6E203D3D3D2022686F72697A6F6E74616C223B0A202020202020202020202020746869732E66726F6D456E64203D206F2E706F736974696F6E656446726F6D203D3D';
wwv_flow_api.g_varchar2_table(88) := '3D2022656E64223B0A202020202020202020202020706F73203D20746869732E686F72697A203F20226C65667422203A2022746F70223B0A202020202020202020202020746869732E6265666F726524203D206374726C242E6368696C6472656E28292E';
wwv_flow_api.g_varchar2_table(89) := '65712830293B0A202020202020202020202020746869732E616674657224203D206374726C242E6368696C6472656E28292E65712831293B0A2020202020202020202020206374726C242E616464436C61737328435F53504C4954544552202B20222072';
wwv_flow_api.g_varchar2_table(90) := '6573697A6522293B0A202020202020202020202020696620286374726C242E6373732822646972656374696F6E2229203D3D3D202272746C2229207B0A202020202020202020202020202020206374726C242E616464436C61737328435F52544C293B0A';
wwv_flow_api.g_varchar2_table(91) := '2020202020202020202020202020202069662028746869732E686F72697A29207B0A2020202020202020202020202020202020202020746869732E6265666F726524203D206374726C242E6368696C6472656E28292E65712831293B0A20202020202020';
wwv_flow_api.g_varchar2_table(92) := '20202020202020202020202020746869732E616674657224203D206374726C242E6368696C6472656E28292E65712830293B0A2020202020202020202020202020202020202020746869732E66726F6D456E64203D2021746869732E66726F6D456E643B';
wwv_flow_api.g_varchar2_table(93) := '0A202020202020202020202020202020207D0A2020202020202020202020207D0A202020202020202020202020696620286374726C242E706172656E742853454C5F53504C4954544552292E6C656E677468203E2030207C7C20746869732E6265666F72';
wwv_flow_api.g_varchar2_table(94) := '65242E69732853454C5F53504C495454455229207C7C20746869732E6166746572242E69732853454C5F53504C49545445522929207B0A202020202020202020202020202020207468726F77206E6577204572726F7228224368696C64206F662073706C';
wwv_flow_api.g_varchar2_table(95) := '69747465722063616E6E6F7420626520612073706C697474657222293B0A2020202020202020202020207D0A2020202020202020202020206966202821746869732E6265666F7265245B305D2E696429207B0A2020202020202020202020202020202074';
wwv_flow_api.g_varchar2_table(96) := '6869732E6265666F7265245B305D2E6964203D20286374726C245B305D2E6964207C7C202273706C69747465722229202B20225F6669727374223B0A2020202020202020202020207D0A2020202020202020202020206966202821746869732E61667465';
wwv_flow_api.g_varchar2_table(97) := '72245B305D2E696429207B0A20202020202020202020202020202020746869732E6166746572245B305D2E6964203D20286374726C245B305D2E6964207C7C202273706C69747465722229202B20225F7365636F6E64223B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(98) := '207D0A202020202020202020202020696620286F2E706F736974696F6E203C206F2E6D696E53697A6529207B0A202020202020202020202020202020206F2E706F736974696F6E203D206F2E6D696E53697A653B0A2020202020202020202020207D0A20';
wwv_flow_api.g_varchar2_table(99) := '2020202020202020202020746869732E6C617374506F73203D206F2E706F736974696F6E3B0A202020202020202020202020696620286F2E736E617029207B0A202020202020202020202020202020206F2E696E63203D206F2E736E61703B0A20202020';
wwv_flow_api.g_varchar2_table(100) := '20202020202020207D0A0A2020202020202020202020202F2F20496E7365727420736570617261746F7220626172206265747765656E207468652074776F206368696C6472656E0A202020202020202020202020746869732E5F72656E64657242617228';
wwv_flow_api.g_varchar2_table(101) := '6F7574293B0A202020202020202020202020746869732E62617224203D2024286F75742E746F537472696E672829292E696E736572744166746572286374726C242E6368696C6472656E28292E6571283029293B202F2F20696E7365727420696E206D69';
wwv_flow_api.g_varchar2_table(102) := '64646C6520696E646570656E64656E74206F6620646972656374696F6E0A0A20202020202020202020202069662028746869732E686F72697A29207B0A20202020202020202020202020202020746869732E62617253697A65203D20746869732E626172';
wwv_flow_api.g_varchar2_table(103) := '242E776964746828293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020746869732E62617253697A65203D20746869732E626172242E68656967687428293B0A2020202020202020202020207D0A0A2020';
wwv_flow_api.g_varchar2_table(104) := '202020202020202020206374726C242E637373287B0A20202020202020202020202020202020706F736974696F6E3A202272656C6174697665220A2020202020202020202020207D292E6368696C6472656E28292E637373287B0A202020202020202020';
wwv_flow_api.g_varchar2_table(105) := '20202020202020706F736974696F6E3A20226162736F6C757465220A2020202020202020202020207D293B0A0A20202020202020202020202069662028746869732E686F72697A29207B0A202020202020202020202020202020206C656674203D207468';
wwv_flow_api.g_varchar2_table(106) := '69732E626172242E706F736974696F6E28295B706F735D3B0A20202020202020202020202020202020746F70203D20303B0A20202020202020202020202020202020637572736F72203D2022652D726573697A65223B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(107) := '20202069662028746869732E66726F6D456E6429207B0A20202020202020202020202020202020202020206B6579496E63203D206B6579732E4C4546543B0A20202020202020202020202020202020202020206B6579446563203D206B6579732E524947';
wwv_flow_api.g_varchar2_table(108) := '48543B0A202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020206B6579496E63203D206B6579732E52494748543B0A20202020202020202020202020202020202020206B6579446563203D206B';
wwv_flow_api.g_varchar2_table(109) := '6579732E4C4546543B0A202020202020202020202020202020207D0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206C656674203D20303B0A20202020202020202020202020202020746F70203D20746869';
wwv_flow_api.g_varchar2_table(110) := '732E626172242E706F736974696F6E28295B706F735D3B0A20202020202020202020202020202020637572736F72203D2022732D726573697A65223B0A2020202020202020202020202020202069662028746869732E66726F6D456E6429207B0A202020';
wwv_flow_api.g_varchar2_table(111) := '20202020202020202020202020202020206B6579496E63203D206B6579732E55503B0A20202020202020202020202020202020202020206B6579446563203D206B6579732E444F574E3B0A202020202020202020202020202020207D20656C7365207B0A';
wwv_flow_api.g_varchar2_table(112) := '20202020202020202020202020202020202020206B6579496E63203D206B6579732E444F574E3B0A20202020202020202020202020202020202020206B6579446563203D206B6579732E55503B0A202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(113) := '20202020202020207D0A0A202020202020202020202020746869732E626172242E637373287B0A202020202020202020202020202020206C6566743A206C6566742C0A20202020202020202020202020202020746F703A20746F700A2020202020202020';
wwv_flow_api.g_varchar2_table(114) := '202020207D292E647261676761626C65287B0A20202020202020202020202020202020617869733A2073656C662E686F72697A203F20227822203A202279222C0A20202020202020202020202020202020636F6E7461696E6D656E743A2022706172656E';
wwv_flow_api.g_varchar2_table(115) := '74222C0A2020202020202020202020202020202063616E63656C3A2053454C5F425554544F4E2C0A20202020202020202020202020202020637572736F723A20637572736F722C0A20202020202020202020202020202020696672616D654669783A206F';
wwv_flow_api.g_varchar2_table(116) := '2E696672616D654669782C0A20202020202020202020202020202020677269643A20677269642C0A202020202020202020202020202020207363726F6C6C3A2066616C73652C0A20202020202020202020202020202020647261673A2066756E6374696F';
wwv_flow_api.g_varchar2_table(117) := '6E2028652C20756929207B0A202020202020202020202020202020202020202076617220703B0A2020202020202020202020202020202020202020696620286F2E7265616C54696D6529207B0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(118) := '2070203D2075692E706F736974696F6E5B706F735D3B0A2020202020202020202020202020202020202020202020206966202873656C662E66726F6D456E6429207B0A2020202020202020202020202020202020202020202020202020202070203D2028';
wwv_flow_api.g_varchar2_table(119) := '73656C662E686F72697A203F206374726C242E77696474682829203A206374726C242E686569676874282929202D2070202D2073656C662E62617253697A653B0A2020202020202020202020202020202020202020202020207D0A202020202020202020';
wwv_flow_api.g_varchar2_table(120) := '20202020202020202020202020202073656C662E5F736574506F7328702C2066616C7365293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D2C0A2020202020202020202020202020202073746172';
wwv_flow_api.g_varchar2_table(121) := '743A2066756E6374696F6E2028652C20756929207B0A202020202020202020202020202020202020202073656C662E626172242E616464436C61737328435F414354495645293B0A202020202020202020202020202020207D2C0A202020202020202020';
wwv_flow_api.g_varchar2_table(122) := '2020202020202073746F703A2066756E6374696F6E2028652C20756929207B0A20202020202020202020202020202020202020207661722070203D2075692E706F736974696F6E5B706F735D3B0A0A202020202020202020202020202020202020202073';
wwv_flow_api.g_varchar2_table(123) := '656C662E626172242E72656D6F7665436C61737328435F414354495645293B0A20202020202020202020202020202020202020206966202873656C662E66726F6D456E6429207B0A20202020202020202020202020202020202020202020202070203D20';
wwv_flow_api.g_varchar2_table(124) := '2873656C662E686F72697A203F206374726C242E77696474682829203A206374726C242E686569676874282929202D2070202D2073656C662E62617253697A653B0A20202020202020202020202020202020202020207D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(125) := '202020202020202073656C662E5F736574506F7328702C2066616C7365293B0A202020202020202020202020202020207D0A2020202020202020202020207D292E636C69636B2866756E6374696F6E202829207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(126) := '20242874686973292E66696E642853454C5F5448554D42292E666F63757328293B0A2020202020202020202020207D292E66696E642853454C5F425554544F4E292E636C69636B2866756E6374696F6E202829207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(127) := '202073656C662E5F736574506F732873656C662E5F676574506F7328292C202173656C662E5F6973436F6C6C61707365642829293B0A2020202020202020202020207D293B0A202020202020202020202020617065782E7769646765742E7574696C2E54';
wwv_flow_api.g_varchar2_table(128) := '6F75636850726F78792E616464546F7563684C697374656E65727328746869732E626172245B305D293B0A202020202020202020202020746869732E626172242E66696E642853454C5F5448554D42292E666F6375732866756E6374696F6E202829207B';
wwv_flow_api.g_varchar2_table(129) := '0A20202020202020202020202020202020242874686973292E706172656E7428292E616464436C61737328435F464F4355534544202B20222022202B20435F414354495645293B0A2020202020202020202020207D292E626C75722866756E6374696F6E';
wwv_flow_api.g_varchar2_table(130) := '202829207B0A20202020202020202020202020202020242874686973292E706172656E7428292E72656D6F7665436C61737328435F464F4355534544202B20222022202B20435F414354495645293B0A2020202020202020202020207D292E6B6579646F';
wwv_flow_api.g_varchar2_table(131) := '776E2866756E6374696F6E20286529207B0A20202020202020202020202020202020766172206D61782C2070312C0A20202020202020202020202020202020202020206B63203D20652E6B6579436F64652C0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(132) := '20202070203D206E756C6C2C0A2020202020202020202020202020202020202020636F6C6C6170736564203D2066616C73653B0A0A20202020202020202020202020202020696620286B63203D3D3D206B657944656320262620216F2E636F6C6C617073';
wwv_flow_api.g_varchar2_table(133) := '656429207B0A202020202020202020202020202020202020202070203D2073656C662E5F676574506F7328293B0A202020202020202020202020202020202020202070202D3D206F2E696E633B0A20202020202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(134) := '202870203C206F2E6D696E53697A65202626206F2E6E6F436F6C6C6170736529207B0A20202020202020202020202020202020202020202020202070203D206F2E6D696E53697A653B0A20202020202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(135) := '202020202020202020202020202020206966202870203C203029207B0A20202020202020202020202020202020202020202020202070203D20303B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D20';
wwv_flow_api.g_varchar2_table(136) := '656C736520696620286B63203D3D3D206B6579496E6329207B0A202020202020202020202020202020202020202070203D2073656C662E5F676574506F7328293B0A20202020202020202020202020202020202020206966202870203C203029207B0A20';
wwv_flow_api.g_varchar2_table(137) := '202020202020202020202020202020202020202020202069662028216F2E6E6F436F6C6C6170736529207B0A20202020202020202020202020202020202020202020202020202020636F6C6C6170736564203D20747275653B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(138) := '20202020202020202020202020207D0A20202020202020202020202020202020202020202020202070203D20303B0A20202020202020202020202020202020202020207D20656C7365207B0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(139) := '70202B3D206F2E696E633B0A20202020202020202020202020202020202020207D0A20202020202020202020202020202020202020206D6178203D2073656C662E5F6765744D6178506F7328293B0A202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(140) := '66202870203E206D617829207B0A20202020202020202020202020202020202020202020202070203D206D61783B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(141) := '202020696620287020213D3D206E756C6C29207B0A20202020202020202020202020202020202020207031203D20703B0A20202020202020202020202020202020202020206966202873656C662E66726F6D456E6429207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(142) := '202020202020202020202020207031203D202873656C662E686F72697A203F206374726C242E77696474682829203A206374726C242E686569676874282929202D207031202D2073656C662E62617253697A653B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(143) := '20202020207D0A202020202020202020202020202020202020202073656C662E626172242E63737328706F732C207031293B0A20202020202020202020202020202020202020206966202874696D6572496429207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(144) := '20202020202020202020636C65617254696D656F75742874696D65724964293B0A20202020202020202020202020202020202020202020202074696D65724964203D206E756C6C3B0A20202020202020202020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(145) := '20202020202020202020202020202074696D65724964203D2073657454696D656F75742866756E6374696F6E202829207B0A20202020202020202020202020202020202020202020202074696D65724964203D206E756C6C3B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(146) := '202020202020202020202020202073656C662E5F736574506F7328702C20636F6C6C6170736564293B0A20202020202020202020202020202020202020207D2C20313030293B0A202020202020202020202020202020202020202072657475726E206661';
wwv_flow_api.g_varchar2_table(147) := '6C73653B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A0A202020202020202020202020746869732E5F6F6E28747275652C20746869732E5F6576656E7448616E646C657273293B202F2F207375707072657373';
wwv_flow_api.g_varchar2_table(148) := '2064697361626C6520636865636B0A0A202020202020202020202020696620286F2E64697361626C656429207B0A20202020202020202020202020202020746869732E5F7365744F7074696F6E282264697361626C6564222C206F2E64697361626C6564';
wwv_flow_api.g_varchar2_table(149) := '293B0A2020202020202020202020207D0A202020202020202020202020746869732E7265667265736828293B0A20202020202020207D2C0A0A20202020202020205F726573697A653A2066756E6374696F6E20286576656E7429207B0A20202020202020';
wwv_flow_api.g_varchar2_table(150) := '202020202076617220682C20772C20626F756E64732C206F66667365742C0A202020202020202020202020202020206F203D20746869732E6F7074696F6E732C0A202020202020202020202020202020206374726C24203D20746869732E656C656D656E';
wwv_flow_api.g_varchar2_table(151) := '743B0A0A202020202020202020202020696620286576656E74202626206576656E742E74617267657420213D3D206374726C245B305D29207B0A2020202020202020202020202020202072657475726E3B0A2020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(152) := '202020202020202068203D206374726C242E68656967687428293B0A20202020202020202020202077203D206374726C242E776964746828293B0A2020202020202020202020206966202868203D3D3D2030207C7C2077203D3D3D203029207B0A202020';
wwv_flow_api.g_varchar2_table(153) := '202020202020202020202020206F2E6E65656473526573697A65203D20747275653B0A2020202020202020202020202020202072657475726E3B0A202020202020202020202020202020202F2F7468726F77206E6577204572726F72282253706C697474';
wwv_flow_api.g_varchar2_table(154) := '6572206E6565647320746F20626520696E206120636F6D706F6E656E7420776974682073697A6522293B0A2020202020202020202020207D0A0A2020202020202020202020206F6666736574203D206374726C242E6F666673657428293B0A2020202020';
wwv_flow_api.g_varchar2_table(155) := '2020202020202069662028746869732E686F72697A29207B0A202020202020202020202020202020206374726C242E6368696C6472656E28292E656163682866756E6374696F6E202829207B0A2020202020202020202020202020202020202020757469';
wwv_flow_api.g_varchar2_table(156) := '6C2E7365744F7574657248656967687428242874686973292C2068293B0A202020202020202020202020202020207D293B0A2020202020202020202020202020202069662028746869732E66726F6D456E6429207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(157) := '202020202020626F756E6473203D205B6F66667365742E6C656674202B206F2E6D696E53697A652C206F66667365742E746F702C206F66667365742E6C656674202B2077202D20746869732E62617253697A652C206F66667365742E746F70202B20685D';
wwv_flow_api.g_varchar2_table(158) := '3B0A202020202020202020202020202020202020202069662028216F2E64726167436F6C6C61707365207C7C206F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020202020202020202020626F756E64735B325D202D3D206F2E';
wwv_flow_api.g_varchar2_table(159) := '6D696E53697A653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020626F756E6473203D205B6F66667365742E6C6566742C206F';
wwv_flow_api.g_varchar2_table(160) := '66667365742E746F702C206F66667365742E6C656674202B2077202D20746869732E62617253697A65202D206F2E6D696E53697A652C206F66667365742E746F70202B20685D3B0A202020202020202020202020202020202020202069662028216F2E64';
wwv_flow_api.g_varchar2_table(161) := '726167436F6C6C61707365207C7C206F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020202020202020202020626F756E64735B305D202B3D206F2E6D696E53697A65202B20313B0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(162) := '2020207D0A202020202020202020202020202020207D0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206374726C242E6368696C6472656E28292E656163682866756E6374696F6E202829207B0A20202020';
wwv_flow_api.g_varchar2_table(163) := '202020202020202020202020202020207574696C2E7365744F75746572576964746828242874686973292C2077293B0A202020202020202020202020202020207D293B0A2020202020202020202020202020202069662028746869732E66726F6D456E64';
wwv_flow_api.g_varchar2_table(164) := '29207B0A2020202020202020202020202020202020202020626F756E6473203D205B6F66667365742E6C6566742C206F66667365742E746F70202B206F2E6D696E53697A652C206F66667365742E6C656674202B20772C206F66667365742E746F70202B';
wwv_flow_api.g_varchar2_table(165) := '2068202D20746869732E62617253697A655D3B0A202020202020202020202020202020202020202069662028216F2E64726167436F6C6C61707365207C7C206F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(166) := '202020626F756E64735B335D202D3D206F2E6D696E53697A653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020626F756E6473';
wwv_flow_api.g_varchar2_table(167) := '203D205B6F66667365742E6C6566742C206F66667365742E746F702C206F66667365742E6C656674202B20772C206F66667365742E746F70202B2068202D20746869732E62617253697A65202D206F2E6D696E53697A655D3B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(168) := '2020202020202020202069662028216F2E64726167436F6C6C61707365207C7C206F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020202020202020202020626F756E64735B315D202B3D206F2E6D696E53697A65202B20313B';
wwv_flow_api.g_varchar2_table(169) := '0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D0A202020202020202020202020746869732E5F736574506F73286F2E706F736974696F6E2C206F2E636F6C6C6170';
wwv_flow_api.g_varchar2_table(170) := '736564293B0A202020202020202020202020746869732E626172242E647261676761626C6528226F7074696F6E222C2022636F6E7461696E6D656E74222C20626F756E6473293B0A2020202020202020202020206374726C242E6368696C6472656E2822';
wwv_flow_api.g_varchar2_table(171) := '2E726573697A6522292E66696C74657228223A76697369626C6522292E747269676765722822726573697A6522293B0A202020202020202020202020696620286576656E7429206576656E742E73746F7050726F7061676174696F6E28293B0A20202020';
wwv_flow_api.g_varchar2_table(172) := '202020207D2C0A0A20202020202020205F64657374726F793A2066756E6374696F6E202829207B0A202020202020202020202020746869732E656C656D656E742E72656D6F7665436C61737328435F53504C4954544552202B20222022202B20435F4449';
wwv_flow_api.g_varchar2_table(173) := '5341424C4544202B20222022202B20435F52544C202B202220726573697A6522290A202020202020202020202020202020202E6368696C6472656E2853454C5F424152292E72656D6F766528293B0A202020202020202020202020746869732E656C656D';
wwv_flow_api.g_varchar2_table(174) := '656E742E6368696C6472656E28292E6373732822706F736974696F6E222C202222293B0A20202020202020207D2C0A0A2020202020202020726566726573683A2066756E6374696F6E202829207B0A20202020202020202020202069662028746869732E';
wwv_flow_api.g_varchar2_table(175) := '656C656D656E742E697328223A76697369626C65222929207B0A20202020202020202020202020202020746869732E656C656D656E742E747269676765722822726573697A6522293B0A2020202020202020202020207D0A20202020202020207D2C0A0A';
wwv_flow_api.g_varchar2_table(176) := '20202020202020205F7365744F7074696F6E3A2066756E6374696F6E20286B65792C2076616C756529207B0A20202020202020202020202076617220677269642C206D696E4C696D69742C207468756D62243B0A0A202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(177) := '28746869732E6F7074696F6E732E6E6F436F6C6C6170736520262620286B6579203D3D3D2022636F6C6C617073656422207C7C206B6579203D3D3D2022726573746F72655465787422207C7C206B6579203D3D3D2022636F6C6C61707365546578742229';
wwv_flow_api.g_varchar2_table(178) := '29207B0A2020202020202020202020202020202064656275672E7761726E282253657474696E672022202B206B6579202B2022206F7074696F6E206F6E206E6F436F6C6C617073652073706C697474657220686173206E6F206566666563742E22293B0A';
wwv_flow_api.g_varchar2_table(179) := '2020202020202020202020202020202072657475726E3B0A2020202020202020202020207D0A0A202020202020202020202020696620286B6579203D3D3D20226F7269656E746174696F6E22207C7C206B6579203D3D3D2022706F736974696F6E656446';
wwv_flow_api.g_varchar2_table(180) := '726F6D22207C7C206B6579203D3D3D20226E6F436F6C6C617073652229207B0A202020202020202020202020202020202F2F2074686573652063616E2774206265206368616E676564206F6E636520696E697469616C697A65640A202020202020202020';
wwv_flow_api.g_varchar2_table(181) := '202020202020207468726F77206E6577204572726F722822526561646F6E6C79206F7074696F6E3A2022202B206B6579293B0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022706F736974696F6E2229207B0A20202020';
wwv_flow_api.g_varchar2_table(182) := '2020202020202020202020202F2F206D616B6520737572652076616C75652069732061206E756D6265720A20202020202020202020202020202020746869732E5F736574506F732876616C7565202A20312C20746869732E5F6973436F6C6C6170736564';
wwv_flow_api.g_varchar2_table(183) := '2829293B0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022636F6C6C61707365642229207B0A202020202020202020202020202020202F2F206D616B6520737572652076616C756520697320626F6F6C65616E0A202020';
wwv_flow_api.g_varchar2_table(184) := '20202020202020202020202020746869732E5F736574506F7328746869732E5F676574506F7328292C20212176616C7565293B0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022736E61702229207B0A20202020202020';
wwv_flow_api.g_varchar2_table(185) := '2020202020202020202F2F206D616B6520737572652076616C75652069732061206E756D626572206966206E6F742066616C73650A2020202020202020202020202020202076616C7565203D2076616C7565203F2076616C7565202A2031203A2066616C';
wwv_flow_api.g_varchar2_table(186) := '73653B0A20202020202020202020202020202020746869732E6F7074696F6E732E736E6170203D2076616C75653B0A2020202020202020202020202020202067726964203D2076616C7565203F205B76616C75652C2076616C75655D203A2066616C7365';
wwv_flow_api.g_varchar2_table(187) := '3B0A20202020202020202020202020202020746869732E626172242E647261676761626C6528226F7074696F6E222C202267726964222C2067726964293B0A202020202020202020202020202020206966202876616C756529207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(188) := '202020202020202020202020746869732E6F7074696F6E732E696E63203D2076616C75653B0A202020202020202020202020202020207D0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022696E632229207B0A20202020';
wwv_flow_api.g_varchar2_table(189) := '20202020202020202020202076616C7565203D2076616C7565202A20313B0A2020202020202020202020202020202069662028746869732E6F7074696F6E732E736E617029207B0A202020202020202020202020202020202020202076616C7565203D20';
wwv_flow_api.g_varchar2_table(190) := '746869732E6F7074696F6E732E736E61703B0A202020202020202020202020202020207D0A20202020202020202020202020202020746869732E6F7074696F6E732E696E63203D2076616C75653B0A2020202020202020202020207D20656C7365206966';
wwv_flow_api.g_varchar2_table(191) := '20286B6579203D3D3D202264697361626C65642229207B0A20202020202020202020202020202020746869732E6F7074696F6E732E64697361626C6564203D2076616C75653B0A202020202020202020202020202020207468756D6224203D2074686973';
wwv_flow_api.g_varchar2_table(192) := '2E626172242E66696E642853454C5F5448554D42293B0A202020202020202020202020202020206966202821746869732E6F7074696F6E732E6E6F436F6C6C6170736529207B0A20202020202020202020202020202020202020202F2F2064697361626C';
wwv_flow_api.g_varchar2_table(193) := '652074686520627574746F6E20616E642061646A7573742074686520746F6F6C7469700A20202020202020202020202020202020202020207468756D62245B305D2E64697361626C6564203D2076616C75653B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(194) := '202020206966202876616C756529207B0A2020202020202020202020202020202020202020202020207468756D62242E61747472285449544C452C20746869732E6F7074696F6E732E7469746C65293B0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(195) := '207D20656C7365207B0A2020202020202020202020202020202020202020202020207468756D62242E61747472285449544C452C20746869732E6F7074696F6E732E636F6C6C6170736564203F20746869732E6F7074696F6E732E726573746F72655465';
wwv_flow_api.g_varchar2_table(196) := '7874203A20746869732E6F7074696F6E732E636F6C6C6170736554657874293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(197) := '6966202876616C756529207B0A2020202020202020202020202020202020202020202020207468756D62242E72656D6F7665417474722822746162696E64657822293B0A20202020202020202020202020202020202020207D20656C7365207B0A202020';
wwv_flow_api.g_varchar2_table(198) := '2020202020202020202020202020202020202020207468756D62242E617474722822746162696E646578222C20223022293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A202020202020202020';
wwv_flow_api.g_varchar2_table(199) := '20202020202020746869732E626172242E647261676761626C6528226F7074696F6E222C202264697361626C6564222C2076616C7565293B0A202020202020202020202020202020206966202876616C756529207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(200) := '202020202020746869732E656C656D656E742E616464436C61737328435F44495341424C4544293B0A2020202020202020202020202020202020202020746869732E626172242E616464436C61737328435F44495341424C4544293B0A20202020202020';
wwv_flow_api.g_varchar2_table(201) := '202020202020202020202020207468756D62242E617474722822617269612D64697361626C6564222C2074727565293B0A202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020207468756D6224';
wwv_flow_api.g_varchar2_table(202) := '2E72656D6F7665417474722822617269612D64697361626C656422293B0A2020202020202020202020202020202020202020746869732E626172242E72656D6F7665436C61737328435F44495341424C4544293B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(203) := '2020202020746869732E656C656D656E742E72656D6F7665436C61737328435F44495341424C4544293B0A202020202020202020202020202020207D0A2020202020202020202020207D20656C736520696620286B6579203D3D3D20226D696E53697A65';
wwv_flow_api.g_varchar2_table(204) := '2229207B0A202020202020202020202020202020206D696E4C696D6974203D20746869732E6F7074696F6E732E6E6F436F6C6C61707365203F2030203A20313B0A202020202020202020202020202020206966202876616C7565203C206D696E4C696D69';
wwv_flow_api.g_varchar2_table(205) := '7429207B0A202020202020202020202020202020202020202076616C7565203D206D696E4C696D69743B0A202020202020202020202020202020202020202064656275672E7761726E28224F7074696F6E206D696E53697A652061646A75737465642229';
wwv_flow_api.g_varchar2_table(206) := '3B0A202020202020202020202020202020207D0A20202020202020202020202020202020746869732E6F7074696F6E732E6D696E53697A65203D2076616C75653B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(207) := '202020242E5769646765742E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C20617267756D656E7473293B0A2020202020202020202020207D0A202020202020202020202020696620286B6579203D3D3D20227469746C';
wwv_flow_api.g_varchar2_table(208) := '652229207B0A20202020202020202020202020202020746869732E626172242E61747472285449544C452C2076616C7565293B0A2020202020202020202020202020202069662028746869732E6F7074696F6E732E6E6F436F6C6C61707365207C7C2074';

wwv_flow_api.g_varchar2_table(209) := '6869732E6F7074696F6E732E64697361626C656429207B0A2020202020202020202020202020202020202020746869732E626172242E66696E642853454C5F5448554D42292E61747472285449544C452C2076616C7565293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(210) := '2020202020207D0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022726573746F7265546578742220262620746869732E6F7074696F6E732E636F6C6C61707365642026262021746869732E6F7074696F6E732E64697361';
wwv_flow_api.g_varchar2_table(211) := '626C656429207B0A20202020202020202020202020202020746869732E626172242E66696E642853454C5F425554544F4E292E61747472285449544C452C2076616C7565293B0A2020202020202020202020207D20656C736520696620286B6579203D3D';
wwv_flow_api.g_varchar2_table(212) := '3D2022636F6C6C6170736554657874222026262021746869732E6F7074696F6E732E636F6C6C61707365642026262021746869732E6F7074696F6E732E64697361626C656429207B0A20202020202020202020202020202020746869732E626172242E66';
wwv_flow_api.g_varchar2_table(213) := '696E642853454C5F425554544F4E292E61747472285449544C452C2076616C7565293B0A2020202020202020202020207D20656C736520696620286B6579203D3D3D2022696672616D654669782229207B0A202020202020202020202020202020207468';
wwv_flow_api.g_varchar2_table(214) := '69732E626172242E647261676761626C6528226F7074696F6E222C2022696672616D65466978222C2076616C7565293B0A2020202020202020202020207D20656C736520696620286B6579203D3D3D202264726167436F6C6C617073652229207B0A2020';
wwv_flow_api.g_varchar2_table(215) := '2020202020202020202020202020746869732E7265667265736828293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020205F6576656E7448616E646C6572733A207B0A202020202020202020202020726573697A65';
wwv_flow_api.g_varchar2_table(216) := '3A2066756E6374696F6E20286576656E7429207B0A20202020202020202020202020202020746869732E5F726573697A65286576656E74293B0A2020202020202020202020207D0A20202020202020207D2C0A0A0A20202020202020205F72656E646572';
wwv_flow_api.g_varchar2_table(217) := '4261723A2066756E6374696F6E20286F757429207B0A202020202020202020202020766172206F203D20746869732E6F7074696F6E732C0A20202020202020202020202020202020626172436C617373203D20746869732E686F72697A203F20435F5350';
wwv_flow_api.g_varchar2_table(218) := '4C49545445525F48203A20435F53504C49545445525F563B0A0A20202020202020202020202069662028746869732E66726F6D456E6429207B0A20202020202020202020202020202020626172436C617373202B3D20222022202B20435F53504C495454';
wwv_flow_api.g_varchar2_table(219) := '45525F454E443B0A2020202020202020202020207D0A202020202020202020202020696620286F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020206F2E636F6C6C6170736564203D2066616C73653B0A202020202020202020';
wwv_flow_api.g_varchar2_table(220) := '2020207D0A202020202020202020202020696620286F2E636F6C6C617073656429207B0A20202020202020202020202020202020626172436C617373202B3D20222022202B20435F434F4C4C41505345443B0A2020202020202020202020207D0A0A2020';
wwv_flow_api.g_varchar2_table(221) := '202020202020202020206F75742E6D61726B757028223C64697622292E617474722822636C617373222C20626172436C617373290A202020202020202020202020202020202E6F7074696F6E616C41747472285449544C452C206F2E7469746C65290A20';
wwv_flow_api.g_varchar2_table(222) := '2020202020202020202020202020202E6D61726B757028223E3C6469763E3C2F6469763E22293B0A202020202020202020202020696620286F2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020206F75742E6D61726B75702822';
wwv_flow_api.g_varchar2_table(223) := '3C7370616E20726F6C653D27736570617261746F722720636C6173733D2722202B20435F5448554D42202B20222720746162696E6465783D27302720617269612D657870616E6465643D27747275652722290A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(224) := '2020202E6F7074696F6E616C41747472285449544C452C206F2E7469746C6529202F2F206475706C6963617465207469746C6520666F72207468652062656E65666974206F66204A4157530A20202020202020202020202020202020202020202F2F2054';
wwv_flow_api.g_varchar2_table(225) := '68697320636175736573204A41575320746F206769766520657874726120696E737472756374696F6E73207468617420617265206E6F742075736566756C0A20202020202020202020202020202020202020202F2F20202E61747472282022617269612D';
wwv_flow_api.g_varchar2_table(226) := '636F6E74726F6C73222C20746869732E6265666F7265245B305D2E6964202B20222022202B20746869732E6166746572245B305D2E696420290A20202020202020202020202020202020202020202E6D61726B757028223E3C2F7370616E3E22293B0A20';
wwv_flow_api.g_varchar2_table(227) := '20202020202020202020207D20656C7365207B0A202020202020202020202020202020206F75742E6D61726B757028223C627574746F6E20726F6C653D27736570617261746F722720636C6173733D2722202B20435F5448554D42202B20222720747970';
wwv_flow_api.g_varchar2_table(228) := '653D27627574746F6E2722290A20202020202020202020202020202020202020202E617474722822617269612D657870616E646564222C20216F2E636F6C6C6170736564290A20202020202020202020202020202020202020202E6F7074696F6E616C41';
wwv_flow_api.g_varchar2_table(229) := '747472285449544C452C206F2E636F6C6C6170736564203F206F2E726573746F726554657874203A206F2E636F6C6C6170736554657874290A20202020202020202020202020202020202020202F2F205468697320636175736573204A41575320746F20';
wwv_flow_api.g_varchar2_table(230) := '6769766520657874726120696E737472756374696F6E73207468617420617265206E6F742075736566756C0A20202020202020202020202020202020202020202F2F202E61747472282022617269612D636F6E74726F6C73222C20746869732E6265666F';
wwv_flow_api.g_varchar2_table(231) := '7265245B305D2E6964202B20222022202B20746869732E6166746572245B305D2E696420290A20202020202020202020202020202020202020202E6D61726B757028223E3C2F627574746F6E3E22293B0A2020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(232) := '202020202020206F75742E6D61726B757028223C2F6469763E22293B0A20202020202020207D2C0A0A20202020202020205F676574506F733A2066756E6374696F6E202829207B0A202020202020202020202020766172206374726C24203D2074686973';
wwv_flow_api.g_varchar2_table(233) := '2E656C656D656E742C0A20202020202020202020202020202020706F73203D20746869732E686F72697A203F20226C65667422203A2022746F70222C0A2020202020202020202020202020202070203D20746869732E626172242E706F736974696F6E28';
wwv_flow_api.g_varchar2_table(234) := '295B706F735D3B0A0A20202020202020202020202069662028746869732E66726F6D456E6429207B0A2020202020202020202020202020202070203D2028746869732E686F72697A203F206374726C242E77696474682829203A206374726C242E686569';
wwv_flow_api.g_varchar2_table(235) := '676874282929202D2070202D20746869732E62617253697A653B0A2020202020202020202020207D0A20202020202020202020202072657475726E20703B0A20202020202020207D2C0A0A20202020202020205F6973436F6C6C61707365643A2066756E';
wwv_flow_api.g_varchar2_table(236) := '6374696F6E202829207B0A20202020202020202020202072657475726E20746869732E626172242E686173436C61737328435F434F4C4C4150534544293B0A20202020202020207D2C0A0A20202020202020205F6765744D6178506F733A2066756E6374';
wwv_flow_api.g_varchar2_table(237) := '696F6E202829207B0A202020202020202020202020766172206F203D20746869732E6F7074696F6E732C0A202020202020202020202020202020206374726C24203D20746869732E656C656D656E743B0A0A202020202020202020202020696620287468';
wwv_flow_api.g_varchar2_table(238) := '69732E686F72697A29207B0A2020202020202020202020202020202072657475726E206374726C242E77696474682829202D20746869732E62617253697A65202D206F2E6D696E53697A653B0A2020202020202020202020207D202F2F20656C73650A20';
wwv_flow_api.g_varchar2_table(239) := '202020202020202020202072657475726E206374726C242E6865696768742829202D20746869732E62617253697A65202D206F2E6D696E53697A653B0A20202020202020207D2C0A0A20202020202020205F736574506F733A2066756E6374696F6E2028';
wwv_flow_api.g_varchar2_table(240) := '706F736974696F6E2C20636F6C6C617073656429207B0A202020202020202020202020766172206D61782C20746F74616C2C206368696C64242C206368696C6453697A652C20702C207468756D62242C0A202020202020202020202020202020206F203D';
wwv_flow_api.g_varchar2_table(241) := '20746869732E6F7074696F6E732C0A202020202020202020202020202020206374726C24203D20746869732E656C656D656E742C0A20202020202020202020202020202020706F73203D20746869732E686F72697A203F20226C65667422203A2022746F';
wwv_flow_api.g_varchar2_table(242) := '70222C0A20202020202020202020202020202020637572436F6C6C6170736564203D20746869732E5F6973436F6C6C617073656428292C0A20202020202020202020202020202020637572506F73203D20746869732E6C617374506F733B0A0A20202020';
wwv_flow_api.g_varchar2_table(243) := '2020202020202020696620286F2E6E6F436F6C6C6170736529207B0A20202020202020202020202020202020636F6C6C6170736564203D2066616C73653B202F2F2063616E27742062652074727565207768656E206E6F436F6C6C617073650A20202020';
wwv_flow_api.g_varchar2_table(244) := '20202020202020207D0A0A20202020202020202020202069662028637572436F6C6C61707365642026262021636F6C6C617073656429207B0A20202020202020202020202020202020706F736974696F6E203D20746869732E6C617374506F733B0A2020';
wwv_flow_api.g_varchar2_table(245) := '202020202020202020202020202069662028706F736974696F6E203C206F2E6D696E53697A6529207B0A2020202020202020202020202020202020202020706F736974696F6E203D206F2E6D696E53697A653B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(246) := '7D0A2020202020202020202020207D0A20202020202020202020202069662028706F736974696F6E203C206F2E6D696E53697A6529207B0A20202020202020202020202020202020696620286F2E6E6F436F6C6C6170736529207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(247) := '202020202020202020202020706F736974696F6E203D206F2E6D696E53697A653B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020636F6C6C6170736564203D20747275653B0A202020';
wwv_flow_api.g_varchar2_table(248) := '202020202020202020202020207D0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206D6178203D20746869732E5F6765744D6178506F7328293B0A2020202020202020202020202020202069662028706F73';
wwv_flow_api.g_varchar2_table(249) := '6974696F6E203E206D617829207B0A2020202020202020202020202020202020202020706F736974696F6E203D206D61783B0A202020202020202020202020202020207D0A2020202020202020202020207D0A202020202020202020202020696620286F';
wwv_flow_api.g_varchar2_table(250) := '2E6E6F436F6C6C6170736520262620706F736974696F6E203C3D203029207B0A20202020202020202020202020202020706F736974696F6E203D20303B0A2020202020202020202020207D0A20202020202020202020202069662028706F736974696F6E';
wwv_flow_api.g_varchar2_table(251) := '203E203029207B0A20202020202020202020202020202020746869732E6C617374506F73203D20706F736974696F6E3B0A2020202020202020202020207D0A20202020202020202020202069662028636F6C6C617073656429207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(252) := '2020202020202020706F736974696F6E203D20303B0A202020202020202020202020202020206F2E706F736974696F6E203D20303B0A2020202020202020202020207D0A202020202020202020202020746F74616C203D20746869732E686F72697A203F';
wwv_flow_api.g_varchar2_table(253) := '206374726C242E77696474682829203A206374726C242E68656967687428293B0A20202020202020202020202070203D20706F736974696F6E3B0A20202020202020202020202069662028746869732E66726F6D456E6429207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(254) := '2020202020202070203D20746F74616C202D20706F736974696F6E202D20746869732E62617253697A653B0A2020202020202020202020207D0A202020202020202020202020746869732E626172242E63737328706F732C2070293B0A20202020202020';
wwv_flow_api.g_varchar2_table(255) := '20202020207468756D6224203D20746869732E626172242E66696E642853454C5F5448554D42293B0A0A20202020202020202020202069662028746869732E66726F6D456E6429207B0A202020202020202020202020202020206368696C6424203D2074';
wwv_flow_api.g_varchar2_table(256) := '6869732E6166746572243B0A202020202020202020202020202020206368696C6453697A65203D20746F74616C202D2070202D20746869732E62617253697A653B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(257) := '2020206368696C6424203D20746869732E6265666F7265243B0A202020202020202020202020202020206368696C6453697A65203D20703B0A2020202020202020202020207D0A2020202020202020202020206966202821636F6C6C617073656429207B';
wwv_flow_api.g_varchar2_table(258) := '0A20202020202020202020202020202020696620286F2E6E6F436F6C6C6170736529207B0A20202020202020202020202020202020202020202F2F2061206E6F436F6C6C617073652073706C69747465722077697468206D696E53697A6520302063616E';
wwv_flow_api.g_varchar2_table(259) := '2068617665206F6E65206F7220746865206F74686572206368696C6472656E20636F6D706C6574656C7920636C6F7365640A20202020202020202020202020202020202020202F2F20627574206974206973206E6F7420636F6E73696465726564202263';
wwv_flow_api.g_varchar2_table(260) := '6F6C6C6170736564222E0A20202020202020202020202020202020202020202F2F20686964652069662069742074616B6573207570206E6F2073706163652C2073686F77206F74686572776973650A202020202020202020202020202020202020202063';
wwv_flow_api.g_varchar2_table(261) := '68696C64242E746F67676C6528706F736974696F6E20213D3D2030293B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020746869732E626172242E72656D6F7665436C61737328435F43';
wwv_flow_api.g_varchar2_table(262) := '4F4C4C4150534544293B0A202020202020202020202020202020202020202069662028216F2E6E6F436F6C6C6170736520262620216F2E64697361626C656429207B0A2020202020202020202020202020202020202020202020207468756D62242E6174';
wwv_flow_api.g_varchar2_table(263) := '74722822617269612D657870616E646564222C2074727565292E61747472285449544C452C206F2E636F6C6C6170736554657874293B0A20202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020636869';
wwv_flow_api.g_varchar2_table(264) := '6C64242E73686F7728293B0A202020202020202020202020202020207D0A2020202020202020202020202020202069662028746869732E686F72697A29207B0A20202020202020202020202020202020202020207574696C2E7365744F75746572576964';
wwv_flow_api.g_varchar2_table(265) := '7468286368696C64242C206368696C6453697A65293B0A202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020207574696C2E7365744F75746572486569676874286368696C64242C206368696C';
wwv_flow_api.g_varchar2_table(266) := '6453697A65293B0A202020202020202020202020202020207D0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020746869732E626172242E616464436C61737328435F434F4C4C4150534544293B0A20202020';
wwv_flow_api.g_varchar2_table(267) := '20202020202020202020202069662028216F2E64697361626C656429207B0A20202020202020202020202020202020202020207468756D62242E617474722822617269612D657870616E646564222C2066616C7365292E61747472285449544C452C206F';
wwv_flow_api.g_varchar2_table(268) := '2E726573746F726554657874293B0A202020202020202020202020202020207D0A202020202020202020202020202020206368696C64242E6869646528293B0A2020202020202020202020207D0A20202020202020202020202069662028746869732E66';
wwv_flow_api.g_varchar2_table(269) := '726F6D456E6429207B0A202020202020202020202020202020206368696C6424203D20746869732E6265666F7265243B0A202020202020202020202020202020206368696C6453697A65203D20703B0A2020202020202020202020207D20656C7365207B';
wwv_flow_api.g_varchar2_table(270) := '0A202020202020202020202020202020206368696C6424203D20746869732E6166746572243B0A202020202020202020202020202020206368696C6453697A65203D20746F74616C202D2070202D20746869732E62617253697A653B0A20202020202020';
wwv_flow_api.g_varchar2_table(271) := '20202020207D0A20202020202020202020202069662028746869732E686F72697A29207B0A202020202020202020202020202020207574696C2E7365744F757465725769647468286368696C64242C206368696C6453697A65293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(272) := '202020207D20656C7365207B0A202020202020202020202020202020207574696C2E7365744F75746572486569676874286368696C64242C206368696C6453697A65293B0A2020202020202020202020207D0A202020202020202020202020696620286F';
wwv_flow_api.g_varchar2_table(273) := '2E6E6F436F6C6C6170736529207B0A202020202020202020202020202020206368696C64242E746F67676C65286368696C6453697A6520213D3D2030293B0A2020202020202020202020207D0A0A202020202020202020202020746869732E6166746572';
wwv_flow_api.g_varchar2_table(274) := '242E63737328706F732C202870202B20746869732E62617253697A6529202B2022707822293B0A202020202020202020202020746869732E6265666F7265242E63737328706F732C2030293B202F2F20646F207468697320696E20636173652074686520';
wwv_flow_api.g_varchar2_table(275) := '6469722069732072746C0A2020202020202020202020202F2F20696620616E79206368616E6765730A202020202020202020202020696620282821636F6C6C617073656420262620706F736974696F6E20213D3D20637572506F7329207C7C2063757243';
wwv_flow_api.g_varchar2_table(276) := '6F6C6C617073656420213D3D20636F6C6C617073656429207B0A202020202020202020202020202020206F2E636F6C6C6170736564203D20636F6C6C61707365643B0A202020202020202020202020202020206F2E706F736974696F6E203D20706F7369';
wwv_flow_api.g_varchar2_table(277) := '74696F6E3B0A202020202020202020202020202020202F2F20726573697A650A202020202020202020202020202020206374726C242E6368696C6472656E28222E726573697A6522292E66696C74657228223A76697369626C6522292E74726967676572';
wwv_flow_api.g_varchar2_table(278) := '2822726573697A6522293B0A20202020202020202020202020202020746869732E5F7472696767657228226368616E6765222C207B7D2C207B0A2020202020202020202020202020202020202020706F736974696F6E3A206F2E706F736974696F6E2C0A';
wwv_flow_api.g_varchar2_table(279) := '2020202020202020202020202020202020202020636F6C6C61707365643A206F2E636F6C6C61707365642C0A20202020202020202020202020202020202020206C617374506F736974696F6E3A20746869732E6C617374506F730A202020202020202020';
wwv_flow_api.g_varchar2_table(280) := '202020202020207D293B0A2020202020202020202020207D0A20202020202020207D0A202020207D293B0A0A20202020766172206469616C6F67436F756E74203D20302C0A20202020202020206D656E75436F756E74203D20303B0A0A202020202F2F20';
wwv_flow_api.g_varchar2_table(281) := '22436C61737322206D6574686F640A202020202F2F2054686973206973207479706963616C6C7920626F756E6420746F204374726C2D463620616E6420696620536869667420616C736F2070726573736564207061737320696E207472756520666F7220';
wwv_flow_api.g_varchar2_table(282) := '726576657273650A20202020242E617065782E73706C69747465722E6E65787453706C6974746572203D2066756E6374696F6E20287265766572736529207B0A2020202020202020766172206E657874242C20616C6C42617273242C206375722C0A2020';
wwv_flow_api.g_varchar2_table(283) := '20202020202020202020696E63203D2072657665727365203F202D31203A20312C0A202020202020202020202020666F637573656424203D202428646F63756D656E742E616374697665456C656D656E74293B0A0A202020202020202069662028646961';
wwv_flow_api.g_varchar2_table(284) := '6C6F67436F756E74203E2030207C7C206D656E75436F756E74203E203029207B0A20202020202020202020202072657475726E3B0A20202020202020207D0A2020202020202020616C6C4261727324203D20242853454C5F53504C4954544552202B2022';
wwv_flow_api.g_varchar2_table(285) := '203E2E22202B20435F53504C49545445525F48202B20222C22202B2053454C5F53504C4954544552202B2022203E2E22202B20435F53504C49545445525F56290A2020202020202020202020202E66696C74657228223A76697369626C6522290A202020';
wwv_flow_api.g_varchar2_table(286) := '2020202020202020202E6E6F7428222E75692D73746174652D64697361626C656422290A2020202020202020202020202E61646428666F637573656424293B0A0A2020202020202020637572203D20616C6C42617273242E696E64657828666F63757365';
wwv_flow_api.g_varchar2_table(287) := '6424293B0A202020202020202069662028637572203E3D203029207B0A202020202020202020202020637572202B3D20696E633B0A202020202020202020202020696620287265766572736520262620666F6375736564242E706172656E7428292E6973';
wwv_flow_api.g_varchar2_table(288) := '2853454C5F4241522929207B0A20202020202020202020202020202020637572202B3D20696E633B202F2F20736B6970206F76657220666F63757365640A2020202020202020202020207D0A20202020202020202020202069662028637572203E3D2030';
wwv_flow_api.g_varchar2_table(289) := '20262620637572203C20616C6C42617273242E6C656E67746829207B0A202020202020202020202020202020206E65787424203D20616C6C42617273242E657128637572293B0A2020202020202020202020207D0A20202020202020207D0A0A20202020';
wwv_flow_api.g_varchar2_table(290) := '2020202069662028286E65787424202626206E657874242E6C656E677468203D3D3D20302026262021666F6375736564242E706172656E7428292E69732853454C5F4241522929207C7C20666F6375736564242E6973282268746D6C2C626F6479222929';
wwv_flow_api.g_varchar2_table(291) := '207B0A2020202020202020202020206E65787424203D20242853454C5F53504C4954544552202B2022203E2E22202B20435F53504C49545445525F48202B20222C22202B2053454C5F53504C4954544552202B2022203E2E22202B20435F53504C495454';
wwv_flow_api.g_varchar2_table(292) := '45525F56290A202020202020202020202020202020202E66696C74657228223A76697369626C6522290A202020202020202020202020202020202E6E6F7428222E75692D73746174652D64697361626C656422295B72657665727365203F20226C617374';
wwv_flow_api.g_varchar2_table(293) := '22203A20226669727374225D28293B0A20202020202020207D0A0A2020202020202020696620286E65787424202626206E657874242E6C656E677468203E203029207B0A2020202020202020202020206E657874242E6368696C6472656E2853454C5F54';
wwv_flow_api.g_varchar2_table(294) := '48554D42292E666F63757328293B0A20202020202020202020202072657475726E20747275653B0A20202020202020207D0A202020207D3B0A0A202020202F2F206F6E20646F63756D656E742072656164790A20202020242866756E6374696F6E202829';
wwv_flow_api.g_varchar2_table(295) := '207B0A0A20202020202020202428646F63756D656E742E626F6479292E6F6E28226D656E756265666F72656F70656E222C2066756E6374696F6E2028202F2A6576656E742C2075692A2F29207B0A2020202020202020202020206D656E75436F756E7420';
wwv_flow_api.g_varchar2_table(296) := '2B3D20313B0A20202020202020207D292E6F6E28226D656E756166746572636C6F7365222C2066756E6374696F6E2028202F2A6576656E742C2075692A2F29207B0A2020202020202020202020206D656E75436F756E74202D3D20313B0A202020202020';
wwv_flow_api.g_varchar2_table(297) := '20207D292E6F6E28226469616C6F676F70656E222C2066756E6374696F6E2028202F2A6576656E742C2075692A2F29207B0A2020202020202020202020206469616C6F67436F756E74202B3D20313B0A20202020202020207D292E6F6E28226469616C6F';
wwv_flow_api.g_varchar2_table(298) := '67636C6F7365222C2066756E6374696F6E2028202F2A6576656E742C2075692A2F29207B0A2020202020202020202020206469616C6F67436F756E74202D3D20313B0A20202020202020207D293B0A0A202020207D293B0A0A202020202F2F207768656E';
wwv_flow_api.g_varchar2_table(299) := '20616E206974656D20697320696E20612073706C697474657220746861742063616E20626520636F6C6C617073656420616C6C6F7720746865206D657373616765206D6F64756C6520746F206D616B6520746865206974656D2076697369626C650A2020';
wwv_flow_api.g_varchar2_table(300) := '202069662028617065782E6D65737361676529207B0A2020202020202020617065782E6D6573736167652E6164645669736962696C697479436865636B2866756E6374696F6E2028696429207B0A20202020202020202020202076617220656C24203D20';
wwv_flow_api.g_varchar2_table(301) := '2428222322202B206964293B0A202020202020202020202020656C242E706172656E747328222E612D53706C697474657222292E656163682866756E6374696F6E202829207B0A202020202020202020202020202020202F2F20646F6E2774206B6E6F77';
wwv_flow_api.g_varchar2_table(302) := '20696620746865206974656D206973206F6E2074686520636F6C6C61707369626C652073696465206F72206E6F7420736F206F6E6C7920657870616E64206966206974206973206E6F742076697369626C650A2020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(303) := '66202821656C242E697328223A76697369626C65222929207B0A2020202020202020202020202020202020202020242874686973292E73706C697474657228226F7074696F6E222C2022636F6C6C6170736564222C2066616C7365293B0A202020202020';
wwv_flow_api.g_varchar2_table(304) := '202020202020202020207D0A2020202020202020202020207D293B0A20202020202020207D293B0A202020207D0A0A7D2928617065782E6A51756572792C20617065782E7574696C2C20617065782E6465627567293B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(71507146560761372)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'libraries/widget.splitter.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A210A2053706C6974746572202D2061206A51756572792055492062617365642077696467657420666F722064796E616D6963616C6C79206469766964696E672074686520617661696C61626C6520737061636520666F722074776F20737562207265';
wwv_flow_api.g_varchar2_table(2) := '67696F6E7320686F72697A6F6E74616C6C79206F7220766572746963616C6C792E0A20436F707972696768742028632920323031302C20323031372C204F7261636C6520616E642F6F722069747320616666696C69617465732E20416C6C207269676874';
wwv_flow_api.g_varchar2_table(3) := '732072657365727665642E0A202A2F0A2166756E6374696F6E28692C742C65297B2275736520737472696374223B76617220733D222E612D53706C69747465722D626172482C2E612D53706C69747465722D62617256222C6F3D22612D53706C69747465';
wwv_flow_api.g_varchar2_table(4) := '722D7468756D62222C6E3D222E222B6F2C723D2269732D64697361626C6564222C613D227469746C65223B692E7769646765742822617065782E73706C6974746572222C7B76657273696F6E3A22352E30222C7769646765744576656E74507265666978';
wwv_flow_api.g_varchar2_table(5) := '3A2273706C6974746572222C6F7074696F6E733A7B6F7269656E746174696F6E3A22686F72697A6F6E74616C222C706F736974696F6E656446726F6D3A22626567696E222C6D696E53697A653A36302C706F736974696F6E3A3130302C6E6F436F6C6C61';
wwv_flow_api.g_varchar2_table(6) := '7073653A21312C64726167436F6C6C617073653A21302C636F6C6C61707365643A21312C736E61703A21312C696E633A31302C7265616C54696D653A21312C696672616D654669783A21312C726573746F7265546578743A6E756C6C2C636F6C6C617073';
wwv_flow_api.g_varchar2_table(7) := '65546578743A6E756C6C2C7469746C653A6E756C6C2C6368616E67653A6E756C6C2C6C617A7952656E6465723A21312C6E65656473526573697A653A21312C7669736962696C697479436865636B44656C61793A3330302C696D6D656469617465566973';
wwv_flow_api.g_varchar2_table(8) := '6962696C697479436865636B3A21317D2C6C617374506F733A6E756C6C2C626172243A6E756C6C2C6265666F7265243A6E756C6C2C6166746572243A6E756C6C2C686F72697A3A21302C66726F6D456E643A21312C62617253697A653A312C5F63726561';
wwv_flow_api.g_varchar2_table(9) := '74653A66756E6374696F6E28297B76617220743D746869732C653D742E6F7074696F6E732C733D742E656C656D656E742C6F3D735B305D3B652E6C617A7952656E6465723F28617065782E7769646765742E7574696C2E6F6E5669736962696C69747943';
wwv_flow_api.g_varchar2_table(10) := '68616E6765286F2C2866756E6374696F6E2869297B652E697356697369626C653D692C69262621652E72656E6465726564262628742E5F696E6974436F6D706F6E656E7428292C652E72656E64657265643D2130292C692626652E6E6565647352657369';
wwv_flow_api.g_varchar2_table(11) := '7A65262628742E5F726573697A6528292C652E6E65656473526573697A653D2131297D29292C692877696E646F77292E6F6E2822617065787265616479656E64222C2866756E6374696F6E28297B76617220693D735B305D3B73657454696D656F757428';
wwv_flow_api.g_varchar2_table(12) := '2866756E6374696F6E28297B617065782E7769646765742E7574696C2E7669736962696C6974794368616E676528692C2130297D292C652E7669736962696C697479436865636B44656C61797C7C316533297D29292C652E696D6D656469617465566973';
wwv_flow_api.g_varchar2_table(13) := '6962696C697479436865636B2626617065782E7769646765742E7574696C2E7669736962696C6974794368616E6765286F2C213029293A742E5F696E6974436F6D706F6E656E7428297D2C5F696E6974436F6D706F6E656E743A66756E6374696F6E2829';
wwv_flow_api.g_varchar2_table(14) := '7B76617220732C6F2C722C612C6C2C682C643D746869732C703D746869732E6F7074696F6E732C633D746869732E656C656D656E742C663D742E68746D6C4275696C64657228292C623D692E75692E6B6579436F64652C753D2121702E736E617026265B';
wwv_flow_api.g_varchar2_table(15) := '312A702E736E61702C312A702E736E61705D2C6D3D702E6E6F436F6C6C617073653F303A312C7A3D6E756C6C3B69662832213D3D632E6368696C6472656E28292E6C656E677468297468726F77206E6577204572726F72282253706C6974746572206D75';
wwv_flow_api.g_varchar2_table(16) := '737420686176652065786163746C792074776F206368696C6472656E2E22293B69662822686F72697A6F6E74616C22213D3D702E6F7269656E746174696F6E262622766572746963616C22213D3D702E6F7269656E746174696F6E297468726F77206E65';
wwv_flow_api.g_varchar2_table(17) := '77204572726F7228224F7269656E746174696F6E206261642076616C756522293B69662822626567696E22213D3D702E706F736974696F6E656446726F6D262622656E6422213D3D702E706F736974696F6E656446726F6D297468726F77206E65772045';
wwv_flow_api.g_varchar2_table(18) := '72726F722822506F736974696F6E656446726F6D206261642076616C756522293B696628702E6D696E53697A653C6D262628702E6D696E53697A653D6D2C652E7761726E28224F7074696F6E206D696E53697A652061646A75737465642229292C746869';
wwv_flow_api.g_varchar2_table(19) := '732E686F72697A3D22686F72697A6F6E74616C223D3D3D702E6F7269656E746174696F6E2C746869732E66726F6D456E643D22656E64223D3D3D702E706F736974696F6E656446726F6D2C683D746869732E686F72697A3F226C656674223A22746F7022';
wwv_flow_api.g_varchar2_table(20) := '2C746869732E6265666F7265243D632E6368696C6472656E28292E65712830292C746869732E6166746572243D632E6368696C6472656E28292E65712831292C632E616464436C6173732822612D53706C697474657220726573697A6522292C2272746C';
wwv_flow_api.g_varchar2_table(21) := '223D3D3D632E6373732822646972656374696F6E2229262628632E616464436C6173732822752D52544C22292C746869732E686F72697A262628746869732E6265666F7265243D632E6368696C6472656E28292E65712831292C746869732E6166746572';
wwv_flow_api.g_varchar2_table(22) := '243D632E6368696C6472656E28292E65712830292C746869732E66726F6D456E643D21746869732E66726F6D456E6429292C632E706172656E7428222E612D53706C697474657222292E6C656E6774683E307C7C746869732E6265666F7265242E697328';
wwv_flow_api.g_varchar2_table(23) := '222E612D53706C697474657222297C7C746869732E6166746572242E697328222E612D53706C69747465722229297468726F77206E6577204572726F7228224368696C64206F662073706C69747465722063616E6E6F7420626520612073706C69747465';
wwv_flow_api.g_varchar2_table(24) := '7222293B746869732E6265666F7265245B305D2E69647C7C28746869732E6265666F7265245B305D2E69643D28635B305D2E69647C7C2273706C697474657222292B225F666972737422292C746869732E6166746572245B305D2E69647C7C2874686973';
wwv_flow_api.g_varchar2_table(25) := '2E6166746572245B305D2E69643D28635B305D2E69647C7C2273706C697474657222292B225F7365636F6E6422292C702E706F736974696F6E3C702E6D696E53697A65262628702E706F736974696F6E3D702E6D696E53697A65292C746869732E6C6173';
wwv_flow_api.g_varchar2_table(26) := '74506F733D702E706F736974696F6E2C702E736E6170262628702E696E633D702E736E6170292C746869732E5F72656E6465724261722866292C746869732E626172243D6928662E746F537472696E672829292E696E73657274416674657228632E6368';
wwv_flow_api.g_varchar2_table(27) := '696C6472656E28292E6571283029292C746869732E686F72697A3F746869732E62617253697A653D746869732E626172242E776964746828293A746869732E62617253697A653D746869732E626172242E68656967687428292C632E637373287B706F73';

wwv_flow_api.g_varchar2_table(28) := '6974696F6E3A2272656C6174697665227D292E6368696C6472656E28292E637373287B706F736974696F6E3A226162736F6C757465227D292C746869732E686F72697A3F28733D746869732E626172242E706F736974696F6E28295B685D2C6F3D302C72';
wwv_flow_api.g_varchar2_table(29) := '3D22652D726573697A65222C746869732E66726F6D456E643F28613D622E4C4546542C6C3D622E5249474854293A28613D622E52494748542C6C3D622E4C45465429293A28733D302C6F3D746869732E626172242E706F736974696F6E28295B685D2C72';
wwv_flow_api.g_varchar2_table(30) := '3D22732D726573697A65222C746869732E66726F6D456E643F28613D622E55502C6C3D622E444F574E293A28613D622E444F574E2C6C3D622E555029292C746869732E626172242E637373287B6C6566743A732C746F703A6F7D292E647261676761626C';
wwv_flow_api.g_varchar2_table(31) := '65287B617869733A642E686F72697A3F2278223A2279222C636F6E7461696E6D656E743A22706172656E74222C63616E63656C3A22627574746F6E222C637572736F723A722C696672616D654669783A702E696672616D654669782C677269643A752C73';
wwv_flow_api.g_varchar2_table(32) := '63726F6C6C3A21312C647261673A66756E6374696F6E28692C74297B76617220653B702E7265616C54696D65262628653D742E706F736974696F6E5B685D2C642E66726F6D456E64262628653D28642E686F72697A3F632E776964746828293A632E6865';
wwv_flow_api.g_varchar2_table(33) := '696768742829292D652D642E62617253697A65292C642E5F736574506F7328652C213129297D2C73746172743A66756E6374696F6E28692C74297B642E626172242E616464436C617373282269732D61637469766522297D2C73746F703A66756E637469';
wwv_flow_api.g_varchar2_table(34) := '6F6E28692C74297B76617220653D742E706F736974696F6E5B685D3B642E626172242E72656D6F7665436C617373282269732D61637469766522292C642E66726F6D456E64262628653D28642E686F72697A3F632E776964746828293A632E6865696768';
wwv_flow_api.g_varchar2_table(35) := '742829292D652D642E62617253697A65292C642E5F736574506F7328652C2131297D7D292E636C69636B282866756E6374696F6E28297B692874686973292E66696E64286E292E666F63757328297D29292E66696E642822627574746F6E22292E636C69';
wwv_flow_api.g_varchar2_table(36) := '636B282866756E6374696F6E28297B642E5F736574506F7328642E5F676574506F7328292C21642E5F6973436F6C6C61707365642829297D29292C617065782E7769646765742E7574696C2E546F75636850726F78792E616464546F7563684C69737465';
wwv_flow_api.g_varchar2_table(37) := '6E65727328746869732E626172245B305D292C746869732E626172242E66696E64286E292E666F637573282866756E6374696F6E28297B692874686973292E706172656E7428292E616464436C617373282269732D666F63757365642069732D61637469';
wwv_flow_api.g_varchar2_table(38) := '766522297D29292E626C7572282866756E6374696F6E28297B692874686973292E706172656E7428292E72656D6F7665436C617373282269732D666F63757365642069732D61637469766522297D29292E6B6579646F776E282866756E6374696F6E2869';
wwv_flow_api.g_varchar2_table(39) := '297B76617220742C652C733D692E6B6579436F64652C6F3D6E756C6C2C6E3D21313B69662873213D3D6C7C7C702E636F6C6C61707365643F733D3D3D61262628286F3D642E5F676574506F732829293C303F28702E6E6F436F6C6C617073657C7C286E3D';
wwv_flow_api.g_varchar2_table(40) := '2130292C6F3D30293A6F2B3D702E696E632C743D642E5F6765744D6178506F7328292C6F3E742626286F3D7429293A286F3D642E5F676574506F7328292C286F2D3D702E696E63293C702E6D696E53697A652626702E6E6F436F6C6C617073652626286F';
wwv_flow_api.g_varchar2_table(41) := '3D702E6D696E53697A65292C6F3C302626286F3D3029292C6E756C6C213D3D6F2972657475726E20653D6F2C642E66726F6D456E64262628653D28642E686F72697A3F632E776964746828293A632E6865696768742829292D652D642E62617253697A65';
wwv_flow_api.g_varchar2_table(42) := '292C642E626172242E63737328682C65292C7A262628636C65617254696D656F7574287A292C7A3D6E756C6C292C7A3D73657454696D656F7574282866756E6374696F6E28297B7A3D6E756C6C2C642E5F736574506F73286F2C6E297D292C313030292C';
wwv_flow_api.g_varchar2_table(43) := '21317D29292C746869732E5F6F6E2821302C746869732E5F6576656E7448616E646C657273292C702E64697361626C65642626746869732E5F7365744F7074696F6E282264697361626C6564222C702E64697361626C6564292C746869732E7265667265';
wwv_flow_api.g_varchar2_table(44) := '736828297D2C5F726573697A653A66756E6374696F6E2865297B76617220732C6F2C6E2C722C613D746869732E6F7074696F6E732C6C3D746869732E656C656D656E743B652626652E746172676574213D3D6C5B305D7C7C28733D6C2E68656967687428';
wwv_flow_api.g_varchar2_table(45) := '292C6F3D6C2E776964746828292C30213D3D73262630213D3D6F3F28723D6C2E6F666673657428292C746869732E686F72697A3F286C2E6368696C6472656E28292E65616368282866756E6374696F6E28297B742E7365744F7574657248656967687428';
wwv_flow_api.g_varchar2_table(46) := '692874686973292C73297D29292C746869732E66726F6D456E643F286E3D5B722E6C6566742B612E6D696E53697A652C722E746F702C722E6C6566742B6F2D746869732E62617253697A652C722E746F702B735D2C612E64726167436F6C6C6170736526';
wwv_flow_api.g_varchar2_table(47) := '2621612E6E6F436F6C6C617073657C7C286E5B325D2D3D612E6D696E53697A6529293A286E3D5B722E6C6566742C722E746F702C722E6C6566742B6F2D746869732E62617253697A652D612E6D696E53697A652C722E746F702B735D2C612E6472616743';
wwv_flow_api.g_varchar2_table(48) := '6F6C6C61707365262621612E6E6F436F6C6C617073657C7C286E5B305D2B3D612E6D696E53697A652B312929293A286C2E6368696C6472656E28292E65616368282866756E6374696F6E28297B742E7365744F7574657257696474682869287468697329';
wwv_flow_api.g_varchar2_table(49) := '2C6F297D29292C746869732E66726F6D456E643F286E3D5B722E6C6566742C722E746F702B612E6D696E53697A652C722E6C6566742B6F2C722E746F702B732D746869732E62617253697A655D2C612E64726167436F6C6C61707365262621612E6E6F43';
wwv_flow_api.g_varchar2_table(50) := '6F6C6C617073657C7C286E5B335D2D3D612E6D696E53697A6529293A286E3D5B722E6C6566742C722E746F702C722E6C6566742B6F2C722E746F702B732D746869732E62617253697A652D612E6D696E53697A655D2C612E64726167436F6C6C61707365';
wwv_flow_api.g_varchar2_table(51) := '262621612E6E6F436F6C6C617073657C7C286E5B315D2B3D612E6D696E53697A652B312929292C746869732E5F736574506F7328612E706F736974696F6E2C612E636F6C6C6170736564292C746869732E626172242E647261676761626C6528226F7074';
wwv_flow_api.g_varchar2_table(52) := '696F6E222C22636F6E7461696E6D656E74222C6E292C6C2E6368696C6472656E28222E726573697A6522292E66696C74657228223A76697369626C6522292E747269676765722822726573697A6522292C652626652E73746F7050726F7061676174696F';
wwv_flow_api.g_varchar2_table(53) := '6E2829293A612E6E65656473526573697A653D2130297D2C5F64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C6173732822612D53706C697474657220222B722B2220752D52544C20726573697A6522';
wwv_flow_api.g_varchar2_table(54) := '292E6368696C6472656E2873292E72656D6F766528292C746869732E656C656D656E742E6368696C6472656E28292E6373732822706F736974696F6E222C2222297D2C726566726573683A66756E6374696F6E28297B746869732E656C656D656E742E69';
wwv_flow_api.g_varchar2_table(55) := '7328223A76697369626C6522292626746869732E656C656D656E742E747269676765722822726573697A6522297D2C5F7365744F7074696F6E3A66756E6374696F6E28742C73297B766172206F2C6C2C683B69662821746869732E6F7074696F6E732E6E';
wwv_flow_api.g_varchar2_table(56) := '6F436F6C6C617073657C7C22636F6C6C617073656422213D3D74262622726573746F72655465787422213D3D74262622636F6C6C617073655465787422213D3D74297B696628226F7269656E746174696F6E223D3D3D747C7C22706F736974696F6E6564';
wwv_flow_api.g_varchar2_table(57) := '46726F6D223D3D3D747C7C226E6F436F6C6C61707365223D3D3D74297468726F77206E6577204572726F722822526561646F6E6C79206F7074696F6E3A20222B74293B22706F736974696F6E223D3D3D743F746869732E5F736574506F7328312A732C74';
wwv_flow_api.g_varchar2_table(58) := '6869732E5F6973436F6C6C61707365642829293A22636F6C6C6170736564223D3D3D743F746869732E5F736574506F7328746869732E5F676574506F7328292C212173293A22736E6170223D3D3D743F28733D2121732626312A732C746869732E6F7074';
wwv_flow_api.g_varchar2_table(59) := '696F6E732E736E61703D732C6F3D21217326265B732C735D2C746869732E626172242E647261676761626C6528226F7074696F6E222C2267726964222C6F292C73262628746869732E6F7074696F6E732E696E633D7329293A22696E63223D3D3D743F28';
wwv_flow_api.g_varchar2_table(60) := '732A3D312C746869732E6F7074696F6E732E736E6170262628733D746869732E6F7074696F6E732E736E6170292C746869732E6F7074696F6E732E696E633D73293A2264697361626C6564223D3D3D743F28746869732E6F7074696F6E732E6469736162';
wwv_flow_api.g_varchar2_table(61) := '6C65643D732C683D746869732E626172242E66696E64286E292C746869732E6F7074696F6E732E6E6F436F6C6C617073653F733F682E72656D6F7665417474722822746162696E64657822293A682E617474722822746162696E646578222C223022293A';
wwv_flow_api.g_varchar2_table(62) := '28685B305D2E64697361626C65643D732C733F682E6174747228612C746869732E6F7074696F6E732E7469746C65293A682E6174747228612C746869732E6F7074696F6E732E636F6C6C61707365643F746869732E6F7074696F6E732E726573746F7265';
wwv_flow_api.g_varchar2_table(63) := '546578743A746869732E6F7074696F6E732E636F6C6C617073655465787429292C746869732E626172242E647261676761626C6528226F7074696F6E222C2264697361626C6564222C73292C733F28746869732E656C656D656E742E616464436C617373';
wwv_flow_api.g_varchar2_table(64) := '2872292C746869732E626172242E616464436C6173732872292C682E617474722822617269612D64697361626C6564222C213029293A28682E72656D6F7665417474722822617269612D64697361626C656422292C746869732E626172242E72656D6F76';
wwv_flow_api.g_varchar2_table(65) := '65436C6173732872292C746869732E656C656D656E742E72656D6F7665436C61737328722929293A226D696E53697A65223D3D3D743F28733C286C3D746869732E6F7074696F6E732E6E6F436F6C6C617073653F303A3129262628733D6C2C652E776172';
wwv_flow_api.g_varchar2_table(66) := '6E28224F7074696F6E206D696E53697A652061646A75737465642229292C746869732E6F7074696F6E732E6D696E53697A653D73293A692E5769646765742E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C617267756D';
wwv_flow_api.g_varchar2_table(67) := '656E7473292C227469746C65223D3D3D743F28746869732E626172242E6174747228612C73292C28746869732E6F7074696F6E732E6E6F436F6C6C617073657C7C746869732E6F7074696F6E732E64697361626C6564292626746869732E626172242E66';
wwv_flow_api.g_varchar2_table(68) := '696E64286E292E6174747228612C7329293A22726573746F726554657874223D3D3D742626746869732E6F7074696F6E732E636F6C6C6170736564262621746869732E6F7074696F6E732E64697361626C65643F746869732E626172242E66696E642822';
wwv_flow_api.g_varchar2_table(69) := '627574746F6E22292E6174747228612C73293A22636F6C6C617073655465787422213D3D747C7C746869732E6F7074696F6E732E636F6C6C61707365647C7C746869732E6F7074696F6E732E64697361626C65643F22696672616D65466978223D3D3D74';
wwv_flow_api.g_varchar2_table(70) := '3F746869732E626172242E647261676761626C6528226F7074696F6E222C22696672616D65466978222C73293A2264726167436F6C6C61707365223D3D3D742626746869732E7265667265736828293A746869732E626172242E66696E64282262757474';
wwv_flow_api.g_varchar2_table(71) := '6F6E22292E6174747228612C73297D656C736520652E7761726E282253657474696E6720222B742B22206F7074696F6E206F6E206E6F436F6C6C617073652073706C697474657220686173206E6F206566666563742E22297D2C5F6576656E7448616E64';
wwv_flow_api.g_varchar2_table(72) := '6C6572733A7B726573697A653A66756E6374696F6E2869297B746869732E5F726573697A652869297D7D2C5F72656E6465724261723A66756E6374696F6E2869297B76617220743D746869732E6F7074696F6E732C653D746869732E686F72697A3F2261';
wwv_flow_api.g_varchar2_table(73) := '2D53706C69747465722D62617248223A22612D53706C69747465722D62617256223B746869732E66726F6D456E64262628652B3D2220612D53706C69747465722D2D656E6422292C742E6E6F436F6C6C61707365262628742E636F6C6C61707365643D21';
wwv_flow_api.g_varchar2_table(74) := '31292C742E636F6C6C6170736564262628652B3D222069732D636F6C6C617073656422292C692E6D61726B757028223C64697622292E617474722822636C617373222C65292E6F7074696F6E616C4174747228612C742E7469746C65292E6D61726B7570';
wwv_flow_api.g_varchar2_table(75) := '28223E3C6469763E3C2F6469763E22292C742E6E6F436F6C6C617073653F692E6D61726B757028223C7370616E20726F6C653D27736570617261746F722720636C6173733D27222B6F2B222720746162696E6465783D27302720617269612D657870616E';
wwv_flow_api.g_varchar2_table(76) := '6465643D27747275652722292E6F7074696F6E616C4174747228612C742E7469746C65292E6D61726B757028223E3C2F7370616E3E22293A692E6D61726B757028223C627574746F6E20726F6C653D27736570617261746F722720636C6173733D27222B';
wwv_flow_api.g_varchar2_table(77) := '6F2B222720747970653D27627574746F6E2722292E617474722822617269612D657870616E646564222C21742E636F6C6C6170736564292E6F7074696F6E616C4174747228612C742E636F6C6C61707365643F742E726573746F7265546578743A742E63';
wwv_flow_api.g_varchar2_table(78) := '6F6C6C6170736554657874292E6D61726B757028223E3C2F627574746F6E3E22292C692E6D61726B757028223C2F6469763E22297D2C5F676574506F733A66756E6374696F6E28297B76617220693D746869732E656C656D656E742C743D746869732E68';
wwv_flow_api.g_varchar2_table(79) := '6F72697A3F226C656674223A22746F70222C653D746869732E626172242E706F736974696F6E28295B745D3B72657475726E20746869732E66726F6D456E64262628653D28746869732E686F72697A3F692E776964746828293A692E6865696768742829';
wwv_flow_api.g_varchar2_table(80) := '292D652D746869732E62617253697A65292C657D2C5F6973436F6C6C61707365643A66756E6374696F6E28297B72657475726E20746869732E626172242E686173436C617373282269732D636F6C6C617073656422297D2C5F6765744D6178506F733A66';
wwv_flow_api.g_varchar2_table(81) := '756E6374696F6E28297B76617220693D746869732E6F7074696F6E732C743D746869732E656C656D656E743B72657475726E20746869732E686F72697A3F742E776964746828292D746869732E62617253697A652D692E6D696E53697A653A742E686569';
wwv_flow_api.g_varchar2_table(82) := '67687428292D746869732E62617253697A652D692E6D696E53697A657D2C5F736574506F733A66756E6374696F6E28692C65297B76617220732C6F2C722C6C2C682C642C703D746869732E6F7074696F6E732C633D746869732E656C656D656E742C663D';
wwv_flow_api.g_varchar2_table(83) := '746869732E686F72697A3F226C656674223A22746F70222C623D746869732E5F6973436F6C6C617073656428292C753D746869732E6C617374506F733B702E6E6F436F6C6C61707365262628653D2131292C6226262165262628693D746869732E6C6173';
wwv_flow_api.g_varchar2_table(84) := '74506F73293C702E6D696E53697A65262628693D702E6D696E53697A65292C693C702E6D696E53697A653F702E6E6F436F6C6C617073653F693D702E6D696E53697A653A653D21303A693E28733D746869732E5F6765744D6178506F7328292926262869';
wwv_flow_api.g_varchar2_table(85) := '3D73292C702E6E6F436F6C6C617073652626693C3D30262628693D30292C693E30262628746869732E6C617374506F733D69292C65262628693D302C702E706F736974696F6E3D30292C6F3D746869732E686F72697A3F632E776964746828293A632E68';
wwv_flow_api.g_varchar2_table(86) := '656967687428292C683D692C746869732E66726F6D456E64262628683D6F2D692D746869732E62617253697A65292C746869732E626172242E63737328662C68292C643D746869732E626172242E66696E64286E292C746869732E66726F6D456E643F28';
wwv_flow_api.g_varchar2_table(87) := '723D746869732E6166746572242C6C3D6F2D682D746869732E62617253697A65293A28723D746869732E6265666F7265242C6C3D68292C653F28746869732E626172242E616464436C617373282269732D636F6C6C617073656422292C702E6469736162';
wwv_flow_api.g_varchar2_table(88) := '6C65647C7C642E617474722822617269612D657870616E646564222C2131292E6174747228612C702E726573746F726554657874292C722E686964652829293A28702E6E6F436F6C6C617073653F722E746F67676C652830213D3D69293A28746869732E';
wwv_flow_api.g_varchar2_table(89) := '626172242E72656D6F7665436C617373282269732D636F6C6C617073656422292C702E6E6F436F6C6C617073657C7C702E64697361626C65647C7C642E617474722822617269612D657870616E646564222C2130292E6174747228612C702E636F6C6C61';
wwv_flow_api.g_varchar2_table(90) := '70736554657874292C722E73686F772829292C746869732E686F72697A3F742E7365744F75746572576964746828722C6C293A742E7365744F7574657248656967687428722C6C29292C746869732E66726F6D456E643F28723D746869732E6265666F72';
wwv_flow_api.g_varchar2_table(91) := '65242C6C3D68293A28723D746869732E6166746572242C6C3D6F2D682D746869732E62617253697A65292C746869732E686F72697A3F742E7365744F75746572576964746828722C6C293A742E7365744F7574657248656967687428722C6C292C702E6E';
wwv_flow_api.g_varchar2_table(92) := '6F436F6C6C617073652626722E746F67676C652830213D3D6C292C746869732E6166746572242E63737328662C682B746869732E62617253697A652B22707822292C746869732E6265666F7265242E63737328662C30292C282165262669213D3D757C7C';
wwv_flow_api.g_varchar2_table(93) := '62213D3D6529262628702E636F6C6C61707365643D652C702E706F736974696F6E3D692C632E6368696C6472656E28222E726573697A6522292E66696C74657228223A76697369626C6522292E747269676765722822726573697A6522292C746869732E';
wwv_flow_api.g_varchar2_table(94) := '5F7472696767657228226368616E6765222C7B7D2C7B706F736974696F6E3A702E706F736974696F6E2C636F6C6C61707365643A702E636F6C6C61707365642C6C617374506F736974696F6E3A746869732E6C617374506F737D29297D7D293B76617220';
wwv_flow_api.g_varchar2_table(95) := '6C3D302C683D303B692E617065782E73706C69747465722E6E65787453706C69747465723D66756E6374696F6E2874297B76617220652C6F2C722C613D743F2D313A312C643D6928646F63756D656E742E616374697665456C656D656E74293B69662821';
wwv_flow_api.g_varchar2_table(96) := '286C3E307C7C683E30292972657475726E28723D286F3D6928222E612D53706C6974746572203E2E612D53706C69747465722D626172482C2E612D53706C6974746572203E2E612D53706C69747465722D6261725622292E66696C74657228223A766973';
wwv_flow_api.g_varchar2_table(97) := '69626C6522292E6E6F7428222E75692D73746174652D64697361626C656422292E616464286429292E696E646578286429293E3D30262628722B3D612C742626642E706172656E7428292E6973287329262628722B3D61292C723E3D302626723C6F2E6C';
wwv_flow_api.g_varchar2_table(98) := '656E677468262628653D6F2E657128722929292C28652626303D3D3D652E6C656E677468262621642E706172656E7428292E69732873297C7C642E6973282268746D6C2C626F6479222929262628653D6928222E612D53706C6974746572203E2E612D53';
wwv_flow_api.g_varchar2_table(99) := '706C69747465722D626172482C2E612D53706C6974746572203E2E612D53706C69747465722D6261725622292E66696C74657228223A76697369626C6522292E6E6F7428222E75692D73746174652D64697361626C656422295B743F226C617374223A22';
wwv_flow_api.g_varchar2_table(100) := '6669727374225D2829292C652626652E6C656E6774683E303F28652E6368696C6472656E286E292E666F63757328292C2130293A766F696420307D2C69282866756E6374696F6E28297B6928646F63756D656E742E626F6479292E6F6E28226D656E7562';
wwv_flow_api.g_varchar2_table(101) := '65666F72656F70656E222C2866756E6374696F6E28297B682B3D317D29292E6F6E28226D656E756166746572636C6F7365222C2866756E6374696F6E28297B682D3D317D29292E6F6E28226469616C6F676F70656E222C2866756E6374696F6E28297B6C';
wwv_flow_api.g_varchar2_table(102) := '2B3D317D29292E6F6E28226469616C6F67636C6F7365222C2866756E6374696F6E28297B6C2D3D317D29297D29292C617065782E6D6573736167652626617065782E6D6573736167652E6164645669736962696C697479436865636B282866756E637469';
wwv_flow_api.g_varchar2_table(103) := '6F6E2874297B76617220653D69282223222B74293B652E706172656E747328222E612D53706C697474657222292E65616368282866756E6374696F6E28297B652E697328223A76697369626C6522297C7C692874686973292E73706C697474657228226F';
wwv_flow_api.g_varchar2_table(104) := '7074696F6E222C22636F6C6C6170736564222C2131297D29297D29297D28617065782E6A51756572792C617065782E7574696C2C617065782E6465627567293B0A2F2F2320736F757263654D617070696E6755524C3D7769646765742E73706C69747465';
wwv_flow_api.g_varchar2_table(105) := '722E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(71508580617870963)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'libraries/widget.splitter.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227769646765742E73706C69747465722E6A73225D2C226E616D6573223A5B2224222C227574696C222C226465627567222C2253454C5F424152222C22435F5448554D42222C2253454C5F54';
wwv_flow_api.g_varchar2_table(2) := '48554D42222C22435F44495341424C4544222C225449544C45222C22776964676574222C2276657273696F6E222C227769646765744576656E74507265666978222C226F7074696F6E73222C226F7269656E746174696F6E222C22706F736974696F6E65';
wwv_flow_api.g_varchar2_table(3) := '6446726F6D222C226D696E53697A65222C22706F736974696F6E222C226E6F436F6C6C61707365222C2264726167436F6C6C61707365222C22636F6C6C6170736564222C22736E6170222C22696E63222C227265616C54696D65222C22696672616D6546';
wwv_flow_api.g_varchar2_table(4) := '6978222C22726573746F726554657874222C22636F6C6C6170736554657874222C227469746C65222C226368616E6765222C226C617A7952656E646572222C226E65656473526573697A65222C227669736962696C697479436865636B44656C6179222C';
wwv_flow_api.g_varchar2_table(5) := '22696D6D6564696174655669736962696C697479436865636B222C226C617374506F73222C2262617224222C226265666F726524222C22616674657224222C22686F72697A222C2266726F6D456E64222C2262617253697A65222C225F63726561746522';
wwv_flow_api.g_varchar2_table(6) := '2C2273656C66222C2274686973222C226F222C226374726C24222C22656C656D656E74222C22656C222C2261706578222C226F6E5669736962696C6974794368616E6765222C22697356697369626C65222C2272656E6465726564222C225F696E697443';
wwv_flow_api.g_varchar2_table(7) := '6F6D706F6E656E74222C225F726573697A65222C2277696E646F77222C226F6E222C2273657454696D656F7574222C227669736962696C6974794368616E6765222C226C656674222C22746F70222C22637572736F72222C226B6579496E63222C226B65';
wwv_flow_api.g_varchar2_table(8) := '79446563222C22706F73222C226F7574222C2268746D6C4275696C646572222C226B657973222C227569222C226B6579436F6465222C2267726964222C226D696E4C696D6974222C2274696D65724964222C226368696C6472656E222C226C656E677468';
wwv_flow_api.g_varchar2_table(9) := '222C224572726F72222C227761726E222C226571222C22616464436C617373222C22435F53504C4954544552222C22637373222C22706172656E74222C226973222C226964222C225F72656E646572426172222C22746F537472696E67222C22696E7365';
wwv_flow_api.g_varchar2_table(10) := '72744166746572222C227769647468222C22686569676874222C224C454654222C225249474854222C225550222C22444F574E222C22647261676761626C65222C2261786973222C22636F6E7461696E6D656E74222C2263616E63656C222C227363726F';
wwv_flow_api.g_varchar2_table(11) := '6C6C222C2264726167222C2265222C2270222C225F736574506F73222C227374617274222C2273746F70222C2272656D6F7665436C617373222C22636C69636B222C2266696E64222C22666F637573222C225F676574506F73222C225F6973436F6C6C61';
wwv_flow_api.g_varchar2_table(12) := '70736564222C22546F75636850726F7879222C22616464546F7563684C697374656E657273222C22435F464F4355534544222C22626C7572222C226B6579646F776E222C226D6178222C227031222C226B63222C225F6765744D6178506F73222C22636C';
wwv_flow_api.g_varchar2_table(13) := '65617254696D656F7574222C225F6F6E222C225F6576656E7448616E646C657273222C2264697361626C6564222C225F7365744F7074696F6E222C2272656672657368222C226576656E74222C2268222C2277222C22626F756E6473222C226F66667365';
wwv_flow_api.g_varchar2_table(14) := '74222C22746172676574222C2265616368222C227365744F75746572486569676874222C227365744F757465725769647468222C2266696C746572222C2274726967676572222C2273746F7050726F7061676174696F6E222C225F64657374726F79222C';
wwv_flow_api.g_varchar2_table(15) := '2272656D6F7665222C226B6579222C2276616C7565222C227468756D6224222C2272656D6F766541747472222C2261747472222C22576964676574222C2270726F746F74797065222C226170706C79222C22617267756D656E7473222C22726573697A65';
wwv_flow_api.g_varchar2_table(16) := '222C22626172436C617373222C226D61726B7570222C226F7074696F6E616C41747472222C22686173436C617373222C22746F74616C222C226368696C6424222C226368696C6453697A65222C22637572436F6C6C6170736564222C22637572506F7322';
wwv_flow_api.g_varchar2_table(17) := '2C2268696465222C22746F67676C65222C2273686F77222C225F74726967676572222C226C617374506F736974696F6E222C226469616C6F67436F756E74222C226D656E75436F756E74222C2273706C6974746572222C226E65787453706C6974746572';
wwv_flow_api.g_varchar2_table(18) := '222C2272657665727365222C226E65787424222C22616C6C4261727324222C22637572222C22666F637573656424222C22646F63756D656E74222C22616374697665456C656D656E74222C2253454C5F53504C4954544552222C226E6F74222C22616464';
wwv_flow_api.g_varchar2_table(19) := '222C22696E646578222C22626F6479222C226D657373616765222C226164645669736962696C697479436865636B222C22656C24222C22706172656E7473222C226A5175657279225D2C226D617070696E6773223A223B3B3B3B43417144412C53414157';
wwv_flow_api.g_varchar2_table(20) := '412C45414147432C4541414D432C47414368422C614145412C49414949432C454141552C6F43414556432C454141552C6D42414356432C454141592C4941414D442C45414B6C42452C454141612C63414762432C454141512C5141455A502C4541414551';
wwv_flow_api.g_varchar2_table(21) := '2C4F41414F2C6742414169422C4341437442432C514141532C4D414354432C6B4241416D422C5741436E42432C514141532C4341434C432C594141612C61414362432C65414167422C5141476842432C514141532C47414754432C534141552C49414356';
wwv_flow_api.g_varchar2_table(22) := '432C594141592C4541455A432C634141632C45414364432C574141572C45414358432C4D41414D2C4541434E432C4941414B2C4741434C432C554141552C45414356432C574141572C45414358432C594141612C4B414362432C614141632C4B41436443';
wwv_flow_api.g_varchar2_table(23) := '2C4D41414F2C4B414350432C4F4141512C4B414352432C594141592C4541435A432C614141612C45414362432C7142414173422C4941437442432C3042414130422C4741453942432C514141532C4B414354432C4B41414D2C4B41434E432C514141532C';
wwv_flow_api.g_varchar2_table(24) := '4B414354432C4F4141512C4B414352432C4F41414F2C45414350432C534141532C45414354432C514141532C45414554432C514141532C5741434C2C49414149432C4541414F432C4B41414D432C45414149462C4541414B35422C51414374422B422C45';
wwv_flow_api.g_varchar2_table(25) := '414151482C4541414B492C51414362432C4541414B462C4541414D2C47414558442C45414145642C594143466B422C4B41414B72432C4F41414F502C4B41414B36432C6D4241416D42462C474141492C53414155472C47414339434E2C454141454D2C55';
wwv_flow_api.g_varchar2_table(26) := '414159412C45414356412C494141634E2C454141454F2C5741436842542C4541414B552C694241434C522C454141454F2C554141572C47414562442C474141614E2C45414145622C63414366572C4541414B572C5541434C542C45414145622C61414163';
wwv_flow_api.g_varchar2_table(27) := '2C4D4147784235422C454141456D442C51414151432C474141472C6742414167422C5741457A422C49414149522C4541414B462C4541414D2C47414566572C594141572C57414350522C4B41414B72432C4F41414F502C4B41414B71442C694241416942';
wwv_flow_api.g_varchar2_table(28) := '562C474141492C4B41437643482C454141455A2C7342414177422C5141473742592C45414145582C3042414346652C4B41414B72432C4F41414F502C4B41414B71442C694241416942562C474141492C49414731434C2C4541414B552C6B42414962412C';
wwv_flow_api.g_varchar2_table(29) := '65414167422C5741435A2C494141494D2C4541414D432C4541414B432C45414358432C45414151432C45414151432C454143684272422C4541414F432C4B414350432C45414149442C4B41414B37422C514143542B422C45414151462C4B41414B472C51';
wwv_flow_api.g_varchar2_table(30) := '4143626B422C4541414D35442C4541414B36442C63414358432C4541414F2F442C4541414567452C47414147432C5141435A432C4941414F7A422C4541414574422C4D41414F2C434141552C4541415473422C4541414574422C4B41416D422C45414154';
wwv_flow_api.g_varchar2_table(31) := '73422C4541414574422C4D41432F4267442C4541415731422C454141457A422C574141612C454141492C45414339426F442C454141552C4B4145642C47414167432C494141354231422C4541414D32422C57414157432C4F41436A422C4D41414D2C4941';
wwv_flow_api.g_varchar2_table(32) := '4149432C4D41414D2C3443414570422C47414173422C6541416C4239422C4541414537422C6141416B442C6141416C4236422C4541414537422C59414370432C4D41414D2C4941414932442C4D41414D2C7942414570422C47414179422C554141724239';
wwv_flow_api.g_varchar2_table(33) := '422C4541414535422C674241416D442C514141724234422C4541414535422C6541436C432C4D41414D2C4941414930442C4D41414D2C344241714270422C47416C424939422C4541414533422C5141415571442C4941435A31422C4541414533422C5141';
wwv_flow_api.g_varchar2_table(34) := '415571442C4541435A6A452C4541414D73452C4B41414B2C344241456668432C4B41414B4C2C4D414130422C6541416C424D2C4541414537422C5941436634422C4B41414B4A2C5141412B422C51414172424B2C4541414535422C6541436A422B432C45';
wwv_flow_api.g_varchar2_table(35) := '41414D70422C4B41414B4C2C4D4141512C4F4141532C4D414335424B2C4B41414B502C51414155532C4541414D32422C57414157492C474141472C4741436E436A432C4B41414B4E2C4F414153512C4541414D32422C57414157492C474141472C474143';
wwv_flow_api.g_varchar2_table(36) := '6C432F422C4541414D67432C53414153432C7142414367422C51414133426A432C4541414D6B432C494141492C654143566C432C4541414D67432C53416A484E2C53416B48496C432C4B41414B4C2C5141434C4B2C4B41414B502C51414155532C454141';
wwv_flow_api.g_varchar2_table(37) := '4D32422C57414157492C474141472C4741436E436A432C4B41414B4E2C4F414153512C4541414D32422C57414157492C474141472C4741436C436A432C4B41414B4A2C53414157492C4B41414B4A2C5541477A424D2C4541414D6D432C4F412F48432C65';
wwv_flow_api.g_varchar2_table(38) := '412B486F42502C4F4141532C4741414B39422C4B41414B502C5141415136432C47412F482F432C6742412B486D4574432C4B41414B4E2C4F41414F34432C47412F482F452C65416749502C4D41414D2C49414149502C4D41414D2C30434145662F422C4B';
wwv_flow_api.g_varchar2_table(39) := '41414B502C514141512C4741414738432C4B41436A4276432C4B41414B502C514141512C4741414738432C4941414D72432C4541414D2C4741414771432C4941414D2C594141632C5541456C4476432C4B41414B4E2C4F41414F2C4741414736432C4B41';
wwv_flow_api.g_varchar2_table(40) := '43684276432C4B41414B4E2C4F41414F2C4741414736432C4941414D72432C4541414D2C4741414771432C4941414D2C594141632C5741456C4474432C4541414531422C5341415730422C4541414533422C5541436632422C4541414531422C53414157';
wwv_flow_api.g_varchar2_table(41) := '30422C4541414533422C5341456E4230422C4B41414B542C51414155552C4541414531422C5341436230422C4541414574422C4F41434673422C4541414572422C4941414D71422C4541414574422C4D41496471422C4B41414B77432C574141576E422C';
wwv_flow_api.g_varchar2_table(42) := '474143684272422C4B41414B522C4B41414F68432C4541414536442C454141496F422C59414159432C5941415978432C4541414D32422C57414157492C474141472C49414531446A432C4B41414B4C2C4D41434C4B2C4B41414B482C51414155472C4B41';
wwv_flow_api.g_varchar2_table(43) := '414B522C4B41414B6D442C5141457A4233432C4B41414B482C51414155472C4B41414B522C4B41414B6F442C534147374231432C4541414D6B432C494141492C4341434E37442C534141552C6141435873442C574141574F2C494141492C434143643744';
wwv_flow_api.g_varchar2_table(44) := '2C534141552C6141475679422C4B41414B4C2C4F41434C6F422C4541414F662C4B41414B522C4B41414B6A422C5741415736432C47414335424A2C4541414D2C4541434E432C454141532C5741434C6A422C4B41414B4A2C5341434C73422C454141534B';
wwv_flow_api.g_varchar2_table(45) := '2C4541414B73422C4B41436431422C45414153492C4541414B75422C5141456435422C454141534B2C4541414B75422C4D41436433422C45414153492C4541414B73422C5141476C4239422C4541414F2C45414350432C4541414D68422C4B41414B522C';

wwv_flow_api.g_varchar2_table(46) := '4B41414B6A422C5741415736432C4741433342482C454141532C5741434C6A422C4B41414B4A2C5341434C73422C454141534B2C4541414B77422C4741436435422C45414153492C4541414B79422C4F41456439422C454141534B2C4541414B79422C4B';
wwv_flow_api.g_varchar2_table(47) := '41436437422C45414153492C4541414B77422C4B414974422F432C4B41414B522C4B41414B34432C494141492C4341435672422C4B41414D412C4541434E432C4941414B412C4941434E69432C554141552C43414354432C4B41414D6E442C4541414B4A';
wwv_flow_api.g_varchar2_table(48) := '2C4D4141512C4941414D2C4941437A4277442C594141612C53414362432C4F416C4C4B2C53416D4C4C6E432C4F414151412C454143526E432C554141576D422C454141456E422C5541436234432C4B41414D412C4541434E32422C514141512C45414352';
wwv_flow_api.g_varchar2_table(49) := '432C4B41414D2C53414155432C454141472F422C474143662C4941414967432C4541434176442C4541414570422C5741434632452C4541414968432C454141476A442C5341415336432C4741435A72422C4541414B482C5541434C34442C4741414B7A44';
wwv_flow_api.g_varchar2_table(50) := '2C4541414B4A2C4D4141514F2C4541414D79432C514141557A432C4541414D30432C55414159592C454141497A442C4541414B462C5341456A45452C4541414B30442C51414151442C474141472C4B41477842452C4D41414F2C53414155482C45414147';
wwv_flow_api.g_varchar2_table(51) := '2F422C47414368427A422C4541414B502C4B41414B30432C5341724D582C6341754D4879422C4B41414D2C534141554A2C454141472F422C474143662C4941414967432C4541414968432C454141476A442C5341415336432C474145704272422C454141';
wwv_flow_api.g_varchar2_table(52) := '4B502C4B41414B6F452C5941314D582C6141324D4B37442C4541414B482C5541434C34442C4741414B7A442C4541414B4A2C4D4141514F2C4541414D79432C514141557A432C4541414D30432C55414159592C454141497A442C4541414B462C5341456A';
wwv_flow_api.g_varchar2_table(53) := '45452C4541414B30442C51414151442C474141472C4D414572424B2C4F41414D2C5741434C72472C4541414577432C4D41414D38442C4B41414B6A472C474141576B472C5741437A42442C4B412F4D4D2C55412B4D57442C4F41414D2C57414374423944';
wwv_flow_api.g_varchar2_table(54) := '2C4541414B30442C5141415131442C4541414B69452C574141596A452C4541414B6B452C6D424145764335442C4B41414B72432C4F41414F502C4B41414B79472C57414157432C6B4241416B426E452C4B41414B522C4B41414B2C4941437844512C4B41';
wwv_flow_api.g_varchar2_table(55) := '414B522C4B41414B73452C4B41414B6A472C474141576B472C4F41414D2C574143354276472C4541414577432C4D41414D71432C53414153482C534141536B432C324241433342432C4D41414B2C5741434A37472C4541414577432C4D41414D71432C53';
wwv_flow_api.g_varchar2_table(56) := '41415375422C59414159512C324241433942452C534141512C53414155662C4741436A422C4941414967422C4541414B432C4541434C432C4541414B6C422C4541414539422C514143502B422C454141492C4B41434A39452C474141592C454130426842';
wwv_flow_api.g_varchar2_table(57) := '2C47417842492B462C4941414F74442C474141576C422C4541414576422C554153622B462C4941414F76442C4B41436473432C454141497A442C4541414B69452C574143442C474143432F442C454141457A422C61414348452C474141592C4741456842';
wwv_flow_api.g_varchar2_table(58) := '38452C454141492C4741454A412C4741414B76442C4541414572422C4941455832462C4541414D78452C4541414B32452C614143506C422C45414149652C4941434A662C45414149652C4B41704252662C454141497A442C4541414B69452C5741435452';
wwv_flow_api.g_varchar2_table(59) := '2C4741414B76442C4541414572422C4B41434371422C4541414533422C5341415732422C454141457A422C6141436E4267462C4541414976442C4541414533422C5341454E6B462C454141492C4941434A412C454141492C49416942462C4F41414E412C';
wwv_flow_api.g_varchar2_table(60) := '454163412C4F41624167422C4541414B68422C454143447A442C4541414B482C5541434C34452C4741414D7A452C4541414B4A2C4D4141514F2C4541414D79432C514141557A432C4541414D30432C5541415934422C4541414B7A452C4541414B462C53';
wwv_flow_api.g_varchar2_table(61) := '41456E45452C4541414B502C4B41414B34432C4941414968422C4541414B6F442C4741436635432C494143412B432C614141612F432C47414362412C454141552C4D414564412C45414155662C594141572C5741436A42652C454141552C4B4143563742';
wwv_flow_api.g_varchar2_table(62) := '2C4541414B30442C51414151442C4541414739452C4B41436A422C4D4143492C4B41496673422C4B41414B34452C4B4141492C4541414D35452C4B41414B36452C67424145684235452C4541414536452C5541434639452C4B41414B2B452C574141572C';
wwv_flow_api.g_varchar2_table(63) := '5741415939452C4541414536452C5541456C4339452C4B41414B67462C5741475474452C514141532C5341415575452C474143662C49414149432C45414147432C45414147432C45414151432C4541436470462C45414149442C4B41414B37422C514143';
wwv_flow_api.g_varchar2_table(64) := '542B422C45414151462C4B41414B472C5141456238452C47414153412C4541414D4B2C5341415770462C4541414D2C4B4147704367462C4541414968462C4541414D30432C5341435675432C454141496A462C4541414D79432C514143412C4941414E75';
wwv_flow_api.g_varchar2_table(65) := '432C47414169422C4941414E432C47414D66452C454141536E462C4541414D6D462C5341435872462C4B41414B4C2C4F41434C4F2C4541414D32422C5741415730442C4D41414B2C5741436C4239482C4541414B2B482C6541416568492C454141457743';
wwv_flow_api.g_varchar2_table(66) := '2C4D41414F6B462C4D414537426C462C4B41414B4A2C5341434C77462C454141532C43414143432C4541414F74452C4B41414F642C4541414533422C514141532B472C4541414F72452C4941414B71452C4541414F74452C4B41414F6F452C454141496E';
wwv_flow_api.g_varchar2_table(67) := '462C4B41414B482C5141415377462C4541414F72452C4941414D6B452C47414376466A462C4541414578422C654141674277422C454141457A422C614143724234472C4541414F2C4941414D6E462C4541414533422C5741476E4238472C454141532C43';
wwv_flow_api.g_varchar2_table(68) := '414143432C4541414F74452C4B41414D73452C4541414F72452C4941414B71452C4541414F74452C4B41414F6F452C454141496E462C4B41414B482C51414155492C4541414533422C514141532B472C4541414F72452C4941414D6B452C47414376466A';
wwv_flow_api.g_varchar2_table(69) := '462C4541414578422C654141674277422C454141457A422C614143724234472C4541414F2C4941414D6E462C4541414533422C514141552C4D41496A4334422C4541414D32422C5741415730442C4D41414B2C5741436C4239482C4541414B67492C6341';
wwv_flow_api.g_varchar2_table(70) := '41636A492C4541414577432C4D41414F6D462C4D414535426E462C4B41414B4A2C5341434C77462C454141532C43414143432C4541414F74452C4B41414D73452C4541414F72452C4941414D662C4541414533422C514141532B472C4541414F74452C4B';
wwv_flow_api.g_varchar2_table(71) := '41414F6F452C45414147452C4541414F72452C4941414D6B452C454141496C462C4B41414B482C5341436A46492C4541414578422C654141674277422C454141457A422C614143724234472C4541414F2C4941414D6E462C4541414533422C5741476E42';
wwv_flow_api.g_varchar2_table(72) := '38472C454141532C43414143432C4541414F74452C4B41414D73452C4541414F72452C4941414B71452C4541414F74452C4B41414F6F452C45414147452C4541414F72452C4941414D6B452C454141496C462C4B41414B482C51414155492C4541414533';
wwv_flow_api.g_varchar2_table(73) := '422C5341436A4632422C4541414578422C654141674277422C454141457A422C614143724234472C4541414F2C4941414D6E462C4541414533422C514141552C4B4149724330422C4B41414B79442C5141415178442C4541414531422C5341415530422C';
wwv_flow_api.g_varchar2_table(74) := '4541414576422C574143334273422C4B41414B522C4B41414B79442C554141552C534141552C634141656D432C47414337436C462C4541414D32422C534141532C5741415736442C4F41414F2C59414159432C514141512C5541436A44562C4741414F41';
wwv_flow_api.g_varchar2_table(75) := '2C4541414D572C6D424178436233462C45414145622C614141632C49413243784279472C534141552C5741434E37462C4B41414B472C5141415179442C594141597A422C6341416D4272452C4541416E4271452C6942414370424E2C534141536C452C47';
wwv_flow_api.g_varchar2_table(76) := '4141536D492C534143764239462C4B41414B472C5141415130422C574141574F2C494141492C574141592C4B4147354334432C514141532C5741434468462C4B41414B472C514141516D432C474141472C614143684274432C4B41414B472C5141415177';
wwv_flow_api.g_varchar2_table(77) := '462C514141512C57414937425A2C574141592C5341415567422C4541414B432C47414376422C4941414974452C4541414D432C4541415573452C45414570422C494141496A472C4B41414B37422C514141514B2C59414175422C6341415275482C474141';
wwv_flow_api.g_varchar2_table(78) := '2B422C6742414152412C47414169432C6942414152412C45414168462C43414B412C474141592C6742414152412C47414169432C6D42414152412C4741416F432C65414152412C45414572442C4D41414D2C4941414968452C4D41414D2C6F4241417342';
wwv_flow_api.g_varchar2_table(79) := '67452C47414376422C61414152412C454145502F462C4B41414B79442C51414167422C4541415275432C4541415768472C4B41414B69452C67424143642C6341415238422C454145502F462C4B41414B79442C514141517A442C4B41414B67452C594141';
wwv_flow_api.g_varchar2_table(80) := '6167432C47414368422C53414152442C47414550432C49414151412C47414167422C45414152412C454143684268472C4B41414B37422C51414151512C4B41414F71482C454143704274452C4941414F73452C474141512C43414143412C4541414F412C';
wwv_flow_api.g_varchar2_table(81) := '474143764268472C4B41414B522C4B41414B79442C554141552C534141552C4F41415176422C4741436C4373452C4941434168472C4B41414B37422C51414151532C4941414D6F482C494145522C51414152442C47414350432C47414167422C4541435A';
wwv_flow_api.g_varchar2_table(82) := '68472C4B41414B37422C51414151512C4F41436271482C4541415168472C4B41414B37422C51414151512C4D41457A4271422C4B41414B37422C51414151532C4941414D6F482C4741434A2C61414152442C474143502F462C4B41414B37422C51414151';
wwv_flow_api.g_varchar2_table(83) := '32472C534141576B422C4541437842432C454141536A472C4B41414B522C4B41414B73452C4B41414B6A472C4741436E426D432C4B41414B37422C514141514B2C5741535677482C45414341432C4541414F432C574141572C5941456C42442C4541414F';
wwv_flow_api.g_varchar2_table(84) := '452C4B41414B2C574141592C4D41563542462C4541414F2C474141476E422C534141576B422C4541436A42412C45414341432C4541414F452C4B41414B70492C4541414F69432C4B41414B37422C51414151632C4F4145684367482C4541414F452C4B41';
wwv_flow_api.g_varchar2_table(85) := '414B70492C4541414F69432C4B41414B37422C514141514F2C5541415973422C4B41414B37422C51414151592C5941416369422C4B41414B37422C51414151612C654153354667422C4B41414B522C4B41414B79442C554141552C534141552C57414159';
wwv_flow_api.g_varchar2_table(86) := '2B432C4741437443412C4741434168472C4B41414B472C514141512B422C5341415370452C47414374426B432C4B41414B522C4B41414B30432C5341415370452C4741436E426D492C4541414F452C4B41414B2C6942414169422C4B41453742462C4541';
wwv_flow_api.g_varchar2_table(87) := '414F432C574141572C694241436C426C472C4B41414B522C4B41414B6F452C5941415939462C47414374426B432C4B41414B472C5141415179442C5941415939462C4B4145642C5941415269492C47414548432C4741444A72452C4541415733422C4B41';
wwv_flow_api.g_varchar2_table(88) := '414B37422C514141514B2C574141612C454141492C4B4145724377482C4541415172452C454143526A452C4541414D73452C4B41414B2C344241456668432C4B41414B37422C51414151472C5141415530482C474145764278492C4541414534492C4F41';
wwv_flow_api.g_varchar2_table(89) := '414F432C5541415574422C5741415775422C4D41414D74472C4B41414D75472C5741456C432C55414152522C474143412F462C4B41414B522C4B41414B32472C4B41414B70492C4541414F69492C4941436C4268472C4B41414B37422C514141514B2C59';
wwv_flow_api.g_varchar2_table(90) := '41416377422C4B41414B37422C5141415132472C574143784339452C4B41414B522C4B41414B73452C4B41414B6A472C4741415773492C4B41414B70492C4541414F69492C49414533422C6742414152442C47414179422F462C4B41414B37422C514141';
wwv_flow_api.g_varchar2_table(91) := '514F2C5941416373422C4B41414B37422C5141415132472C534143784539452C4B41414B522C4B41414B73452C4B41375A4C2C5541365A734271432C4B41414B70492C4541414F69492C47414378422C6942414152442C47414132422F462C4B41414B37';
wwv_flow_api.g_varchar2_table(92) := '422C514141514F2C5741416373422C4B41414B37422C5141415132472C53414533442C6341415269422C454143502F462C4B41414B522C4B41414B79442C554141552C534141552C594141612B432C47414335422C6942414152442C474143502F462C4B';
wwv_flow_api.g_varchar2_table(93) := '41414B67462C55414A4C68462C4B41414B522C4B41414B73452C4B412F5A4C2C55412B5A734271432C4B41414B70492C4541414F69492C51413145764374492C4541414D73452C4B41414B2C574141612B442C4541414D2C6B44416B4674436C422C6541';
wwv_flow_api.g_varchar2_table(94) := '4167422C4341435A32422C4F4141512C5341415576422C474143646A462C4B41414B552C5141415175452C4B414B72427A432C574141592C534141556E422C4741436C422C4941414970422C45414149442C4B41414B37422C5141435473492C45414157';
wwv_flow_api.g_varchar2_table(95) := '7A472C4B41414B4C2C4D413362542C6B424143412C6B42413462504B2C4B41414B4A2C5541434C36472C474141592C6F4241455A78472C454141457A422C6141434679422C4541414576422C574141592C4741456475422C4541414576422C594143462B';
wwv_flow_api.g_varchar2_table(96) := '482C474141592C69424147684270462C4541414971462C4F41414F2C51414151502C4B41414B2C514141534D2C4741433542452C6141416135492C4541414F6B432C4541414568422C4F4143744279482C4F41414F2C67424143527A472C454141457A42';
wwv_flow_api.g_varchar2_table(97) := '2C5741434636432C4541414971462C4F41414F2C694341416D4339492C454141552C754341436E442B492C6141416135492C4541414F6B432C4541414568422C4F4147744279482C4F41414F2C5941455A72462C4541414971462C4F41414F2C6D434141';
wwv_flow_api.g_varchar2_table(98) := '714339492C454141552C6D424143724475492C4B41414B2C694241416B426C472C4541414576422C5741437A4269492C6141416135492C4541414F6B432C4541414576422C5541415975422C454141456C422C594141636B422C454141456A422C634147';
wwv_flow_api.g_varchar2_table(99) := '704430482C4F41414F2C634145684272462C4541414971462C4F41414F2C5741476631432C514141532C5741434C2C4941414939442C45414151462C4B41414B472C5141436269422C4541414D70422C4B41414B4C2C4D4141512C4F4141532C4D414335';
wwv_flow_api.g_varchar2_table(100) := '4236442C4541414978442C4B41414B522C4B41414B6A422C5741415736432C47414B37422C4F41484970422C4B41414B4A2C5541434C34442C4741414B78442C4B41414B4C2C4D4141514F2C4541414D79432C514141557A432C4541414D30432C554141';
wwv_flow_api.g_varchar2_table(101) := '59592C4541414978442C4B41414B482C534145314432442C47414758532C614141632C574143562C4F41414F6A452C4B41414B522C4B41414B6F482C53413964502C6942416965646C432C574141592C574143522C494141497A452C45414149442C4B41';
wwv_flow_api.g_varchar2_table(102) := '414B37422C514143542B422C45414151462C4B41414B472C5141456A422C4F414149482C4B41414B4C2C4D4143454F2C4541414D79432C5141415533432C4B41414B482C51414155492C4541414533422C514145724334422C4541414D30432C53414157';
wwv_flow_api.g_varchar2_table(103) := '35432C4B41414B482C51414155492C4541414533422C53414737436D462C514141532C534141556C462C45414155472C4741437A422C4941414936462C4541414B73432C4541414F432C45414151432C4541415776442C4541414779432C4541436C4368';
wwv_flow_api.g_varchar2_table(104) := '472C45414149442C4B41414B37422C514143542B422C45414151462C4B41414B472C5141436269422C4541414D70422C4B41414B4C2C4D4141512C4F4141532C4D4143354271482C4541416568482C4B41414B69452C654143704267442C454141536A48';
wwv_flow_api.g_varchar2_table(105) := '2C4B41414B542C51414564552C454141457A422C61414346452C474141592C4741475A73492C494141694274492C4941436A42482C4541415779422C4B41414B542C53414344552C4541414533422C55414362432C4541415730422C4541414533422C53';
wwv_flow_api.g_varchar2_table(106) := '41476A42432C4541415730422C4541414533422C5141435432422C454141457A422C57414346442C4541415730422C4541414533422C51414562492C474141592C4541495A482C4741444A67472C4541414D76452C4B41414B30452C67424145506E472C';
wwv_flow_api.g_varchar2_table(107) := '4541415767472C4741476674452C454141457A422C59414163442C474141592C4941433542412C454141572C47414558412C454141572C4941435879422C4B41414B542C5141415568422C47414566472C49414341482C454141572C4541435830422C45';
wwv_flow_api.g_varchar2_table(108) := '41414531422C534141572C4741456A4273492C4541415137472C4B41414B4C2C4D4141514F2C4541414D79432C514141557A432C4541414D30432C5341433343592C454141496A462C4541434179422C4B41414B4A2C5541434C34442C4541414971442C';
wwv_flow_api.g_varchar2_table(109) := '4541415174492C4541415779422C4B41414B482C5341456843472C4B41414B522C4B41414B34432C4941414968422C4541414B6F432C4741436E4279432C454141536A472C4B41414B522C4B41414B73452C4B41414B6A472C47414570426D432C4B4141';
wwv_flow_api.g_varchar2_table(110) := '4B4A2C5341434C6B482C4541415339472C4B41414B4E2C4F41436471482C45414159462C4541415172442C4541414978442C4B41414B482C554145374269482C4541415339472C4B41414B502C5141436473482C4541415976442C4741455839452C4741';
wwv_flow_api.g_varchar2_table(111) := '6D424473422C4B41414B522C4B41414B30432C5341726A424A2C674241736A42446A432C4541414536452C554143486D422C4541414F452C4B41414B2C6942414169422C4741414F412C4B41414B70492C4541414F6B432C454141456C422C6141457444';
wwv_flow_api.g_varchar2_table(112) := '2B482C4541414F492C53417442486A482C454141457A422C5741494673492C4541414F4B2C4F41416F422C4941416235492C4941456479422C4B41414B522C4B41414B6F452C59417A6942522C6742413069424733442C454141457A422C594141657942';
wwv_flow_api.g_varchar2_table(113) := '2C4541414536452C55414370426D422C4541414F452C4B41414B2C6942414169422C4741414D412C4B41414B70492C4541414F6B432C454141456A422C634145724438482C4541414F4D2C5141455070482C4B41414B4C2C4D41434C6C432C4541414B67';
wwv_flow_api.g_varchar2_table(114) := '492C6341416371422C45414151432C4741453342744A2C4541414B2B482C6541416573422C45414151432C49415368432F472C4B41414B4A2C5341434C6B482C4541415339472C4B41414B502C5141436473482C4541415976442C4941455A73442C4541';
wwv_flow_api.g_varchar2_table(115) := '415339472C4B41414B4E2C4F41436471482C45414159462C4541415172442C4541414978442C4B41414B482C5341453742472C4B41414B4C2C4D41434C6C432C4541414B67492C6341416371422C45414151432C4741453342744A2C4541414B2B482C65';
wwv_flow_api.g_varchar2_table(116) := '41416573422C45414151432C474145354239472C454141457A422C5941434673492C4541414F4B2C4F414171422C494141644A2C4741476C422F472C4B41414B4E2C4F41414F30432C4941414968422C4541414D6F432C4541414978442C4B41414B482C';
wwv_flow_api.g_varchar2_table(117) := '514141572C4D41433143472C4B41414B502C5141415132432C4941414968422C4541414B2C4B4145684231432C47414161482C4941416130492C47414157442C494141694274492C4B4143784475422C4541414576422C55414159412C4541436475422C';
wwv_flow_api.g_varchar2_table(118) := '4541414531422C53414157412C4541456232422C4541414D32422C534141532C5741415736442C4F41414F2C59414159432C514141512C554143724433462C4B41414B71482C534141532C534141552C474141492C434143784239492C5341415530422C';
wwv_flow_api.g_varchar2_table(119) := '4541414531422C5341435A472C5541415775422C4541414576422C5541436234492C6141416374482C4B41414B542C63414D6E432C4941414967492C454141632C45414364432C454141592C4541496842684B2C4541414536432C4B41414B6F482C5341';
wwv_flow_api.g_varchar2_table(120) := '4153432C614141652C53414155432C47414372432C49414149432C4541414F432C45414155432C4541436A426C4A2C4541414D2B492C474141572C454141492C4541437242492C45414157764B2C45414145774B2C53414153432C65414531422C4B4141';
wwv_flow_api.g_varchar2_table(121) := '49562C454141632C4741414B432C454141592C474179426E432C4F416A42414D2C47414C41442C45414157724B2C45414145304B2C2B4441435278432C4F41414F2C5941435079432C494141492C734241434A432C494141494C2C4941454D4D2C4D4141';
wwv_flow_api.g_varchar2_table(122) := '4D4E2C4B4143562C49414350442C4741414F6C4A2C454143482B492C47414157492C4541415331462C53414153432C4741414733452C4B414368436D4B2C4741414F6C4A2C474145506B4A2C4741414F2C4741414B412C4541414D442C454141532F462C';
wwv_flow_api.g_varchar2_table(123) := '534143334238462C45414151432C4541415335462C4741414736462C4D41497642462C47414130422C4941416A42412C4541414D39462C534141694269472C4541415331462C53414153432C4741414733452C494141616F4B2C454141537A462C474141';
wwv_flow_api.g_varchar2_table(124) := '472C674241432F4573462C45414151704B2C45414145304B2C2B4441434C78432C4F41414F2C5941435079432C494141492C734241417342522C454141552C4F4141532C5941476C44432C47414153412C4541414D39462C4F4141532C47414378423846';
wwv_flow_api.g_varchar2_table(125) := '2C4541414D2F462C5341415368452C474141576B472C5341436E422C514146582C47414F4A76472C474141452C57414545412C45414145774B2C534141534D2C4D41414D31482C474141472C6B4241416B422C5741436C4334472C474141612C4B414364';
wwv_flow_api.g_varchar2_table(126) := '35472C474141472C6B4241416B422C574143704234472C474141612C4B41436435472C474141472C634141632C574143684232472C474141652C4B4143684233472C474141472C654141652C5741436A4232472C474141652C51414D6E426C482C4B4141';
wwv_flow_api.g_varchar2_table(127) := '4B6B492C5341434C6C492C4B41414B6B492C51414151432C6F4241416D422C534141556A472C47414374432C494141496B472C4541414D6A4C2C454141452C4941414D2B452C4741436C426B472C45414149432C514141512C654141656E442C4D41414B';
wwv_flow_api.g_varchar2_table(128) := '2C57414576426B442C454141496E472C474141472C6141435239452C4541414577432C4D41414D79482C534141532C534141552C614141612C53417A714235442C43412B71424770482C4B41414B73492C4F41415174492C4B41414B35432C4B41414D34';
wwv_flow_api.g_varchar2_table(129) := '432C4B41414B3343222C2266696C65223A227769646765742E73706C69747465722E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(71508906284870965)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'libraries/widget.splitter.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A207468652064656661756C74207A2D696E64657820697320746F6F206C6F772069662074686520726567696F6E20636F6E7461696E7320616E204947202A2F0A2E666F732D53706C6974746572202E612D53706C69747465722D626172482C0A2E66';
wwv_flow_api.g_varchar2_table(2) := '6F732D53706C6974746572202E612D53706C69747465722D62617256207B0A20207A2D696E6465783A203430303B0A7D0A0A2E666F732D53706C6974746572203E202E726F77207B0A20206F766572666C6F773A206175746F3B0A20206D617267696E2D';
wwv_flow_api.g_varchar2_table(3) := '6C6566743A203070783B0A20206D617267696E2D72696768743A203070783B0A7D0A0A2E666F732D53706C6974746572203E202E726F77203E202E636F6C7B0A202070616464696E672D6C6566743A203070783B0A202070616464696E672D7269676874';
wwv_flow_api.g_varchar2_table(4) := '3A203070783B0A7D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139082106810556758)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'css/style.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227374796C652E637373225D2C226E616D6573223A5B5D2C226D617070696E6773223A22414143412C38422C434143412C38422C434143452C572C434147462C6B422C434143452C612C4341';
wwv_flow_api.g_varchar2_table(2) := '43412C612C434143412C632C434147462C75422C434143452C632C434143412C65222C2266696C65223A227374796C652E637373222C22736F7572636573436F6E74656E74223A5B222F2A207468652064656661756C74207A2D696E6465782069732074';
wwv_flow_api.g_varchar2_table(3) := '6F6F206C6F772069662074686520726567696F6E20636F6E7461696E7320616E204947202A2F5C6E2E666F732D53706C6974746572202E612D53706C69747465722D626172482C5C6E2E666F732D53706C6974746572202E612D53706C69747465722D62';
wwv_flow_api.g_varchar2_table(4) := '617256207B5C6E20207A2D696E6465783A203430303B5C6E7D5C6E5C6E2E666F732D53706C6974746572203E202E726F77207B5C6E20206F766572666C6F773A206175746F3B5C6E20206D617267696E2D6C6566743A203070783B5C6E20206D61726769';
wwv_flow_api.g_varchar2_table(5) := '6E2D72696768743A203070783B5C6E7D5C6E5C6E2E666F732D53706C6974746572203E202E726F77203E202E636F6C7B5C6E202070616464696E672D6C6566743A203070783B5C6E202070616464696E672D72696768743A203070783B5C6E7D5C6E225D';
wwv_flow_api.g_varchar2_table(6) := '7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139082445037556759)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'css/style.css.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D53706C6974746572202E612D53706C69747465722D626172482C2E666F732D53706C6974746572202E612D53706C69747465722D626172567B7A2D696E6465783A3430307D2E666F732D53706C69747465723E2E726F777B6F766572666C6F';
wwv_flow_api.g_varchar2_table(2) := '773A6175746F3B6D617267696E2D6C6566743A303B6D617267696E2D72696768743A307D2E666F732D53706C69747465723E2E726F773E2E636F6C7B70616464696E672D6C6566743A303B70616464696E672D72696768743A307D0A2F2A2320736F7572';
wwv_flow_api.g_varchar2_table(3) := '63654D617070696E6755524C3D7374796C652E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139082848398556759)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'css/style.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C20617065782C242C2476202A2F0A0A77696E646F772E464F53203D2077696E646F772E464F53207C7C207B7D3B0A0A2F2A2A0A202A2040706172616D207B6F626A6563747D202020636F6E66696720202020202020202020202020';
wwv_flow_api.g_varchar2_table(2) := '202020202020202020202020436F6E66696775726174696F6E206F626A65637420636F6E7461696E696E6720616C6C206F7074696F6E730A202A2040706172616D207B737472696E677D202020636F6E6669672E726564696F6E67496420202020202020';
wwv_flow_api.g_varchar2_table(3) := '202020202020202053706C697474657220726567696F6E2049440A202A2040706172616D207B737472696E677D202020636F6E6669672E6F7269656E746174696F6E202020202020202020202020205B686F72697A6F6E74616C207C2076657274696361';
wwv_flow_api.g_varchar2_table(4) := '6C5D0A202A2040706172616D207B737472696E677D202020636F6E6669672E646972656374696F6E2020202020202020202020202020205B626567696E207C20656E645D0A202A2040706172616D207B6E756D6265727D2020205B636F6E6669672E706F';
wwv_flow_api.g_varchar2_table(5) := '736974696F6E5D202020202020202020202020202053706C6974746572207374617274696E6720706F736974696F6E20696E20706978656C730A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E636F6C6C61707365645D202020';
wwv_flow_api.g_varchar2_table(6) := '2020202020202020202057686574686572207468652073706C697474657220697320636F6C6C6170736564206F6E2070616765206C6F61640A202A2040706172616D207B737472696E677D2020205B636F6E6669672E706F736974696F6E436F64655D20';
wwv_flow_api.g_varchar2_table(7) := '20202020202020202053706C6974746572207374617274696E6720706F736974696F6E20617320612070726F706F7274696F6E205B30207C20312F34207C20312F33207C20312F32207C20322F33207C20332F345D0A202A2040706172616D207B66756E';
wwv_flow_api.g_varchar2_table(8) := '6374696F6E7D205B636F6E6669672E706F736974696F6E46756E6374696F6E5D202020202020412066756E6374696F6E2072657475726E696E672074686520696E697469616C2073706C697474657220706F736974696F6E20696E20706978656C730A20';
wwv_flow_api.g_varchar2_table(9) := '2A2040706172616D207B6E756D6265727D202020636F6E6669672E6D696E53697A6520202020202020202020202020202020204D696E696D756D2070616E656C2073697A650A202A2040706172616D207B66756E6374696F6E7D20636F6E6669672E6865';
wwv_flow_api.g_varchar2_table(10) := '6967687446756E6374696F6E20202020202020202020412066756E6374696F6E2072657475726E696E672074686520726567696F6E2068656967687420696E20706978656C730A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E70';
wwv_flow_api.g_varchar2_table(11) := '65727369737453746174655072656620202020202020205768657468657220746F2073746F726520746865206C617465737420706F736974696F6E206F6E20746865207365727665720A202A2040706172616D207B626F6F6C65616E7D2020636F6E6669';
wwv_flow_api.g_varchar2_table(12) := '672E7065727369737453746174654C6F63616C202020202020205768657468657220746F2073746F726520746865206C617465737420706F736974696F6E20696E206C6F63616C2073746F726167650A202A2040706172616D207B626F6F6C65616E7D20';
wwv_flow_api.g_varchar2_table(13) := '20636F6E6669672E6C617A7952656E6465722020202020202020202020202020496E697469616C697A6573207468652073706C6974746572207768656E2074686520726567696F6E206265636F6D65732076697369626C650A202A2040706172616D207B';
wwv_flow_api.g_varchar2_table(14) := '737472696E677D2020205B636F6E6669672E616A61784964656E7469666965725D2020202020202020414A4158206964656E74696669657220726571756972656420627920706572736973745374617465507265660A202A2040706172616D207B626F6F';
wwv_flow_api.g_varchar2_table(15) := '6C65616E7D2020636F6E6669672E636F6E74696E756F7573526573697A652020202020202020436F6E74696E756F75736C7920726573697A6520737562726567696F6E73206173207468652073706C697474657220697320647261676765640A202A2040';
wwv_flow_api.g_varchar2_table(16) := '706172616D207B626F6F6C65616E7D2020636F6E6669672E63616E436F6C6C617073652020202020202020202020202057686574686572207468652073706C69747465722063616E20626520636F6C6C61707365640A202A2040706172616D207B626F6F';
wwv_flow_api.g_varchar2_table(17) := '6C65616E7D2020636F6E6669672E64726167436F6C6C6170736520202020202020202020202057686574686572206472616767696E67206F76657220746865206D696E53697A652077696C6C20636F6C6C61707365207468652073706C69747465720A20';
wwv_flow_api.g_varchar2_table(18) := '2A2040706172616D207B626F6F6C65616E7D2020636F6E6669672E636F6E7461696E73496672616D652020202020202020202057686574686572206F6E65206F662074686520737562726567696F6E7320636F6E7461696E7320616E20694672616D650A';
wwv_flow_api.g_varchar2_table(19) := '202A2040706172616D207B737472696E677D2020205B636F6E6669672E637573746F6D53656C6563746F725D2020202020202020437573746F6D2073656C6563746F72206964656E74696679696E67207468652073706C697474657220656C656D656E74';
wwv_flow_api.g_varchar2_table(20) := '20756E64657220746865207265616C20726567696F6E0A202A2040706172616D207B6E756D6265727D2020205B636F6E6669672E7374657053697A655D2020202020202020202020202020537465702073697A6520696E20706978656C207768656E2064';
wwv_flow_api.g_varchar2_table(21) := '72616767696E670A202A2040706172616D207B6E756D6265727D2020205B636F6E6669672E6B65795374657053697A655D2020202020202020202020537465702073697A6520696E20706978656C207768656E206D6F76696E6720766961206B6579626F';
wwv_flow_api.g_varchar2_table(22) := '6172640A202A2040706172616D207B737472696E677D2020205B636F6E6669672E7469746C655D202020202020202020202020202020202053706C6974746572207469746C65206D6573736167650A202A2040706172616D207B737472696E677D202020';
wwv_flow_api.g_varchar2_table(23) := '5B636F6E6669672E7469746C65436F6C6C617073655D20202020202020202053706C697474657220627574746F6E207469746C65206D657373616765207768656E20657870616E6465640A202A2040706172616D207B737472696E677D2020205B636F6E';
wwv_flow_api.g_varchar2_table(24) := '6669672E7469746C65526573746F72655D2020202020202020202053706C697474657220627574746F6E207469746C65206D657373616765207768656E20636F6C6C61707365640A202A2040706172616D207B66756E6374696F6E7D205B636F6E666967';

wwv_flow_api.g_varchar2_table(25) := '2E6368616E676546756E6374696F6E5D2020202020202020412066756E6374696F6E20746F20626520696E766F6B65642065766572792074696D65207468652073706C6974746572206D6F7665732E2066756E6374696F6E28652C207569297B7D0A202A';
wwv_flow_api.g_varchar2_table(26) := '2040706172616D207B6E756D6265727D2020205B636F6E6669672E70616464696E6746697273745D202020202020202020205468652070616464696E6720696E20706978656C73206F662074686520666972737420737562726567696F6E0A202A204070';
wwv_flow_api.g_varchar2_table(27) := '6172616D207B6E756D6265727D2020205B636F6E6669672E70616464696E675365636F6E645D2020202020202020205468652070616464696E6720696E20706978656C73206F6620746865207365636F6E6420737562726567696F6E0A202A2F0A286675';
wwv_flow_api.g_varchar2_table(28) := '6E6374696F6E20282429207B0A202020202F2F20636F6E7374616E74730A2020202076617220435F4A45545F53454C4543544F52203D20275B69642A3D225F6A6574225D272C0A2020202020202020435F464F535F53504C49545445525F434C41535320';
wwv_flow_api.g_varchar2_table(29) := '3D2027666F732D53706C6974746572272C0A2020202020202020435F464F535F53504C49545445525F524547494F4E5F434C415353203D20435F464F535F53504C49545445525F434C415353202B20272D726567696F6E273B0A0A2020202077696E646F';
wwv_flow_api.g_varchar2_table(30) := '772E464F532E73706C6974746572203D2066756E6374696F6E2028636F6E6669672C20696E6974466E29207B0A0A202020202020202076617220706C7567696E4E616D65203D2027464F53202D2053706C6974746572273B0A2020202020202020617065';
wwv_flow_api.g_varchar2_table(31) := '782E64656275672E696E666F28706C7567696E4E616D652C20636F6E666967293B0A0A202020202020202076617220706F736974696F6E2C20636F6C6C61707365642C2073706C6974746572243B0A0A20202020202020202F2F20416C6C6F7720746865';
wwv_flow_api.g_varchar2_table(32) := '20646576656C6F70657220746F20706572666F726D20616E79206C617374202863656E7472616C697A656429206368616E676573207573696E67204A61766173637269707420496E697469616C697A6174696F6E20436F64652073657474696E670A2020';
wwv_flow_api.g_varchar2_table(33) := '20202020202069662028696E6974466E20696E7374616E63656F662046756E6374696F6E29207B0A202020202020202020202020696E6974466E2E63616C6C28746869732C20636F6E666967293B0A20202020202020207D0A0A20202020202020207370';
wwv_flow_api.g_varchar2_table(34) := '6C697474657224203D202428272E636F6E7461696E6572272C20272327202B20636F6E6669672E726567696F6E4964292E666972737428293B0A0A202020202020202066756E6374696F6E20696E697453706C69747465722829207B0A20202020202020';
wwv_flow_api.g_varchar2_table(35) := '20202020202F2F206669726520746865206265666F72652072656E646572206576656E740A202020202020202020202020617065782E6576656E742E7472696767657228272327202B20636F6E6669672E726567696F6E49642C2027666F732D73706C69';
wwv_flow_api.g_varchar2_table(36) := '747465722D6265666F72652D72656E646572272C20636F6E666967293B0A0A20202020202020202020202073706C6974746572242E616464436C61737328435F464F535F53504C49545445525F434C415353293B0A20202020202020202020202073706C';
wwv_flow_api.g_varchar2_table(37) := '6974746572242E6368696C6472656E28292E616464436C61737328435F464F535F53504C49545445525F524547494F4E5F434C415353293B0A20202020202020202020202073706C6974746572242E6174747228276964272C20636F6E6669672E726567';
wwv_flow_api.g_varchar2_table(38) := '696F6E4964202B20275F73706C697474657227293B0A0A20202020202020202020202069662028636F6E6669672E70616464696E67466972737429207B0A2020202020202020202020202020202073706C6974746572242E6368696C6472656E28292E65';
wwv_flow_api.g_varchar2_table(39) := '712830292E637373282770616464696E67272C20636F6E6669672E70616464696E674669727374207C7C2027707827293B0A2020202020202020202020207D0A20202020202020202020202069662028636F6E6669672E70616464696E675365636F6E64';
wwv_flow_api.g_varchar2_table(40) := '29207B0A2020202020202020202020202020202073706C6974746572242E6368696C6472656E28292E65712831292E637373282770616464696E67272C20636F6E6669672E70616464696E675365636F6E64207C7C2027707827293B0A20202020202020';
wwv_flow_api.g_varchar2_table(41) := '20202020207D0A0A2020202020202020202020202F2F2043616C63756C617465732074686520696E697469616C20706F736974696F6E206F66207468652073706C69747465722C20616E6420616C736F206F6E20726573697A696E67206576656E74730A';
wwv_flow_api.g_varchar2_table(42) := '20202020202020202020202066756E6374696F6E2063616C63756C617465506F736974696F6E2829207B0A0A202020202020202020202020202020202F2F2063616C63756C6174652074686520706F736974696F6E206F7574206F662061206E756D6265';
wwv_flow_api.g_varchar2_table(43) := '72206F66206F7074696F6E730A2020202020202020202020202020202069662028636F6E6669672E706F736974696F6E46756E6374696F6E29207B0A2020202020202020202020202020202020202020706F736974696F6E203D20636F6E6669672E706F';
wwv_flow_api.g_varchar2_table(44) := '736974696F6E46756E6374696F6E28293B0A202020202020202020202020202020207D20656C73652069662028636F6E6669672E706F736974696F6E436F646520213D3D20756E646566696E656429207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(45) := '202076617220636F6465203D20636F6E6669672E706F736974696F6E436F64652C0A20202020202020202020202020202020202020202020202073697A65203D2028636F6E6669672E6F7269656E746174696F6E203D3D2027686F72697A6F6E74616C27';
wwv_flow_api.g_varchar2_table(46) := '203F2073706C6974746572242E77696474682829203A20636F6E6669672E68656967687446756E6374696F6E2829293B0A0A20202020202020202020202020202020202020202F2F206170706C79696E672074686520302C20312F342C20312F332C2031';
wwv_flow_api.g_varchar2_table(47) := '2F32202E2E2E2070726F706F7274696F6E730A202020202020202020202020202020202020202076617220706F736974696F6E436F6465417272203D20636F64652E73706C697428272F27293B0A2020202020202020202020202020202020202020706F';
wwv_flow_api.g_varchar2_table(48) := '736974696F6E203D20706F736974696F6E436F64654172722E6C656E677468203E2031203F204D6174682E726F756E642873697A65202A20706F736974696F6E436F64654172725B305D202F20706F736974696F6E436F64654172725B315D29203A2030';
wwv_flow_api.g_varchar2_table(49) := '3B0A0A202020202020202020202020202020202020202069662028706F736974696F6E203E203029207B0A202020202020202020202020202020202020202020202020706F736974696F6E202D3D20343B202F2F2068616C66207468652073706C697474';
wwv_flow_api.g_varchar2_table(50) := '65722077696474680A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020202020202072657475726E20706F736974696F6E3B0A2020202020202020202020207D0A0A202020';
wwv_flow_api.g_varchar2_table(51) := '2020202020202020202F2F20436163756C617465207468652073706C697474657220706F736974696F6E0A202020202020202020202020636F6E6669672E696E697469616C506F736974696F6E203D2063616C63756C617465506F736974696F6E28293B';
wwv_flow_api.g_varchar2_table(52) := '0A0A2020202020202020202020202F2F206F766572726964652069662050657273697374205374617465206173205573657220507265666572656E636520697320656E61626C65640A20202020202020202020202069662028636F6E6669672E70657273';
wwv_flow_api.g_varchar2_table(53) := '69737453746174655072656620262620636F6E6669672E706F736974696F6E20213D3D20756E646566696E656420262620636F6E6669672E636F6C6C617073656420213D3D20756E646566696E656429207B0A2020202020202020202020202020202070';
wwv_flow_api.g_varchar2_table(54) := '6F736974696F6E203D20636F6E6669672E706F736974696F6E3B0A20202020202020202020202020202020636F6C6C6170736564203D20636F6E6669672E636F6C6C61707365643B0A2020202020202020202020207D0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(55) := '2F2F206F76657272696465206966205065727369737420537461746520696E204C6F63616C2053746F7261676520697320656E61626C65640A202020202020202020202020766172206C6F63616C53746F72616765537570706F7274203D20617065782E';
wwv_flow_api.g_varchar2_table(56) := '73746F726167652E6861734C6F63616C53746F72616765537570706F727428293B0A20202020202020202020202066756E6374696F6E206765744C6F63616C53746F726167654974656D4E616D652829207B0A2020202020202020202020202020202072';
wwv_flow_api.g_varchar2_table(57) := '657475726E2027666F732D73706C69747465722D27202B202476282770466C6F7749642729202B20272D27202B202476282770466C6F775374657049642729202B20272D27202B20636F6E6669672E726567696F6E49643B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(58) := '207D0A20202020202020202020202069662028636F6E6669672E7065727369737453746174654C6F63616C202626206C6F63616C53746F72616765537570706F727429207B0A20202020202020202020202020202020766172206974656D203D206C6F63';
wwv_flow_api.g_varchar2_table(59) := '616C53746F726167652E6765744974656D286765744C6F63616C53746F726167654974656D4E616D652829293B0A20202020202020202020202020202020696620286974656D29207B0A2020202020202020202020202020202020202020747279207B0A';
wwv_flow_api.g_varchar2_table(60) := '2020202020202020202020202020202020202020202020207661722076616C7565203D204A534F4E2E7061727365286974656D293B0A2020202020202020202020202020202020202020202020206966202876616C75652E706F736974696F6E20213D3D';
wwv_flow_api.g_varchar2_table(61) := '20756E646566696E656429207B0A20202020202020202020202020202020202020202020202020202020706F736974696F6E203D2076616C75652E706F736974696F6E3B0A2020202020202020202020202020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(62) := '202020202020202020202020202020202020206966202876616C75652E636F6C6C617073656420213D3D20756E646566696E656429207B0A20202020202020202020202020202020202020202020202020202020636F6C6C6170736564203D2076616C75';
wwv_flow_api.g_varchar2_table(63) := '652E636F6C6C61707365643B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D20636174636820286529207B0A202020202020202020202020202020202020202020202020617065';
wwv_flow_api.g_varchar2_table(64) := '782E64656275672E6572726F7228706C7567696E4E616D652C2027436F756C64206E6F7420706172736520707265666572656E63652066726F6D206C6F63616C2073746F72616765272C206974656D293B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(65) := '20207D0A202020202020202020202020202020207D0A2020202020202020202020207D20656C73652069662028636F6E6669672E7065727369737453746174654C6F63616C20262620216C6F63616C53746F72616765537570706F727429207B0A202020';
wwv_flow_api.g_varchar2_table(66) := '20202020202020202020202020617065782E64656275672E7761726E28706C7567696E4E616D652C202742726F7773657220646F6573206E6F742068617665204C6F63616C2053746F7261676520537570706F727427293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(67) := '207D0A0A20202020202020202020202066756E6374696F6E207365744865696768742829207B0A2020202020202020202020202020202073706C6974746572242E68656967687428636F6E6669672E68656967687446756E6374696F6E2829293B0A2020';
wwv_flow_api.g_varchar2_table(68) := '202020202020202020207D0A0A20202020202020202020202066756E6374696F6E206669784D6973632829207B0A202020202020202020202020202020202F2F2074616B65732063617265206F6620666978696E6720616E7920696E7465726163746976';
wwv_flow_api.g_varchar2_table(69) := '65207265706F727420686561646572730A2020202020202020202020202020202073706C6974746572242E66696E6428272E6A732D737469636B795461626C6548656164657227292E747269676765722827666F726365726573697A6527293B0A202020';
wwv_flow_api.g_varchar2_table(70) := '2020202020202020202020202069662028636F6E6669672E726573697A654A657443686172747329207B0A2020202020202020202020202020202020202020726573697A654A6574436861727473283530293B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(71) := '7D0A2020202020202020202020207D0A0A2020202020202020202020202F2F207365742074686520686569676874206F66206F75722073706C697474657220636F6E7461696E657220726567696F6E0A2020202020202020202020207365744865696768';
wwv_flow_api.g_varchar2_table(72) := '7428293B0A0A2020202020202020202020202F2F20736574757020726573706F6E7369766520726573697A696E67200A20202020202020202020202073706C6974746572242E6F6E2827726573697A65272C2066756E6374696F6E202829207B0A202020';
wwv_flow_api.g_varchar2_table(73) := '20202020202020202020202020766172206E6577506F736974696F6E3B0A202020202020202020202020202020206966202821636F6E6669672E70657273697374537461746550726566202626202873706C6974746572242E73706C697474657228276F';
wwv_flow_api.g_varchar2_table(74) := '7074696F6E272C2027706F736974696F6E2729203D3D20636F6E6669672E696E697469616C506F736974696F6E2929207B0A2020202020202020202020202020202020202020636F6E6669672E696E697469616C506F736974696F6E203D206E6577506F';
wwv_flow_api.g_varchar2_table(75) := '736974696F6E203D2063616C63756C617465506F736974696F6E28293B0A202020202020202020202020202020202020202073706C6974746572242E73706C697474657228276F7074696F6E272C2027706F736974696F6E272C206E6577506F73697469';
wwv_flow_api.g_varchar2_table(76) := '6F6E293B0A202020202020202020202020202020207D0A2020202020202020202020202020202073657448656967687428293B0A202020202020202020202020202020206669784D69736328293B0A2020202020202020202020207D293B0A0A20202020';
wwv_flow_api.g_varchar2_table(77) := '20202020202020202F2F20496E697469616C697A65207468652073706C69747465720A20202020202020202020202073706C6974746572242E73706C6974746572287B0A202020202020202020202020202020206F7269656E746174696F6E3A20636F6E';
wwv_flow_api.g_varchar2_table(78) := '6669672E6F7269656E746174696F6E2C0A20202020202020202020202020202020706F736974696F6E656446726F6D3A20636F6E6669672E646972656374696F6E2C0A202020202020202020202020202020206D696E53697A653A20636F6E6669672E6D';
wwv_flow_api.g_varchar2_table(79) := '696E53697A652C0A20202020202020202020202020202020706F736974696F6E3A20706F736974696F6E2C0A202020202020202020202020202020206E6F436F6C6C617073653A2021636F6E6669672E63616E436F6C6C617073652C0A20202020202020';
wwv_flow_api.g_varchar2_table(80) := '20202020202020202064726167436F6C6C617073653A20636F6E6669672E64726167436F6C6C617073652C0A20202020202020202020202020202020636F6C6C61707365643A20636F6C6C6170736564207C7C2028706F736974696F6E203D3D20302026';
wwv_flow_api.g_varchar2_table(81) := '262021636F6E6669672E6C617A7952656E646572292C0A20202020202020202020202020202020736E61703A20636F6E6669672E7374657053697A652C0A20202020202020202020202020202020696E633A20636F6E6669672E6B65795374657053697A';
wwv_flow_api.g_varchar2_table(82) := '652C0A202020202020202020202020202020207265616C54696D653A20636F6E6669672E636F6E74696E756F7573526573697A652C0A20202020202020202020202020202020696672616D654669783A20636F6E6669672E636F6E7461696E7349667261';
wwv_flow_api.g_varchar2_table(83) := '6D652C0A20202020202020202020202020202020726573746F7265546578743A20636F6E6669672E7469746C65526573746F72652C0A20202020202020202020202020202020636F6C6C61707365546578743A20636F6E6669672E7469746C65436F6C6C';
wwv_flow_api.g_varchar2_table(84) := '617073652C0A20202020202020202020202020202020696D6D6564696174655669736962696C697479436865636B3A20636F6E6669672E6C617A7952656E6465722C0A202020202020202020202020202020207469746C653A20636F6E6669672E746974';
wwv_flow_api.g_varchar2_table(85) := '6C652C0A202020202020202020202020202020206368616E67653A2066756E6374696F6E2028652C20756929207B0A0A202020202020202020202020202020202020202069662028636F6E6669672E7065727369737453746174655072656629207B0A20';
wwv_flow_api.g_varchar2_table(86) := '2020202020202020202020202020202020202020202020617065782E7365727665722E706C7567696E28636F6E6669672E616A61784964656E7469666965722C207B0A202020202020202020202020202020202020202020202020202020207830313A20';
wwv_flow_api.g_varchar2_table(87) := '75692E6C617374506F736974696F6E2C0A202020202020202020202020202020202020202020202020202020207830323A2075692E636F6C6C61707365640A2020202020202020202020202020202020202020202020207D2C207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(88) := '202020202020202020202020202020202020202071756575653A207B0A2020202020202020202020202020202020202020202020202020202020202020616374696F6E3A20276C617A795772697465272C0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(89) := '20202020202020202020202020206E616D653A20277327202B20636F6E6669672E726567696F6E49640A202020202020202020202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020202020207D293B0A';
wwv_flow_api.g_varchar2_table(90) := '20202020202020202020202020202020202020207D0A0A202020202020202020202020202020202020202069662028636F6E6669672E7065727369737453746174654C6F63616C29207B0A20202020202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(91) := '6620286C6F63616C53746F72616765537570706F727429207B0A202020202020202020202020202020202020202020202020202020206C6F63616C53746F726167652E7365744974656D286765744C6F63616C53746F726167654974656D4E616D652829';
wwv_flow_api.g_varchar2_table(92) := '2C204A534F4E2E737472696E67696679287B0A2020202020202020202020202020202020202020202020202020202020202020706F736974696F6E3A2075692E6C617374506F736974696F6E2C0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(93) := '20202020202020202020636F6C6C61707365643A2075692E636F6C6C61707365640A202020202020202020202020202020202020202020202020202020207D29293B0A2020202020202020202020202020202020202020202020207D20656C7365207B0A';
wwv_flow_api.g_varchar2_table(94) := '20202020202020202020202020202020202020202020202020202020617065782E64656275672E7761726E28706C7567696E4E616D652C202742726F7773657220646F6573206E6F742068617665204C6F63616C2053746F7261676520537570706F7274';
wwv_flow_api.g_varchar2_table(95) := '27293B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D0A0A202020202020202020202020202020202020202069662028636F6E6669672E6368616E676546756E6374696F6E2920';
wwv_flow_api.g_varchar2_table(96) := '7B0A202020202020202020202020202020202020202020202020636F6E6669672E6368616E676546756E6374696F6E28652C207569293B0A20202020202020202020202020202020202020207D0A0A202020202020202020202020202020202020202066';
wwv_flow_api.g_varchar2_table(97) := '69784D69736328293B0A0A20202020202020202020202020202020202020202F2F20726573697A657320616E79207375622D73706C6974746572730A202020202020202020202020202020202020202073706C6974746572242E66696E6428272E27202B';
wwv_flow_api.g_varchar2_table(98) := '20435F464F535F53504C49545445525F434C415353292E747269676765722827726573697A6527293B0A0A20202020202020202020202020202020202020202F2F20666972652074686520726573697A65206576656E740A202020202020202020202020';
wwv_flow_api.g_varchar2_table(99) := '2020202020202020617065782E6576656E742E7472696767657228272327202B20636F6E6669672E726567696F6E49642C2027666F732D73706C69747465722D61667465722D726573697A65272C20636F6E666967293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(100) := '202020207D0A2020202020202020202020207D293B0A0A20202020202020202020202069662028636F6E6669672E726573697A654A657443686172747329207B0A202020202020202020202020202020202F2F207765206E65656420746F206164642074';
wwv_flow_api.g_varchar2_table(101) := '686520686569676874206261636B20616674657220746865206368617274206973207265667265736865640A2020202020202020202020202020202073706C6974746572242E6F6E282761706578616674657272656672657368272C2066756E6374696F';
wwv_flow_api.g_varchar2_table(102) := '6E202829207B0A202020202020202020202020202020202020202073706C6974746572242E66696E6428435F4A45545F53454C4543544F52292E68656967687428273130302527293B0A202020202020202020202020202020207D293B0A202020202020';
wwv_flow_api.g_varchar2_table(103) := '202020202020202020202F2F207765206F6E6C79206E65656420746F206368616E67652074686520686569676874206F6E206F757220706172656E7473206F6E6365206173207468657920617265206E6F7420746F75636865642F6368616E6765642062';
wwv_flow_api.g_varchar2_table(104) := '7920415045580A2020202020202020202020202020202073706C6974746572242E66696E6428272E27202B20435F464F535F53504C49545445525F524547494F4E5F434C415353292E656163682866756E6374696F6E2028696E6465782C206974656D29';
wwv_flow_api.g_varchar2_table(105) := '207B0A202020202020202020202020202020202020202024286974656D292E66696E6428435F4A45545F53454C4543544F52292E656163682866756E6374696F6E2028696E6465782C206974656D29207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(106) := '20202020202024286974656D292E706172656E7428292E68656967687428273130302527292E706172656E7428292E68656967687428273130302527293B0A20202020202020202020202020202020202020207D293B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(107) := '2020207D293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20726573697A6520616E79207375622D73706C69747465727320696E2063617365206F662074696D696E67206973737565730A20202020202020202020202073';
wwv_flow_api.g_varchar2_table(108) := '706C6974746572242E66696E6428272E27202B20435F464F535F53504C49545445525F434C415353292E747269676765722827726573697A6527293B0A0A2020202020202020202020202F2F2066697265207468652061667465722072656E6465722065';
wwv_flow_api.g_varchar2_table(109) := '76656E740A202020202020202020202020617065782E6576656E742E7472696767657228272327202B20636F6E6669672E726567696F6E49642C2027666F732D73706C69747465722D61667465722D72656E646572272C20636F6E666967293B0A202020';
wwv_flow_api.g_varchar2_table(110) := '20202020207D0A0A20202020202020202F2F20496E206F7264657220746F2066697420746865204A45542043686172742077697468696E2074686520726567696F6E207765206E65656420746F20736574207468652068656967687420746F2031303025';
wwv_flow_api.g_varchar2_table(111) := '2C206173204150455820636F6E7374616E746C792072656D6F7665732069740A202020202020202066756E6374696F6E20726573697A654A65744368617274732864656C617929207B0A2020202020202020202020202F2F205765206E65656420612073';
wwv_flow_api.g_varchar2_table(112) := '6C696768742064656C617920746F20656E737572652074686520696E6275696C742041504558207265737A696E67206F6E6E20746865204A45542077696467657420697320636F6D706C657465642066697273740A202020202020202020202020736574';
wwv_flow_api.g_varchar2_table(113) := '54696D656F75742866756E6374696F6E202829207B0A202020202020202020202020202020202F2F20726573697A65200A2020202020202020202020202020202073706C6974746572242E66696E6428435F4A45545F53454C4543544F52292E68656967';
wwv_flow_api.g_varchar2_table(114) := '687428273130302527293B0A2020202020202020202020207D2C2064656C6179207C7C20343030293B0A20202020202020207D0A20202020202020202F2A2A0A2020202020202020202A204D61696E20496E697469616C697A6174696F6E0A2020202020';
wwv_flow_api.g_varchar2_table(115) := '202020202A2F0A202020202020202069662028636F6E6669672E6C617A7952656E64657229207B0A202020202020202020202020617065782E7769646765742E7574696C2E6F6E5669736962696C6974794368616E67652873706C6974746572245B305D';
wwv_flow_api.g_varchar2_table(116) := '2C2066756E6374696F6E2028697356697369626C6529207B0A20202020202020202020202020202020636F6E6669672E697356697369626C65203D20697356697369626C653B0A2020202020202020202020202020202069662028697356697369626C65';
wwv_flow_api.g_varchar2_table(117) := '2026262021636F6E6669672E72656E646572656429207B0A2020202020202020202020202020202020202020696E697453706C697474657228293B0A2020202020202020202020202020202020202020636F6E6669672E72656E6465726564203D207472';
wwv_flow_api.g_varchar2_table(118) := '75653B0A202020202020202020202020202020207D20656C73652069662028697356697369626C6520262620636F6E6669672E726573697A654A657443686172747329207B0A20202020202020202020202020202020202020202F2F2074686520726567';
wwv_flow_api.g_varchar2_table(119) := '696F6E20697320616C72656164792072656E646572656420736F207765206F6E6C79206E6565642061206D696E6F722064656C61790A2020202020202020202020202020202020202020726573697A654A6574436861727473283530293B0A2020202020';
wwv_flow_api.g_varchar2_table(120) := '20202020202020202020207D0A2020202020202020202020207D293B0A202020202020202020202020242877696E646F77292E6F6E2827617065787265616479656E64272C2066756E6374696F6E202829207B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(121) := '2F2F2077652061646420617661726961626C65207265666572656E636520746F2061766F6964206C6F7373206F662073636F70650A2020202020202020202020202020202076617220656C203D2073706C6974746572245B305D3B0A2020202020202020';
wwv_flow_api.g_varchar2_table(122) := '20202020202020202F2F207765206861766520746F20616464206120736C696768742064656C617920746F206D616B65207375726520617065782077696467657473206861766520696E697469616C697A65642073696E6365202873757270726973696E';
wwv_flow_api.g_varchar2_table(123) := '676C79292022617065787265616479656E6422206973206E6F7420656E6F7567680A2020202020202020202020202020202073657454696D656F75742866756E6374696F6E202829207B0A2020202020202020202020202020202020202020617065782E';
wwv_flow_api.g_varchar2_table(124) := '7769646765742E7574696C2E7669736962696C6974794368616E676528656C2C2074727565293B0A202020202020202020202020202020207D2C20636F6E6669672E7669736962696C697479436865636B44656C6179207C7C20333030293B0A20202020';
wwv_flow_api.g_varchar2_table(125) := '20202020202020207D293B0A20202020202020207D20656C7365207B0A202020202020202020202020696E697453706C697474657228293B0A20202020202020207D0A202020207D3B0A0A202020202F2A2A200A20202020202A2045787465726E616C20';
wwv_flow_api.g_varchar2_table(126) := '726573697A652068616E646C6572730A20202020202A2F0A20202020242877696E646F77292E6F6E2827726573697A65272C20617065782E7574696C2E6465626F756E63652866756E6374696F6E202829207B0A20202020202020202F2F20726573697A';
wwv_flow_api.g_varchar2_table(127) := '6520616C6C20666F732073706C697474657273206F6E2074686520706167650A20202020202020202428272E27202B20435F464F535F53504C49545445525F434C415353292E747269676765722827726573697A6527293B0A202020207D2C2031303029';
wwv_flow_api.g_varchar2_table(128) := '293B0A0A202020202F2F20555420737065636966696320616374696F6E730A2020202024282723745F547265654E617627292E6F6E28277468656D6534326C61796F75746368616E676564272C2066756E6374696F6E202829207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(129) := '2F2F206669727374207761697420666F722074686520636F6C6C617073652F657870616E6420616E696D6174696F6E20746F2066696E6973680A202020202020202073657454696D656F75742866756E6374696F6E202829207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(130) := '2020202428272E27202B20435F464F535F53504C49545445525F434C415353292E747269676765722827726573697A6527293B0A20202020202020207D2C20323530293B0A202020207D293B0A0A20202020242877696E646F77292E6F6E282761706578';
wwv_flow_api.g_varchar2_table(131) := '7265616479656E64206170657877696E646F77726573697A6564272C2066756E6374696F6E202829207B0A20202020202020202428272E27202B20435F464F535F53504C49545445525F434C415353292E747269676765722827726573697A6527293B0A';
wwv_flow_api.g_varchar2_table(132) := '202020207D293B0A7D2928617065782E6A5175657279293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139083253325556759)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22464F53222C2224222C2273706C6974746572222C22636F6E666967222C22696E6974466E222C22706F736974';
wwv_flow_api.g_varchar2_table(2) := '696F6E222C22636F6C6C6170736564222C2273706C697474657224222C22696E697453706C6974746572222C2263616C63756C617465506F736974696F6E222C22706F736974696F6E46756E6374696F6E222C22756E646566696E6564222C22706F7369';
wwv_flow_api.g_varchar2_table(3) := '74696F6E436F6465222C22636F6465222C2273697A65222C226F7269656E746174696F6E222C227769647468222C2268656967687446756E6374696F6E222C22706F736974696F6E436F6465417272222C2273706C6974222C226C656E677468222C224D';
wwv_flow_api.g_varchar2_table(4) := '617468222C22726F756E64222C2261706578222C226576656E74222C2274726967676572222C22726567696F6E4964222C22616464436C617373222C226368696C6472656E222C22435F464F535F53504C49545445525F434C415353222C226174747222';
wwv_flow_api.g_varchar2_table(5) := '2C2270616464696E674669727374222C226571222C22637373222C2270616464696E675365636F6E64222C22696E697469616C506F736974696F6E222C2270657273697374537461746550726566222C226C6F63616C53746F72616765537570706F7274';
wwv_flow_api.g_varchar2_table(6) := '222C2273746F72616765222C226861734C6F63616C53746F72616765537570706F7274222C226765744C6F63616C53746F726167654974656D4E616D65222C222476222C227065727369737453746174654C6F63616C222C226974656D222C226C6F6361';
wwv_flow_api.g_varchar2_table(7) := '6C53746F72616765222C226765744974656D222C2276616C7565222C224A534F4E222C227061727365222C2265222C226465627567222C226572726F72222C227761726E222C22736574486569676874222C22686569676874222C226669784D69736322';
wwv_flow_api.g_varchar2_table(8) := '2C2266696E64222C22726573697A654A6574436861727473222C226F6E222C226E6577506F736974696F6E222C22706F736974696F6E656446726F6D222C22646972656374696F6E222C226D696E53697A65222C226E6F436F6C6C61707365222C226361';
wwv_flow_api.g_varchar2_table(9) := '6E436F6C6C61707365222C2264726167436F6C6C61707365222C226C617A7952656E646572222C22736E6170222C227374657053697A65222C22696E63222C226B65795374657053697A65222C227265616C54696D65222C22636F6E74696E756F757352';
wwv_flow_api.g_varchar2_table(10) := '6573697A65222C22696672616D65466978222C22636F6E7461696E73496672616D65222C22726573746F726554657874222C227469746C65526573746F7265222C22636F6C6C6170736554657874222C227469746C65436F6C6C61707365222C22696D6D';
wwv_flow_api.g_varchar2_table(11) := '6564696174655669736962696C697479436865636B222C227469746C65222C226368616E6765222C227569222C22736572766572222C22706C7567696E222C22616A61784964656E746966696572222C22783031222C226C617374506F736974696F6E22';
wwv_flow_api.g_varchar2_table(12) := '2C22783032222C227175657565222C22616374696F6E222C226E616D65222C227365744974656D222C22737472696E67696679222C226368616E676546756E6374696F6E222C2265616368222C22696E646578222C22706172656E74222C2264656C6179';
wwv_flow_api.g_varchar2_table(13) := '222C2273657454696D656F7574222C22696E666F222C2246756E6374696F6E222C2263616C6C222C2274686973222C226669727374222C22776964676574222C227574696C222C226F6E5669736962696C6974794368616E6765222C2269735669736962';
wwv_flow_api.g_varchar2_table(14) := '6C65222C2272656E6465726564222C22656C222C227669736962696C6974794368616E6765222C227669736962696C697479436865636B44656C6179222C226465626F756E6365222C226A5175657279225D2C226D617070696E6773223A224141454141';
wwv_flow_api.g_varchar2_table(15) := '2C4F41414F432C4941414D442C4F41414F432C4B41414F2C47412B4233422C53414157432C47414D50462C4F41414F432C49414149452C534141572C53414155432C45414151432C47414570432C49414749432C45414155432C45414157432C4541537A';

wwv_flow_api.g_varchar2_table(16) := '422C53414153432C494167424C2C53414153432C4941474C2C474141494E2C4541414F4F2C69424143504C2C45414157462C4541414F4F2C77424143662C5141413442432C4941417842522C4541414F532C61414134422C43414331432C49414149432C';
wwv_flow_api.g_varchar2_table(17) := '4541414F562C4541414F532C61414364452C45414138422C6341417442582C4541414F592C5941413842522C45414155532C51414155622C4541414F632C694241477845432C4541416B424C2C4541414B4D2C4D41414D2C4D41436A43642C4541415761';
wwv_flow_api.g_varchar2_table(18) := '2C4541416742452C4F4141532C45414149432C4B41414B432C4D41414D522C4541414F492C45414167422C4741414B412C45414167422C4941414D2C47414574462C49414358622C474141592C47414770422C4F41414F412C45412F42586B422C4B4141';
wwv_flow_api.g_varchar2_table(19) := '4B432C4D41414D432C514141512C4941414D74422C4541414F75422C534141552C36424141384276422C4741457845492C454141556F422C53417242532C67424173426E4270422C4541415571422C57414157442C534172424B452C7542417342314274';
wwv_flow_api.g_varchar2_table(20) := '422C4541415575422C4B41414B2C4B41414D33422C4541414F75422C534141572C6141456E4376422C4541414F34422C6341435078422C4541415571422C57414157492C474141472C47414147432C494141492C5541415739422C4541414F34422C6341';
wwv_flow_api.g_varchar2_table(21) := '4167422C4D41456A4535422C4541414F2B422C6541435033422C4541415571422C57414157492C474141472C47414147432C494141492C5541415739422C4541414F2B422C65414169422C4D41794274452F422C4541414F67432C674241416B4231422C';
wwv_flow_api.g_varchar2_table(22) := '49414772424E2C4541414F69432C7542414177437A422C4941417042522C4541414F452C6541412B434D2C4941417242522C4541414F472C5941436E45442C45414157462C4541414F452C5341436C42432C45414159482C4541414F472C57414976422C';
wwv_flow_api.g_varchar2_table(23) := '494141492B422C4541417342642C4B41414B652C51414151432C7942414376432C53414153432C4941434C2C4D41414F2C674241416B42432C474141472C574141612C4941414D412C474141472C65414169422C4941414D74432C4541414F75422C5341';
wwv_flow_api.g_varchar2_table(24) := '4570462C4741414976422C4541414F75432C6D42414171424C2C45414171422C4341436A442C494141494D2C4541414F432C61414161432C514141514C2C4B414368432C47414149472C454143412C494143492C49414149472C45414151432C4B41414B';
wwv_flow_api.g_varchar2_table(25) := '432C4D41414D4C2C5141434168432C4941416E426D432C4541414D7A432C5741434E412C4541415779432C4541414D7A432C654145474D2C49414170426D432C4541414D78432C5941434E412C4541415977432C4541414D78432C57414578422C4D4141';
wwv_flow_api.g_varchar2_table(26) := '4F32432C4741434C31422C4B41414B32422C4D41414D432C4D413145562C694241304534422C674441416944522C5341472F4578432C4541414F75432C6F42414173424C2C4741437043642C4B41414B32422C4D41414D452C4B413945462C6942413845';
wwv_flow_api.g_varchar2_table(27) := '6D422C2B43414768432C53414153432C4941434C39432C454141552B432C4F41414F6E442C4541414F632C6B42414735422C5341415373432C4941454C68442C4541415569442C4B41414B2C7942414179422F422C514141512C654143354374422C4541';
wwv_flow_api.g_varchar2_table(28) := '414F73442C6942414350412C45414167422C49414B78424A2C4941474139432C454141556D442C474141472C554141552C5741436E422C49414149432C4541434378442C4541414F69432C6B424141714237422C454141554C2C534141532C534141552C';
wwv_flow_api.g_varchar2_table(29) := '61414165432C4541414F67432C6B424143684668432C4541414F67432C674241416B4277422C454141636C442C4941437643462C454141554C2C534141532C534141552C5741415979442C49414537434E2C49414341452C4F41494A68442C454141554C';
wwv_flow_api.g_varchar2_table(30) := '2C534141532C43414366612C594141615A2C4541414F592C594143704236432C65414167427A442C4541414F30442C5541437642432C5141415333442C4541414F32442C51414368427A442C53414155412C4541435630442C5941416135442C4541414F';
wwv_flow_api.g_varchar2_table(31) := '36442C5941437042432C6141416339442C4541414F38442C614143724233442C55414157412C47414130422C4741415A442C4941416B42462C4541414F2B442C5741436C44432C4B41414D68452C4541414F69452C53414362432C4941414B6C452C4541';
wwv_flow_api.g_varchar2_table(32) := '414F6D452C5941435A432C5341415570452C4541414F71452C694241436A42432C5541415774452C4541414F75452C6541436C42432C5941416178452C4541414F79452C6141437042432C6141416331452C4541414F32452C6341437242432C79424141';
wwv_flow_api.g_varchar2_table(33) := '304235452C4541414F2B442C5741436A43632C4D41414F37452C4541414F36452C4D414364432C4F4141512C5341415568432C4541414769432C474145622F452C4541414F69432C6B42414350622C4B41414B34442C4F41414F432C4F41414F6A462C45';
wwv_flow_api.g_varchar2_table(34) := '41414F6B462C65414167422C4341437443432C4941414B4A2C454141474B2C61414352432C4941414B4E2C4541414735452C574143542C434143436D462C4D41414F2C43414348432C4F4141512C59414352432C4B41414D2C4941414D78462C4541414F';
wwv_flow_api.g_varchar2_table(35) := '75422C59414B334276422C4541414F75432C6F424143484C2C454143414F2C6141416167442C5141415170442C49414132424F2C4B41414B38432C554141552C434143334478462C5341415536452C454141474B2C614143626A462C5541415734452C45';
wwv_flow_api.g_varchar2_table(36) := '41414735452C6141476C4269422C4B41414B32422C4D41414D452C4B416A4A642C694241694A2B422C6744414968436A442C4541414F32462C674241435033462C4541414F32462C6541416537432C4541414769432C474147374233422C494147416844';
wwv_flow_api.g_varchar2_table(37) := '2C4541415569442C4B41414B2C6942414134422F422C514141512C5541476E44462C4B41414B432C4D41414D432C514141512C4941414D74422C4541414F75422C534141552C34424141364276422C4D41493345412C4541414F73442C6B424145506C44';
wwv_flow_api.g_varchar2_table(38) := '2C454141556D442C474141472C6F4241416F422C57414337426E442C4541415569442C4B41354B4C2C674241344B3042462C4F41414F2C57414731432F432C4541415569442C4B41414B2C774241416D4375432C4D41414B2C53414155432C4541414F72';
wwv_flow_api.g_varchar2_table(39) := '442C474143704531432C4541414530432C4741414D612C4B41684C482C674241674C774275432C4D41414B2C53414155432C4541414F72442C4741432F4331432C4541414530432C4741414D73442C5341415333432C4F41414F2C5141415132432C5341';
wwv_flow_api.g_varchar2_table(40) := '415333432C4F41414F2C65414D35442F432C4541415569442C4B41414B2C6942414134422F422C514141512C5541476E44462C4B41414B432C4D41414D432C514141512C4941414D74422C4541414F75422C534141552C34424141364276422C47414933';
wwv_flow_api.g_varchar2_table(41) := '452C5341415373442C454141674279432C4741457242432C594141572C5741455035462C4541415569442C4B416C4D442C6742416B4D7342462C4F41414F2C554143764334432C474141532C4B41354C684233452C4B41414B32422C4D41414D6B442C4B';
wwv_flow_api.g_varchar2_table(42) := '41444D2C69424143576A472C47414B7842432C6141416B4269472C5541436C426A472C4541414F6B472C4B41414B432C4B41414D70472C4741477442492C454141594E2C454141452C614141632C4941414D452C4541414F75422C5541415538452C5141';
wwv_flow_api.g_varchar2_table(43) := '774C2F4372472C4541414F2B442C5941435033432C4B41414B6B462C4F41414F432C4B41414B432C6D4241416D4270472C454141552C494141492C5341415571472C47414378447A472C4541414F79472C55414159412C45414366412C494141637A472C';
wwv_flow_api.g_varchar2_table(44) := '4541414F30472C554143724272472C494143414C2C4541414F30472C554141572C47414358442C474141617A472C4541414F73442C694241453342412C45414167422C4F4147784278442C45414145462C5141415132442C474141472C6742414167422C';
wwv_flow_api.g_varchar2_table(45) := '5741457A422C494141496F442C4541414B76472C454141552C4741456E4234462C594141572C5741435035452C4B41414B6B462C4F41414F432C4B41414B4B2C694241416942442C474141492C4B4143764333472C4541414F36472C7342414177422C53';
wwv_flow_api.g_varchar2_table(46) := '4147744378472C4B414F52502C45414145462C5141415132442C474141472C534141556E432C4B41414B6D462C4B41414B4F2C554141532C574145744368482C454141452C69424141344277422C514141512C59414376432C4D41474878422C45414145';
wwv_flow_api.g_varchar2_table(47) := '2C6341416379442C474141472C7742414177422C574145764379432C594141572C574143506C472C454141452C69424141344277422C514141512C59414376432C5141475078422C45414145462C5141415132442C474141472C6B4341416B432C574143';
wwv_flow_api.g_varchar2_table(48) := '33437A442C454141452C69424141344277422C514141512C61416E5039432C4341715047462C4B41414B3246222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139083637887556759)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F533D77696E646F772E464F537C7C7B7D2C66756E6374696F6E2865297B77696E646F772E464F532E73706C69747465723D66756E6374696F6E28692C74297B766172206F2C6E2C723B66756E6374696F6E206128297B66756E6374';
wwv_flow_api.g_varchar2_table(2) := '696F6E207428297B696628692E706F736974696F6E46756E6374696F6E296F3D692E706F736974696F6E46756E6374696F6E28293B656C736520696628766F69642030213D3D692E706F736974696F6E436F6465297B76617220653D692E706F73697469';
wwv_flow_api.g_varchar2_table(3) := '6F6E436F64652C743D22686F72697A6F6E74616C223D3D692E6F7269656E746174696F6E3F722E776964746828293A692E68656967687446756E6374696F6E28292C6E3D652E73706C697428222F22293B286F3D6E2E6C656E6774683E313F4D6174682E';
wwv_flow_api.g_varchar2_table(4) := '726F756E6428742A6E5B305D2F6E5B315D293A30293E302626286F2D3D34297D72657475726E206F7D617065782E6576656E742E74726967676572282223222B692E726567696F6E49642C22666F732D73706C69747465722D6265666F72652D72656E64';
wwv_flow_api.g_varchar2_table(5) := '6572222C69292C722E616464436C6173732822666F732D53706C697474657222292C722E6368696C6472656E28292E616464436C6173732822666F732D53706C69747465722D726567696F6E22292C722E6174747228226964222C692E726567696F6E49';
wwv_flow_api.g_varchar2_table(6) := '642B225F73706C697474657222292C692E70616464696E6746697273742626722E6368696C6472656E28292E65712830292E637373282270616464696E67222C692E70616464696E6746697273747C7C22707822292C692E70616464696E675365636F6E';
wwv_flow_api.g_varchar2_table(7) := '642626722E6368696C6472656E28292E65712831292E637373282270616464696E67222C692E70616464696E675365636F6E647C7C22707822292C692E696E697469616C506F736974696F6E3D7428292C692E7065727369737453746174655072656626';
wwv_flow_api.g_varchar2_table(8) := '26766F69642030213D3D692E706F736974696F6E2626766F69642030213D3D692E636F6C6C61707365642626286F3D692E706F736974696F6E2C6E3D692E636F6C6C6170736564293B76617220613D617065782E73746F726167652E6861734C6F63616C';
wwv_flow_api.g_varchar2_table(9) := '53746F72616765537570706F727428293B66756E6374696F6E206C28297B72657475726E22666F732D73706C69747465722D222B2476282270466C6F77496422292B222D222B2476282270466C6F7753746570496422292B222D222B692E726567696F6E';
wwv_flow_api.g_varchar2_table(10) := '49647D696628692E7065727369737453746174654C6F63616C262661297B76617220703D6C6F63616C53746F726167652E6765744974656D286C2829293B69662870297472797B76617220643D4A534F4E2E70617273652870293B766F69642030213D3D';
wwv_flow_api.g_varchar2_table(11) := '642E706F736974696F6E2626286F3D642E706F736974696F6E292C766F69642030213D3D642E636F6C6C61707365642626286E3D642E636F6C6C6170736564297D63617463682865297B617065782E64656275672E6572726F722822464F53202D205370';
wwv_flow_api.g_varchar2_table(12) := '6C6974746572222C22436F756C64206E6F7420706172736520707265666572656E63652066726F6D206C6F63616C2073746F72616765222C70297D7D656C736520692E7065727369737453746174654C6F63616C262621612626617065782E6465627567';
wwv_flow_api.g_varchar2_table(13) := '2E7761726E2822464F53202D2053706C6974746572222C2242726F7773657220646F6573206E6F742068617665204C6F63616C2053746F7261676520537570706F727422293B66756E6374696F6E206328297B722E68656967687428692E686569676874';
wwv_flow_api.g_varchar2_table(14) := '46756E6374696F6E2829297D66756E6374696F6E206728297B722E66696E6428222E6A732D737469636B795461626C6548656164657222292E747269676765722822666F726365726573697A6522292C692E726573697A654A6574436861727473262673';
wwv_flow_api.g_varchar2_table(15) := '283530297D6328292C722E6F6E2822726573697A65222C2866756E6374696F6E28297B76617220653B692E706572736973745374617465507265667C7C722E73706C697474657228226F7074696F6E222C22706F736974696F6E2229213D692E696E6974';
wwv_flow_api.g_varchar2_table(16) := '69616C506F736974696F6E7C7C28692E696E697469616C506F736974696F6E3D653D7428292C722E73706C697474657228226F7074696F6E222C22706F736974696F6E222C6529292C6328292C6728297D29292C722E73706C6974746572287B6F726965';
wwv_flow_api.g_varchar2_table(17) := '6E746174696F6E3A692E6F7269656E746174696F6E2C706F736974696F6E656446726F6D3A692E646972656374696F6E2C6D696E53697A653A692E6D696E53697A652C706F736974696F6E3A6F2C6E6F436F6C6C617073653A21692E63616E436F6C6C61';
wwv_flow_api.g_varchar2_table(18) := '7073652C64726167436F6C6C617073653A692E64726167436F6C6C617073652C636F6C6C61707365643A6E7C7C303D3D6F262621692E6C617A7952656E6465722C736E61703A692E7374657053697A652C696E633A692E6B65795374657053697A652C72';
wwv_flow_api.g_varchar2_table(19) := '65616C54696D653A692E636F6E74696E756F7573526573697A652C696672616D654669783A692E636F6E7461696E73496672616D652C726573746F7265546578743A692E7469746C65526573746F72652C636F6C6C61707365546578743A692E7469746C';
wwv_flow_api.g_varchar2_table(20) := '65436F6C6C617073652C696D6D6564696174655669736962696C697479436865636B3A692E6C617A7952656E6465722C7469746C653A692E7469746C652C6368616E67653A66756E6374696F6E28652C74297B692E706572736973745374617465507265';
wwv_flow_api.g_varchar2_table(21) := '662626617065782E7365727665722E706C7567696E28692E616A61784964656E7469666965722C7B7830313A742E6C617374506F736974696F6E2C7830323A742E636F6C6C61707365647D2C7B71756575653A7B616374696F6E3A226C617A7957726974';
wwv_flow_api.g_varchar2_table(22) := '65222C6E616D653A2273222B692E726567696F6E49647D7D292C692E7065727369737453746174654C6F63616C262628613F6C6F63616C53746F726167652E7365744974656D286C28292C4A534F4E2E737472696E67696679287B706F736974696F6E3A';
wwv_flow_api.g_varchar2_table(23) := '742E6C617374506F736974696F6E2C636F6C6C61707365643A742E636F6C6C61707365647D29293A617065782E64656275672E7761726E2822464F53202D2053706C6974746572222C2242726F7773657220646F6573206E6F742068617665204C6F6361';
wwv_flow_api.g_varchar2_table(24) := '6C2053746F7261676520537570706F72742229292C692E6368616E676546756E6374696F6E2626692E6368616E676546756E6374696F6E28652C74292C6728292C722E66696E6428222E666F732D53706C697474657222292E7472696767657228227265';
wwv_flow_api.g_varchar2_table(25) := '73697A6522292C617065782E6576656E742E74726967676572282223222B692E726567696F6E49642C22666F732D73706C69747465722D61667465722D726573697A65222C69297D7D292C692E726573697A654A6574436861727473262628722E6F6E28';
wwv_flow_api.g_varchar2_table(26) := '2261706578616674657272656672657368222C2866756E6374696F6E28297B722E66696E6428275B69642A3D225F6A6574225D27292E68656967687428223130302522297D29292C722E66696E6428222E666F732D53706C69747465722D726567696F6E';
wwv_flow_api.g_varchar2_table(27) := '22292E65616368282866756E6374696F6E28692C74297B652874292E66696E6428275B69642A3D225F6A6574225D27292E65616368282866756E6374696F6E28692C74297B652874292E706172656E7428292E68656967687428223130302522292E7061';
wwv_flow_api.g_varchar2_table(28) := '72656E7428292E68656967687428223130302522297D29297D2929292C722E66696E6428222E666F732D53706C697474657222292E747269676765722822726573697A6522292C617065782E6576656E742E74726967676572282223222B692E72656769';
wwv_flow_api.g_varchar2_table(29) := '6F6E49642C22666F732D73706C69747465722D61667465722D72656E646572222C69297D66756E6374696F6E20732865297B73657454696D656F7574282866756E6374696F6E28297B722E66696E6428275B69642A3D225F6A6574225D27292E68656967';
wwv_flow_api.g_varchar2_table(30) := '687428223130302522297D292C657C7C343030297D617065782E64656275672E696E666F2822464F53202D2053706C6974746572222C69292C7420696E7374616E63656F662046756E6374696F6E2626742E63616C6C28746869732C69292C723D652822';
wwv_flow_api.g_varchar2_table(31) := '2E636F6E7461696E6572222C2223222B692E726567696F6E4964292E666972737428292C692E6C617A7952656E6465723F28617065782E7769646765742E7574696C2E6F6E5669736962696C6974794368616E676528725B305D2C2866756E6374696F6E';
wwv_flow_api.g_varchar2_table(32) := '2865297B692E697356697369626C653D652C65262621692E72656E64657265643F286128292C692E72656E64657265643D2130293A652626692E726573697A654A6574436861727473262673283530297D29292C652877696E646F77292E6F6E28226170';
wwv_flow_api.g_varchar2_table(33) := '65787265616479656E64222C2866756E6374696F6E28297B76617220653D725B305D3B73657454696D656F7574282866756E6374696F6E28297B617065782E7769646765742E7574696C2E7669736962696C6974794368616E676528652C2130297D292C';
wwv_flow_api.g_varchar2_table(34) := '692E7669736962696C697479436865636B44656C61797C7C333030297D2929293A6128297D2C652877696E646F77292E6F6E2822726573697A65222C617065782E7574696C2E6465626F756E6365282866756E6374696F6E28297B6528222E666F732D53';
wwv_flow_api.g_varchar2_table(35) := '706C697474657222292E747269676765722822726573697A6522297D292C31303029292C65282223745F547265654E617622292E6F6E28227468656D6534326C61796F75746368616E676564222C2866756E6374696F6E28297B73657454696D656F7574';
wwv_flow_api.g_varchar2_table(36) := '282866756E6374696F6E28297B6528222E666F732D53706C697474657222292E747269676765722822726573697A6522297D292C323530297D29292C652877696E646F77292E6F6E2822617065787265616479656E64206170657877696E646F77726573';
wwv_flow_api.g_varchar2_table(37) := '697A6564222C2866756E6374696F6E28297B6528222E666F732D53706C697474657222292E747269676765722822726573697A6522297D29297D28617065782E6A5175657279293B0A2F2F2320736F757263654D617070696E6755524C3D736372697074';
wwv_flow_api.g_varchar2_table(38) := '2E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(139084120519556759)
,p_plugin_id=>wwv_flow_api.id(134108205512926532)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


