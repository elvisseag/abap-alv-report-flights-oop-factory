*&---------------------------------------------------------------------*
*&  Include           ZES_PROGRAM_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
* This subroutine is used to handle the navigation on the screen
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      PERFORM exit_program.
      SET SCREEN 0.
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.
  CLEAR ok_code.

ENDMODULE.                             " PAI  INPUT