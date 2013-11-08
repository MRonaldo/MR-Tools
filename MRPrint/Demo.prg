#include "inkey.ch"
#include "hbgtinfo.ch"

Procedure Main
   Local i
   Local oMRPrint
   Local cDBF____ := 'AC_CST_PIS'
   Local aToPrint := {}
   Local cFilePdf := 'MR_Print.PDF'
   Local cFileTXT := 'readme.txt'
   Local cFilePRN := 'fileprint.prn'

   F_Set_Desktop()

   //*----------------------------------------------------------------------*
   // MR_Print()
   //*----------------------------------------------------------------------*
   oMRPrint  := MR_Print():New( cFilePdf )

   //*----------------------------------------------------------------------*
   // METODO DE IMPRESSÃO LIVRE ( USER DEFINED )
   //*----------------------------------------------------------------------*
   F_User_Defined( oMRPrint )

   //*----------------------------------------------------------------------*
   // DBF TO PDF
   //*----------------------------------------------------------------------*
   DBUSEAREA( .T.,, cDBF____, cDBF____, .T., .T. )
   IF !( NetErr() )
      oMRPrint:DbfToPdf( cDBF____ )
      oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.900 ), '.DBF Table: ' + cDBF____, oMRPrint:oFont_f______, 14 )
      DBCLOSEAREA( cDBF____ )
   ENDIF

   //*----------------------------------------------------------------------*
   // Array TO PDF - oMRPrint:ArrayToPdf( aPrint, nFontSize ): UNIDIMENSIONAL
   //*----------------------------------------------------------------------*
   FOR i := 1 TO 80
     IF i > 5
        AADD( aToPrint, PADR( STRZERO( i, 3), 6 ) + PADC( 'ARRAY OF TEXT ELEMENTS PRINTED TO A PDF FILE... ANY SUGESTION: SEND A REQUEST TO AUTHOR', 120, '.' ) + PADL( STRZERO( i, 3 ), 6 ) )
     ELSE
        IF i == 1
           AADD( aToPrint, PADR( STRZERO( i, 3), 6 ) + PADC( 'CRIE ARRAY DE ELEMENTOS TIPO TEXTO COM TAMANHO ILIMITADO: O LIMITE DE USO É SUA CRIATIVIDADE', 120, '.' ) + PADL( STRZERO( i, 3 ), 6 ) )
        ELSE
           AADD( aToPrint, PADR( STRZERO( i, 3), 6 ) + PADC( '.', 120 ) + PADL( STRZERO( i, 3 ), 6 ) )
        ENDIF
     ENDIF
   NEXT
   oMRPrint:ArrayToPdf( aToPrint,  7 )

   //*----------------------------------------------------------------------*
   // Array TO PDF - oMRPrint:ArrayToPdf( aPrint, nFontSize ): BIDIMENSIONAL
   //*----------------------------------------------------------------------*
   aToPrint := {}
   FOR i := 1 TO 80
     IF i > 5
        AADD( aToPrint, { STRZERO( i, 3), 'BIDIMENSIONAL: ARRAY ELEMENTS OF ANY TYPE PRINTED TO A PDF FILE', 123456789.01, DATE(), .T., .F., {}, 'BIDIMENSIONAL: ARRAY ELEMENTS OF ANY TYPE PRINTED TO A PDF FILE', 123456789.01, DATE(), .T., .F., {},STRZERO( i, 3 ) } )
     ELSE
        IF i == 1
           AADD( aToPrint, { STRZERO( i, 3), 'BIDIMENSIONAL: ARRAY ELEMENTS OF ANY TYPE PRINTED TO A PDF FILE', 123456789.01, DATE(), .T., .F., {}, 'BIDIMENSIONAL: ARRAY ELEMENTS OF ANY TYPE PRINTED TO A PDF FILE', 123456789.01, DATE(), .T., .F., {},STRZERO( i, 3 ) } )
        ELSE
           AADD( aToPrint, { '', '', 0.01, DATE(), .T., .F., {}, '', 0.01, DATE(), .T., .F., {}, STRZERO( i, 3 ) } )
        ENDIF
     ENDIF
   NEXT
   oMRPrint:ArrayToPdf( aToPrint,  7 )

   //*----------------------------------------------------------------------*
   // TXT FILE TO PDF - oMRPrint:ArrayToPdf( TxtToPDF, nFontSize )
   //*----------------------------------------------------------------------*
   oMRPrint:TxtToPDF( cFileTXT, 10 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.900 ), '.TXT File: ' + cFileTXT, oMRPrint:oFont_f______, 14 )

   //*----------------------------------------------------------------------*
   // PRN FILE TO PDF ( ARQUIVO DE IMPRESSÃO )
   //*----------------------------------------------------------------------*
   oMRPrint:PrnToPdf( cFilePRN,  7 )

   //*----------------------------------------------------------------------*
   // END JOB: CREATE PDF ( .T. / .F. ) Open/Show PDF ?
   //*----------------------------------------------------------------------*
   oMRPrint:Finish( .T. )
   
Return


//*----------------------------------------------------------------------------*
// F_User_Defined( oMRPrint )
//
// oMRPrint:oFont_f______ := Courier   ( Fonte com tamanho do espaçamento Fixo )
// oMRPrint:oFont_v______ := Helvetica ( Fonte com tamanho do espaçamento variavel )
//
//
// Desenhe livremente, baseando na largura e altura do papel utilizado ( 0% a 100% do tamanho do papel )
//
// oMRPrint:Page_Width___ * n ( Valores válidos para n := 0.000 até 1.000 )
// oMRPrint:Page_Height__ * n ( Valores válidos para n := 0.000 até 1.000 )
//
//*----------------------------------------------------------------------------*
Function F_User_Defined( oMRPrint )
   LOCAL i
   LOCAL cAux
   LOCAL cImageFile := 'Resources\Imatech.jpg'

   //*-------------------------------------------------------------------------*
   // ::AddPage( lRetrato ) -> ( .F. ) == Modo Paisagem
   //*-------------------------------------------------------------------------*
   oMRPrint:AddPage( .T. )

   //*----------------------------------------------------------------------*
   // PRINT IMAGE - Draw_Image( nLeft, nTop, nWidth, nHeight, cImageFile )
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Image( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.075 ), 50, 50, cImageFile )

   //*----------------------------------------------------------------------*
   // PRINT TEXT - Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.150 ), ( oMRPrint:Page_Height__ * 0.030 ), 'IMATION TECNOLOGIA & INFORMAÇÃO', oMRPrint:oFont_v______, 12 )

   //*----------------------------------------------------------------------*
   // PRINT TEXT - Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.150 ), ( oMRPrint:Page_Height__ * 0.045 ), 'MRPrint: Sistemas de Impressão para Harbour', oMRPrint:oFont_v______, 10 )

   //*----------------------------------------------------------------------*
   // PRINT TEXT - Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.150 ), ( oMRPrint:Page_Height__ * 0.070 ), 'M., Ronaldo - < ronmesq@gmail.com >', oMRPrint:oFont_v______,  8 )

   //*----------------------------------------------------------------------*
   // PRINT LINE - Draw_Line( x, y, w, z, 0.5 ) : TOP
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Line( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.100 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.100 ), 0.5 )

   //*----------------------------------------------------------------------*
   // PRINT TEXT FMT - Draw_Text_Formated( nLeft, nTop, nRight, nBottom, cTxt, oFont, nSize, nAlign, nColor )
   //*----------------------------------------------------------------------*
   cAux := 'Textos sofisticados e agradaveis de forma fácil e rápida: '
   cAux += 'Produza relatórios com qualidade superior e em qualquer tipo de impressora e Sistema operacional, não precisa nenhum programa externo ou biblioteca de terceiros para imprimir textos complexos e em modo:'
   // LEFT
   oMRPrint:Draw_Text_Formated( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.115 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.150 ), 'LEFT TEXT JUSTIFY..: ' + cAux + ' Alinhado a Esquerda.', oMRPrint:oFont_v______,  7, 1, 3 )
   // CENTER
   oMRPrint:Draw_Text_Formated( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.155 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.180 ), 'CENTER TEXT JUSTIFY: ' + cAux + ' Centralizado.', oMRPrint:oFont_v______,  7, 3, 2 )
   // RIGHT
   oMRPrint:Draw_Text_Formated( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.185 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.210 ), 'RIGHT TEXT JUSTIFY.: ' + cAux + ' Alinhado a Direita.', oMRPrint:oFont_v______,  7, 2, 1 )
   // JUSTIFY
   oMRPrint:Draw_Text_Formated( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.215 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.240 ), 'ALL TEXT JUSTIFY...: ' + cAux + ' Justificado.', oMRPrint:oFont_v______,  7, 4, 0 )

   //*----------------------------------------------------------------------*
   // PRINT TEXT - Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.275 ), 'Courier', oMRPrint:oFont_f______,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.285 ), 'Courier: Negrito', oMRPrint:oFont_f_b____,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.295 ), 'Courier: Itálico', oMRPrint:oFont_f_i____,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.305 ), 'Courier: Negrito + Itálico', oMRPrint:oFont_f_bi___,  8 )

   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.375 ), ( oMRPrint:Page_Height__ * 0.275 ), 'Helvetica', oMRPrint:oFont_v______,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.375 ), ( oMRPrint:Page_Height__ * 0.285 ), 'Helvetica: Negrito ', oMRPrint:oFont_v_b____,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.375 ), ( oMRPrint:Page_Height__ * 0.295 ), 'Helvetica: Itálico', oMRPrint:oFont_v_i____,  8 )
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.375 ), ( oMRPrint:Page_Height__ * 0.305 ), 'Helvetica: Negrito + Itálico', oMRPrint:oFont_v_bi___,  8 )

   //*----------------------------------------------------------------------*
   // SET TEXT COLOR - Set_Font_Color( r, g, b ) : Valores := 0...255
   //*----------------------------------------------------------------------*
   oMRPrint:Set_Font_Color( 255, 0, 0 ) /* Vermelho */
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.695 ), ( oMRPrint:Page_Height__ * 0.275 ), 'Set Text Color: Red', oMRPrint:oFont_v______,  9 )

   oMRPrint:Set_Font_Color( 0, 255, 0 ) /* Verde */
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.695 ), ( oMRPrint:Page_Height__ * 0.285 ), 'Set Text Color: Green', oMRPrint:oFont_v______,  9 )

   oMRPrint:Set_Font_Color( 0, 0, 255 ) /* Azul */
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.695 ), ( oMRPrint:Page_Height__ * 0.295 ), 'Set Text Color: Blue', oMRPrint:oFont_v______,  9 )

   oMRPrint:Set_Font_Color( 0, 0, 0 )   /* Preto */
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.695 ), ( oMRPrint:Page_Height__ * 0.305 ), 'Set Text Color: Black', oMRPrint:oFont_v______,  9 )

   //*----------------------------------------------------------------------*
   // PRINT TEXT ROTATED- Draw_Text_Rotated( nLeft, nTop, cTxt, oFont, nSize, nColor, nAngle )
   //*----------------------------------------------------------------------*
   FOR i := 30 TO 360 STEP 30
      oMRPrint:Draw_Text_Rotated( ( oMRPrint:Page_Width___ * 0.275 ), ( oMRPrint:Page_Height__ * 0.500 ), PADL( 'IMATION TECNOLOGIA', 24 )+ STR( i, 6 ) + CHR( 176 ), oMRPrint:oFont_v______,  9, 0, ( i ) )
   NEXT

   //*----------------------------------------------------------------------*
   // PRINT TEXT ROTATED- REVERSE
   //*----------------------------------------------------------------------*
   FOR i := -30 TO -360 STEP -30
      oMRPrint:Draw_Text_Rotated( ( oMRPrint:Page_Width___ * 0.725 ), ( oMRPrint:Page_Height__ * 0.650 ), PADL( 'IMATION TECNOLOGIA', 24 )+ STR( i, 6 ) + CHR( 176 ), oMRPrint:oFont_v______,  9, 3, ( i ) )
   NEXT

   //*----------------------------------------------------------------------*
   // Draw_Box( x, y, w, z, nPenSize, aColor )
   //*----------------------------------------------------------------------*
   /* Only draw borders */
   oMRPrint:Draw_Box( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.900 ), ( oMRPrint:Page_Width___ * 0.100 ), ( oMRPrint:Page_Height__ * 0.120 ), 1, {   0,   0, 220 } )
   /* Fill only: no borders */
   oMRPrint:Draw_Box( ( oMRPrint:Page_Width___ * 0.250 ), ( oMRPrint:Page_Height__ * 0.900 ), ( oMRPrint:Page_Width___ * 0.100 ), ( oMRPrint:Page_Height__ * 0.120 ), 1, { 220, 220, 110 }, 2 )
   /* Fill + borders */
   oMRPrint:Draw_Box( ( oMRPrint:Page_Width___ * 0.450 ), ( oMRPrint:Page_Height__ * 0.900 ), ( oMRPrint:Page_Width___ * 0.100 ), ( oMRPrint:Page_Height__ * 0.120 ), 1, { 255, 255, 128 }, 3 )

   //*----------------------------------------------------------------------*
   // SET TEXT COLOR - Set_Font_Color( r, g, b ): BLACK : : Valor := 0
   //*----------------------------------------------------------------------*
   oMRPrint:Set_Font_Color( 0, 0, 0 )   /* Preto */
   oMRPrint:Draw_Text( ( oMRPrint:Page_Width___ * 0.150 ), ( oMRPrint:Page_Height__ * 0.950 ), 'Set Text Color: Black ( Return to Default Color )', oMRPrint:oFont_v______,  9 )

   //*----------------------------------------------------------------------*
   // PRINT LINE - Draw_Line( x, y, w, z, 0.5 ) : BOTTOM
   //*----------------------------------------------------------------------*
   oMRPrint:Draw_Line( ( oMRPrint:Page_Width___ * 0.050 ), ( oMRPrint:Page_Height__ * 0.966 ), ( oMRPrint:Page_Width___ * 0.950 ), ( oMRPrint:Page_Height__ * 0.966 ), 0.5 )

RETURN( NIL )


//*----------------------------------------------------------------------------*
// F_Set_Desktop()
//*----------------------------------------------------------------------------*
PROCEDURE F_Set_Desktop()

   REQUEST HB_LANG_PT
   REQUEST HB_CODEPAGE_UTF8
   REQUEST HB_CODEPAGE_UTF8EX

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_GUI
   REQUEST HB_GT_WIN

   *---------------------------------------------------------------------------*
   * ANO COM 04 DIGITOS
   *---------------------------------------------------------------------------*
   SET CENTURY ON

   *---------------------------------------------------------------------------*
   * DATAS: -50 DATA ATUAL + 50
   *---------------------------------------------------------------------------*
   SET EPOCH TO YEAR( DATE() ) - 50

   SETMODE( 33, 112 )

   SetColor( 'N/W' )

   CLS

   hb_langSelect( "PT" )
   hb_cdpSelect( "UTF8EX" )

   Set ( _SET_SCOREBOARD, .F. )
   Set ( _SET_EVENTMASK, INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT )

   *---------------------------------------------------------------------------*
   // CONFIGURAÇÕES REGIONAIS / VIDEO
   *---------------------------------------------------------------------------*
   hb_gtInfo( HB_GTI_CLIPBOARDDATA )
   hb_gtInfo( HB_GTI_SELECTCOPY, .T. )
   hb_gtInfo( HB_GTI_MOUSESTATUS, 1 )
   hb_gtInfo( HB_GTI_MAXIMIZED, .F. )
   hb_gtInfo( HB_GTI_CLOSABLE, .T. )
   hb_gtInfo( HB_GTI_ISGRAPHIC, .T. )
   hb_gtInfo( HB_GTI_STDERRCON, .T. )

RETURN
