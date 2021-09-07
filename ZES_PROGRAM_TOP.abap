*&---------------------------------------------------------------------*
*&  Include           ZES_PROGRAM_TOP
*&---------------------------------------------------------------------*

TABLES: sflight.
CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw DEFINITION LOAD.

DATA tree1  TYPE REF TO cl_gui_alv_tree_simple.

INCLUDE bcalv_simple_event_receiver.

DATA: gtd_sflight     TYPE STANDARD TABLE OF sflight,   " Output-Table
      gt_fieldcatalog TYPE lvc_t_fcat,         " Field Catalog
      gt_sort         TYPE lvc_t_sort,         " Sorting Table
      ok_code         LIKE sy-ucomm.           " OK-Code