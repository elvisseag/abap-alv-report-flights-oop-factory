*&---------------------------------------------------------------------*
*&  Include           ZES_PROGRAM_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*  This subroutine is used to build the field catalog for the ALV list
*----------------------------------------------------------------------*
FORM build_fieldcatalog.
* get fieldcatalog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SFLIGHT'
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.

* change fieldcatalog
  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
  LOOP AT gt_fieldcatalog INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
      WHEN 'CARRID' OR 'CONNID' OR 'FLDATE'.
        ls_fieldcatalog-no_out = 'X'.
        ls_fieldcatalog-key    = ''.
      WHEN 'PRICE' OR 'SEATSOCC' OR 'SEATSMAX' OR 'PAYMENTSUM'.
        ls_fieldcatalog-do_sum = 'X'.
    ENDCASE.
    MODIFY gt_fieldcatalog FROM ls_fieldcatalog.
  ENDLOOP.

ENDFORM.                               " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT_TABLE
*&---------------------------------------------------------------------*
* This subroutine is used to build the sort table or the sort criteria
*----------------------------------------------------------------------*
FORM build_sort_table.

  DATA ls_sort_wa TYPE lvc_s_sort.

* create sort-table
  ls_sort_wa-spos = 1.
  ls_sort_wa-fieldname = 'CARRID'.
  ls_sort_wa-up = 'X'.
  ls_sort_wa-subtot = 'X'.
  APPEND ls_sort_wa TO gt_sort.

  ls_sort_wa-spos = 2.
  ls_sort_wa-fieldname = 'CONNID'.
  ls_sort_wa-up = 'X'.
  ls_sort_wa-subtot = 'X'.
  APPEND ls_sort_wa TO gt_sort.

  ls_sort_wa-spos = 3.
  ls_sort_wa-fieldname = 'FLDATE'.
  ls_sort_wa-up = 'X'.
  APPEND ls_sort_wa TO gt_sort.

ENDFORM.                               " BUILD_SORT_TABLE
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
FORM exit_program.

  CALL METHOD tree1->free.
*  LEAVE PROGRAM.

ENDFORM.                               " exit_program
*&---------------------------------------------------------------------*
*&      Form  register_events
*&---------------------------------------------------------------------*
*  Handling the events in the ALV Tree control in backend
*----------------------------------------------------------------------*
FORM register_events.
* define the events which will be passed to the backend
  DATA: lt_events TYPE cntl_simple_events,
        l_event   TYPE cntl_simple_event.

* define the events which will be passed to the backend
  l_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_click.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
  APPEND l_event TO lt_events.

  CALL METHOD tree1->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.

* set Handler
  DATA: l_event_receiver TYPE REF TO lcl_tree_event_receiver.
  CREATE OBJECT l_event_receiver.
  SET HANDLER l_event_receiver->on_add_hierarchy_node
                                                        FOR tree1.
ENDFORM.                               " register_events
*&---------------------------------------------------------------------*
*&      Form  build_header
*&---------------------------------------------------------------------*
*       build table for header
*----------------------------------------------------------------------*
FORM build_comment USING
      pt_list_commentary TYPE slis_t_listheader
      p_logo             TYPE sdydo_value.

  DATA: ls_line TYPE slis_listheader.
*
* LIST HEADING LINE: TYPE H
  CLEAR ls_line.
  ls_line-typ  = 'H'.
* LS_LINE-KEY:  NOT USED FOR THIS TYPE
  ls_line-info = 'ALV TREE DEMO for SAPTechnical.COM 1'.
  APPEND ls_line TO pt_list_commentary.
  ls_line-info = 'ALV TREE DEMO for SAPTechnical.COM 2'.
  APPEND ls_line TO pt_list_commentary.

*  p_logo = 'ENJOYSAP_LOGO'.

ENDFORM.                    "build_comment

*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
*  Building the ALV-Tree for the first time display
*----------------------------------------------------------------------*
FORM init_tree.

  PERFORM build_fieldcatalog.

  PERFORM build_sort_table.

* create container for alv-tree
  DATA: l_tree_container_name(30) TYPE c,
        l_custom_container        TYPE REF TO cl_gui_custom_container.
  l_tree_container_name = 'G_CONTAINER_0100'.

  CREATE OBJECT l_custom_container
    EXPORTING
      container_name              = l_tree_container_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.

* create tree control
  CREATE OBJECT tree1
    EXPORTING
      i_parent                    = l_custom_container
      i_node_selection_mode       =
                                    cl_gui_column_tree=>node_sel_mode_multiple
      i_item_selection            = 'X'
*      i_no_html_header            = ''
*      i_no_toolbar                = ''
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.

* create info-table for html-header
*  DATA: lt_list_commentary TYPE slis_t_listheader,
*        l_logo             TYPE sdydo_value.
*  PERFORM build_comment USING
*                 lt_list_commentary
*                 l_logo.

* repid for saving variants
  DATA: ls_variant TYPE disvariant.
  ls_variant-report = sy-repid.

* register events
  PERFORM register_events.

* create hierarchy
  CALL METHOD tree1->set_table_for_first_display
    EXPORTING
*      it_list_commentary = lt_list_commentary
*      i_logo             = l_logo
*      i_background_id    = 'ALV_BACKGROUND'
      i_save             = 'A'
      is_variant         = ls_variant
    CHANGING
      it_sort            = gt_sort
      it_outtab          = gtd_sflight
      it_fieldcatalog    = gt_fieldcatalog.

* expand first level
  CALL METHOD tree1->expand_tree
    EXPORTING
      i_level = 1.

* optimize column-width
  CALL METHOD tree1->column_optimize
    EXPORTING
      i_start_column = tree1->c_hierarchy_column_name
      i_end_column   = tree1->c_hierarchy_column_name.

ENDFORM.                    " init_tree
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * UP TO 20 ROWS  INTO TABLE gtd_sflight
    FROM sflight
    WHERE fldate IN s_fldate.

ENDFORM.
