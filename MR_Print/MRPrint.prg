// *---------------------------------------------------------------------------*
 *
 * Copyright 2013 hbQT
 * www - http://harbour-project.org
 *
 * Author: M.,Ronaldo <ronmesq@gmail.com>
 *
// *---------------------------------------------------------------------------*

#include "hbclass.ch"
#include "Dbstruct.ch"
#include "harupdf.ch"
#include "hbzebra.ch"

#define Dbf_nFields___    1
#define Dbf_Header____    2
#define Dbf_Field_____    3
#define Dbf_Field_v___    4
#define Dbf_Line_Txt__    5
#define Dbf_Page_New__    9

#define Page_Left_____    1
#define Page_Line_h___    2
#define Page_Pos_v____    3
#define Page_Pos_z____    4
#define Page_Pos_Save_    5
#define Page_Pos_SaveX    6
#define Page_Prn_Width   10
#define Prn_Page_New__   11
#define Prn_Cols______   12
#define Prn_Cols_Max__   13
#define Prn_Line______   14
#define Prn_Line_Len__   15
#define Prn_Lines_Max_   17
#define Prn_Eject_____   18
#define Prn_Len_Arr___   20

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Classe: MR_Print
//
// *---------------------------------------------------------------------------*
Create Class MR_Print

   /* Objeto: HaruPDF */
   DATA obPdf

   /* Objeto: Pãgina PDF */
   DATA oPage

   /* Arquivo PDF */
   DATA oFile

   /* Fontes de Impress�o */
   DATA Fnt_Fixa_____   INIT "Courier"
   DATA Fnt_Fixa_b___   INIT "Courier-Bold"
   DATA Fnt_Fixa_i___   INIT "Courier-Oblique"
   DATA Fnt_Fixa_bi__   INIT "Courier-BoldOblique"
   DATA Fnt_Var______   INIT "Helvetica"
   DATA Fnt_Var_b____   INIT "Helvetica-Bold"
   DATA Fnt_Var_i____   INIT "Helvetica-Oblique"
   DATA Fnt_Var_bi___   INIT "Helvetica-BoldOblique"

   /* Fonte Impress�o: Fixa: Courier */
   DATA oFont_f______
   DATA oFont_f_b____
   DATA oFont_f_i____
   DATA oFont_f_bi___

   /* Fonte Impress�o: Variavel: Helvetica */
   DATA oFont_v______
   DATA oFont_v_b____
   DATA oFont_v_i____
   DATA oFont_v_bi___

   /* Dimensoes da Pagina */
   DATA Page_Height__   INIT 0
   DATA Page_Width___   INIT 0

   /* Linhas/Colunas Pagina */
   DATA Lin_Max_H_arr   INIT 88
   DATA Lin_Max_H_Dbf   INIT 88
   DATA Lin_Max_H_Prn   INIT 88
   DATA Lin_Max_H_Txt   INIT 88

   /* Objetos */
   DATA Logo_File____   INIT 'Res\Imatech.jpg'

   DATA oFont_CP_____
   DATA hZebra_______   INIT ''

   /* Metodos da Classe */
   Method New( cFilePdf, lUnicode ) Constructor
   Method AddPage( lPortrait )
   Method ArrayToPdf( aPrint, nFont )
   Method TxtToPDF( cFile, nFont )
   Method PrnToPdf( cFile, nFont )
   Method DbfToPDF( cAlias )
   Method Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   Method Draw_Text_Rotated( nLeft, nTop, cTxt, oFont, nSize, nColor, nAngle )
   Method Draw_Text_Formated( nLeft, nTop, nRight, nBottom, cTxt, oFont, nSize, nAlign, nColor )
   Method Draw_Box( x, y, w, h, nPenSize, aColor, nType )
   Method Draw_Line( x, y, w, h, nPenSize )
   Method Draw_Image( nLeft, nTop, nWidth, nHeight, cFImage )
   Method Draw_Zebra( ... )
   Method Set_Font_Color( r, g, b )
   Method Finish( lOpen )

   EndClass

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:New( cFilePdf )
//
// *---------------------------------------------------------------------------*
Method MR_Print:New( cFilePdf, lUnicode )

   ::obPdf := HPDF_New()
   ::oFile := cFilePdf

   IF ( lUnicode := hb_defaultValue( lUnicode, .F. ) )
      ::oFont_CP_____ := 'UTF-8'
      ::oFont_f______ := ::Fnt_Fixa_____
      ::oFont_v______ := ::Fnt_Var______
      HPDF_UseUTFEncodings( ::obPdf )
      HPDF_LoadTTFontFromFile( ::obPdf, ::oFont_f______ + ".ttf", HPDF_TRUE )
      HPDF_LoadTTFontFromFile( ::obPdf, ::oFont_v______ + ".ttf", HPDF_TRUE )
   ELSE
      ::oFont_CP_____ := 'WinAnsiEncoding'
   ENDIF

   HPDF_SetCompressionMode( ::obPdf, HPDF_COMP_ALL )

   /* Fonte Tamanho Fixo */
   ::oFont_f______ := HPDF_GetFont( ::obPdf, ::Fnt_Fixa_____, ::oFont_CP_____ )
   ::oFont_f_b____ := HPDF_GetFont( ::obPdf, ::Fnt_Fixa_b___, ::oFont_CP_____ )
   ::oFont_f_i____ := HPDF_GetFont( ::obPdf, ::Fnt_Fixa_i___, ::oFont_CP_____ )
   ::oFont_f_bi___ := HPDF_GetFont( ::obPdf, ::Fnt_Fixa_bi__, ::oFont_CP_____ )

   /* Fonte Espaçamento Variavel */
   ::oFont_v______ := HPDF_GetFont( ::obPdf, ::Fnt_Var______, ::oFont_CP_____ )
   ::oFont_v_b____ := HPDF_GetFont( ::obPdf, ::Fnt_Var_b____, ::oFont_CP_____ )
   ::oFont_v_i____ := HPDF_GetFont( ::obPdf, ::Fnt_Var_i____, ::oFont_CP_____ )
   ::oFont_v_bi___ := HPDF_GetFont( ::obPdf, ::Fnt_Var_bi___, ::oFont_CP_____ )

   Return( Self )

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:AddPage( lPortrait )
//
// *---------------------------------------------------------------------------*
Method MR_Print:AddPage( lPortrait )

   ::oPage := HPDF_AddPage( ::obPdf )

   IF lPortrait
     HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
   ELSE
     HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE )
   ENDIF

   ::Page_Height__ := HPDF_Page_GetHeight( ::oPage )
   ::Page_Width___ := HPDF_Page_GetWidth( ::oPage )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:ArrayToPdf( aPrint, nFont )
//
// *---------------------------------------------------------------------------*
Method MR_Print:ArrayToPdf( aPrint, nFont )
   LOCAL aAux := {}
   LOCAL aPrn := Afill( Array( 20 ), 0 )
   LOCAL i, n
   LOCAL iMax := LEN( aPrint )

   IF HB_ISARRAY( aPrint )

      aPrn[ Prn_Page_New__ ] := .T.

      /* Array of String ou Bidimensional Array */
      IF HB_ISSTRING( aPrint[ 1 ] )

         FOR i := 1 TO iMax

            IF aPrn[ Prn_Page_New__ ]

               // ::AddPage( lRetrato )
               ::AddPage( .T. )

               // Dimensoes para objetos
               aPrn[ Page_Left_____ ] := ( ::Page_Width___ * 0.050 )
               aPrn[ Page_Line_h___ ] := ( ::Page_Height__ / ::Lin_Max_H_arr )

               aPrn[ Page_Pos_v____ ] := aPrn[ Page_Line_h___ ]

               aPrn[ Prn_Page_New__ ] := .F.

            ENDIF

            // Print Element
            aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
            ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], TRAN( aPrint [ i ], '@A' ), ::oFont_F______, nFont )

            // New page ?
            IF ( aPrn[ Page_Pos_v____ ] + ( aPrn[ Page_Line_h___ ] * 2 ) ) > ::Page_Height__
               aPrn[ Prn_Page_New__ ] := .T.
            ENDIF

         NEXT

      ELSE

         /*  determine element sizes */
         aPrn[ Prn_Len_Arr___ ] := LEN( aPrint[ 1 ] )
         FOR n := 1 TO aPrn[ Prn_Len_Arr___ ]
            IF     HB_ISSTRING( aPrint[ 1, n ] )
               AADD( aAux, LEN( aPrint[ 1, n ] ) )
            ELSEIF HB_ISDATE( aPrint[ 1, n ] )
               AADD( aAux, 12 )
            ELSEIF HB_ISLOGICAL( aPrint[ 1, n ] )
               AADD( aAux,  5 )
            ELSEIF HB_ISNUMERIC( aPrint[ 1, n ] )
               AADD( aAux, LEN( ALLTRIM( STR( aPrint[ 1, n ] ) ) ) )
            ELSE
               AADD( aAux,  5 )
            ENDIF
         NEXT

         /*  determine mex element sizes */
         FOR i := 1 TO iMax
            FOR n := 1 TO aPrn[ Prn_Len_Arr___ ]
               IF     HB_ISSTRING( aPrint[ i, n ] )
                  IF aAux[ n ] <  LEN( aPrint[ i, n ] )
                     aAux[ n ] := LEN( aPrint[ i, n ] )
                  ENDIF
               ELSEIF HB_ISDATE( aPrint[ i, n ] )
                  aAux[ n ] := 10
               ELSEIF HB_ISLOGICAL( aPrint[ i, n ] )
                  aAux[ n ] :=  3
               ELSEIF HB_ISNUMERIC( aPrint[ i, n ] )
                  IF aAux[ n ] <  LEN( ALLTRIM( STR( aPrint[ i, n ] ) ) )
                     aAux[ n ] := LEN( ALLTRIM( STR( aPrint[ i, n ] ) ) )
                  ENDIF
               ELSE
                  aAux[ n ] :=  3
               ENDIF
            NEXT
         NEXT

         /* Determine line Length*/
         FOR n := 1 TO LEN( aAux )
            aPrn[ Prn_Line_Len__ ] += aAux[ n ] + 2
         NEXT
         IF aPrn[ Prn_Line_Len__ ] > 2
            aPrn[ Prn_Line_Len__ ] := IIF( aPrn[ Prn_Line_Len__ ] > 188, 188, aPrn[ Prn_Line_Len__ ] - 2 )
         ELSE
            aPrn[ Prn_Line_Len__ ] := 80
         ENDIF

         FOR i := 1 TO iMax

            IF aPrn[ Prn_Page_New__ ]

               // HPDF_AddPage
               ::oPage := HPDF_AddPage( ::obPdf )

               IF aPrn[ Prn_Line_Len__ ] > 130
                  HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE )
                  nFont := IIF( aPrn[ Prn_Line_Len__ ] > 180, 6.5, IIF( aPrn[ Prn_Line_Len__ ] > 160, 7.5, 8.5 ) )
               ELSE
                  HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
                  nFont := IIF( aPrn[ Prn_Line_Len__ ] >  90, 8, 9 )
               ENDIF

               ::Page_Height__ := HPDF_Page_GetHeight( ::oPage )
               ::Page_Width___ := HPDF_Page_GetWidth( ::oPage )

               // Dimensoes para objetos
               aPrn[ Page_Left_____ ] := ( ::Page_Width___ * 0.050 )
               aPrn[ Page_Line_h___ ] := ( ::Page_Height__ / ::Lin_Max_H_arr )

               aPrn[ Page_Pos_v____ ] := aPrn[ Page_Line_h___ ]

               aPrn[ Prn_Page_New__ ] := .F.

            ENDIF

            aPrn[ Prn_Line______ ] := ''
            // Get Line to Print
            FOR n := 1 TO aPrn[ Prn_Len_Arr___ ]
               IF Len( aPrn[ Prn_Line______ ] ) <= 188
                  IF     HB_ISSTRING( aPrint[ i, n ] )
                     aPrn[ Prn_Line______ ] += PADR( aPrint[ i, n ], aAux[ n ] + 2 )
                  ELSEIF HB_ISDATE( aPrint[ i, n ] )
                     aPrn[ Prn_Line______ ] += PADR( TRAN( aPrint[ i, n ], '@E' ), 12 )
                  ELSEIF HB_ISLOGICAL( aPrint[ i, n ] )
                     aPrn[ Prn_Line______ ] += PADR( IIF( aPrint[ i, n ], '.T.', '.F.' ), 5 )
                  ELSEIF HB_ISNUMERIC( aPrint[ i, n ] )
                     aPrn[ Prn_Line______ ] += PADL( ALLTRIM( STR( aPrint[ i, n ] ) ), aAux[ n ] ) + SPACE( 2 )
                  ELSE
                     aPrn[ Prn_Line______ ] += PADR( '.?.', 5 )
                  ENDIF
               ENDIF
            NEXT

            /* Adjust line Length*/
            aPrn[ Prn_Line______ ] := Trim( aPrn[ Prn_Line______ ] )
            IF Len( aPrn[ Prn_Line______ ] ) > 188
               aPrn[ Prn_Line______ ] := Trim( Left( aPrn[ Prn_Line______ ], 188 ) )
            ENDIF

            // Print Element
            aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
            ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], TRAN( aPrn[ Prn_Line______ ], '@A' ), ::oFont_F______, nFont )

            // New page ?
            IF ( aPrn[ Page_Pos_v____ ] + ( aPrn[ Page_Line_h___ ] * 2 ) ) > ::Page_Height__
               aPrn[ Prn_Page_New__ ] := .T.
            ENDIF

         NEXT

      ENDIF

   ENDIF

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:DbfToPdf( cAlias )
//
// *---------------------------------------------------------------------------*
Method MR_Print:DbfToPdf( cAlias )
   LOCAL i
   LOCAL nFont
   LOCAL aDbf := Afill( Array( 20 ), '' )
   LOCAL aPrn := Afill( Array( 20 ), 0 )

   aPrn[ Dbf_Page_New__ ] := .T.

   aDbf[ Dbf_nFields___ ] := ( cAlias )->( FCount() )

   /* Table Header */
   FOR i := 1 TO aDbf[ Dbf_nFields___ ]
      IF Len( aDbf[ Dbf_Header____ ] ) <= 188
         aDbf[ Dbf_Field_____ ] := ( cAlias )->( FieldName( i ) )
         aDbf[ Dbf_Header____ ] += PadR( aDbf[ Dbf_Field_____ ], ( cAlias )->( dbFieldInfo( DBS_LEN, i ) ), '_' ) + ' '
      ENDIF
   NEXT

   /* Adjust Header Length*/
   aDbf[ Dbf_Header____ ] := Trim( aDbf[ Dbf_Header____ ] )
   IF Len( aDbf[ Dbf_Header____ ] ) > 188
      aDbf[ Dbf_Header____ ] := Trim( Left( aDbf[ Dbf_Header____ ], 188 ) )
   ENDIF

   /* Table Top*/
   ( cAlias )->( dbGoTop() )

   /* LOOP */
   WHILE !( ( cAlias )->( EOF() ) )

      IF aPrn[ Dbf_Page_New__ ]

         // HPDF_AddPage
         ::oPage := HPDF_AddPage( ::obPdf )

         IF Len( aDbf[ Dbf_Header____ ] ) > 130
            HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE )
            nFont := IIF( Len( aDbf[ Dbf_Header____ ] ) > 132, 6, 7 )
         ELSE
            HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
            nFont := IIF( Len( aDbf[ Dbf_Header____ ] ) >  90, 8, 9 )
         ENDIF

         ::Page_Height__ := HPDF_Page_GetHeight( ::oPage )
         ::Page_Width___ := HPDF_Page_GetWidth( ::oPage )

         // Dimensoes para objetos
         aPrn[ Page_Left_____ ] := ( ::Page_Width___ * 0.050 )
         aPrn[ Page_Line_h___ ] := ( ::Page_Height__ / ::Lin_Max_H_arr )

         aPrn[ Dbf_Page_New__ ] := .F.

         aPrn[ Page_Pos_v____ ] := aPrn[ Page_Line_h___ ]

         // Print Element
         aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
         ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], TRAN( aDbf[ Dbf_Header____ ], '@A' ), ::oFont_F_b____, nFont )

         aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]

      ENDIF

      aDbf[ Dbf_Line_Txt__ ] := ''

      /* Table: Line to print */
      FOR i := 1 TO aDbf[ Dbf_nFields___ ]
          IF Len( aDbf[ Dbf_Line_Txt__ ] ) <= 188
             aDbf[ Dbf_Field_v___  ] := ( cAlias )->( FieldGet( i ) )
             IF HB_ISSTRING( aDbf[ Dbf_Field_v___  ] )
                aDbf[ Dbf_Field_v___  ] := aDbf[ Dbf_Field_v___  ] + ' '
             ELSEIF HB_ISDATE( aDbf[ Dbf_Field_v___  ] )
                aDbf[ Dbf_Field_v___  ] := TRAN( aDbf[ Dbf_Field_v___  ], "@E" ) + ' '
             ELSEIF HB_ISLOGICAL( aDbf[ Dbf_Field_v___  ] )
                aDbf[ Dbf_Field_v___  ] := iif( aDbf[ Dbf_Field_v___  ], 'S', 'N' )
             ELSEIF HB_ISNUMERIC( aDbf[ Dbf_Field_v___  ] )
                aDbf[ Dbf_Field_v___  ] := TRAN( aDbf[ Dbf_Field_v___  ], "@E" ) + ' '
             ELSE
                aDbf[ Dbf_Field_v___  ] := LEFT( aDbf[ Dbf_Field_v___  ], 12 ) + ' '
             ENDIF
             aDbf[ Dbf_Line_Txt__ ] += aDbf[ Dbf_Field_v___  ]
          ENDIF
      NEXT

      /* Adjust Header Length*/
      aDbf[ Dbf_Line_Txt__ ] := TRIM(  aDbf[ Dbf_Line_Txt__ ] )
      IF Len( TRIM( aDbf[ Dbf_Line_Txt__ ] ) ) > 188
         aDbf[ Dbf_Line_Txt__ ] := TRIM( Left( aDbf[ Dbf_Line_Txt__ ], 188 ) )
      ENDIF

      // Print Element
      aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
      ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], TRAN( aDbf[ Dbf_Line_Txt__ ], '@A' ), ::oFont_F______, nFont )

      // New page ?
      IF ( aPrn[ Page_Pos_v____ ] + ( aPrn[ Page_Line_h___ ] * 2 ) ) > ::Page_Height__
         aPrn[ Dbf_Page_New__ ] := .T.
      ENDIF

      ( cAlias )->( DBSKIP() )

   END

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:PrnToPdf( cFile, nFont )
//
// *---------------------------------------------------------------------------*
Method MR_Print:PrnToPdf( cFile, nFont )
   LOCAL i := 0
   LOCAL aPrn := Afill( Array( 20 ), 0 )
   LOCAL oFile := TFileRead():New( cFile )

   aPrn[ Prn_Page_New__ ] := .T.

   /* oFile:Open() */
   oFile:Open()
   IF !( oFile:Error() )

      WHILE oFile:MoreToRead()

         aPrn[ Prn_Line______ ] := oFile:ReadLine()

         // Linha
         i++

         // New page ?
         aPrn[ Prn_Eject_____ ] := hb_AT( CHR(12), aPrn[ Prn_Line______ ] )
         IF aPrn[ Prn_Eject_____ ] > 0
            IF i > aPrn[ Prn_Lines_Max_ ]
               aPrn[ Prn_Lines_Max_ ] := i
            ENDIF
            i := 0
            aPrn[ Prn_Line______ ] := SUBSTR( aPrn[ Prn_Line______ ], 1, aPrn[ Prn_Eject_____ ] - 1 )
         ENDIF

         // Colunas
         aPrn[ Prn_Cols______ ] := LEN( aPrn[ Prn_Line______ ] )
         IF aPrn[ Prn_Cols_Max__ ] <  aPrn[ Prn_Cols______ ]
            aPrn[ Prn_Cols_Max__ ] := aPrn[ Prn_Cols______ ]
         ENDIF

      END

      aPrn[ Prn_Cols_Max__ ] := IIF( aPrn[ Prn_Cols_Max__ ] ==  0, 132, IIF( aPrn[ Prn_Cols_Max__ ] > 188, 188, aPrn[ Prn_Cols_Max__ ] ) )

      IF aPrn[ Prn_Lines_Max_ ] > 0
         IF aPrn[ Prn_Lines_Max_ ] > 34
            aPrn[ Prn_Lines_Max_ ] := IIF( aPrn[ Prn_Lines_Max_ ] > ::Lin_Max_H_Prn, ::Lin_Max_H_Prn, aPrn[ Prn_Lines_Max_ ] )
         ELSE
            aPrn[ Prn_Lines_Max_ ] := IIF( aPrn[ Prn_Lines_Max_ ] >= 33, 66, 88 )
         ENDIF
      ELSE
         aPrn[ Prn_Lines_Max_ ] := ::Lin_Max_H_Prn
      ENDIF

   END
   oFile:Close()

   // LEITURA E IMPRESSãO DO ARQUIVO PRN
   oFile:Open()
   IF !( oFile:Error() )

      WHILE oFile:MoreToRead()

         IF aPrn[ Prn_Page_New__ ]

            // ::AddPage( lRetrato )
            IF aPrn[ Prn_Cols_Max__ ] <= 132

               /* AddPage */
               ::AddPage( .T. )

               /* font Size */
               nFont := iif( aPrn[ Prn_Cols_Max__ ] <= 92, 11,  7 )

               /* Left Pos */
               aPrn[ Page_Left_____ ] := iif( aPrn[ Prn_Cols_Max__ ] <= 92, ( ::Page_Width___ * 0.100 ),  ( ::Page_Width___ * 0.055 ) )

            ELSE

               /* AddPage */
               ::AddPage( .F. )

               /* font Size */
               nFont := iif( aPrn[ Prn_Cols_Max__ ] <= 160,  8,  7 )

               /* Left Pos */
               aPrn[ Page_Left_____ ] := iif( aPrn[ Prn_Cols_Max__ ] <= 160, ( ::Page_Width___ * 0.075 ),  ( ::Page_Width___ * 0.050 ) )

            ENDIF

            // Dimensoes para objetos
            aPrn[ Page_Line_h___ ] := ( ::Page_Height__ / ( aPrn[ Prn_Lines_Max_ ] + 3 ) )

            aPrn[ Page_Pos_v____ ] := aPrn[ Page_Line_h___ ]

            aPrn[ Prn_Page_New__ ] := .F.

         ENDIF

         aPrn[ Prn_Line______ ] := oFile:ReadLine()

         // New page ?
         aPrn[ Prn_Eject_____ ] := hb_AT( CHR(12), aPrn[ Prn_Line______ ] )
         IF aPrn[ Prn_Eject_____ ] # 0
            aPrn[ Prn_Line______ ] := IIF( aPrn[ Prn_Eject_____ ] > 1, TRIM( Left( aPrn[ Prn_Line______ ], aPrn[ Prn_Eject_____ ] ) ), '' )
            aPrn[ Prn_Page_New__ ] := ( aPrn[ Page_Pos_v____ ] > ( aPrn[ Page_Line_h___ ] * 3 ) )
         ENDIF

         // Print Element
         aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
         ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], hb_OEMtoANSI( aPrn[ Prn_Line______ ] ), ::oFont_F______, nFont )

         // New page ?
         IF ( aPrn[ Page_Pos_v____ ] + ( aPrn[ Page_Line_h___ ] * 2 ) ) > ::Page_Height__
            aPrn[ Prn_Page_New__ ] := .T.
         ENDIF

      END
   END

   oFile:Close()

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:TxtToPDF( cFile, nFont )
//
// *---------------------------------------------------------------------------*
Method MR_Print:TxtToPDF( cFile, nFont )
   LOCAL aPrn := Afill( Array( 20 ), 0 )
   LOCAL oFile := TFileRead():New( cFile )

   aPrn[ Prn_Page_New__ ] := .T.

   oFile:Open()

   // LEITURA DO ARQUIVO TXT
   IF !( oFile:Error() )

      WHILE oFile:MoreToRead()

         IF aPrn[ Prn_Page_New__ ]

            // ::AddPage( lRetrato )
            ::AddPage( .F. )

            // Dimensoes para objetos
            aPrn[ Page_Left_____ ] := ( ::Page_Width___ * 0.050 )
            aPrn[ Page_Line_h___ ] := ( ::Page_Height__ / ::Lin_Max_H_Txt )

            aPrn[ Page_Pos_v____ ] := aPrn[ Page_Line_h___ ]

            aPrn[ Prn_Page_New__ ] := .F.

         ENDIF

         aPrn[ Prn_Line______ ] := oFile:ReadLine()

         // Print Element
         aPrn[ Page_Pos_v____ ] += aPrn[ Page_Line_h___ ]
         ::Draw_Text( aPrn[ Page_Left_____ ], aPrn[ Page_Pos_v____ ], hb_OEMtoANSI( aPrn[ Prn_Line______ ] ), ::oFont_F______, nFont )

         // New page ?
         IF ( aPrn[ Page_Pos_v____ ] + ( aPrn[ Page_Line_h___ ] * 2 ) ) > ::Page_Height__
            aPrn[ Prn_Page_New__ ] := .T.
         ENDIF

      END

   END

   oFile:Close()

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Text( nLeft, nTop, cTxt, oFont, nSize, nColor )
   LOCAL aColor

   /* FONT COLOR */
   IF !( hb_ISNIL( nColor ) )
      aColor := IIF( nColor == 1, {255,0,0}, IIF( nColor == 2, {0,255,0}, IIF( nColor == 3, {0,0,255}, {0,0,0} ) ) )
      ::Set_Font_Color( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

   /* FONT and SIZE*/
   HPDF_Page_SetFontAndSize( ::oPage, oFont, nSize )

   /* text output */
   HPDF_Page_BeginText( ::oPage )
   HPDF_Page_TextOut( ::oPage, nLeft, ( ::Page_Height__ - nTop ), cTxt )
   HPDF_Page_EndText( ::oPage )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Text_Rotated( nLeft, nTop, cTxt, oFont, nSize, nColor, nAngle )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Text_Rotated( nLeft, nTop, cTxt, oFont, nSize, nColor, nAngle )
   LOCAL aColor
   LOCAL nRadian := ( nAngle / 180 ) * 3.141592 /* Calcurate the radian value. */

   /* FONT COLOR */
   IF !( hb_ISNIL( nColor ) )
      aColor := IIF( nColor == 1, {255,0,0}, IIF( nColor == 2, {0,255,0}, IIF( nColor == 3, {0,0,255}, {0,0,0} ) ) )
      ::Set_Font_Color( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

   /* FONT and SIZE*/
   HPDF_Page_SetFontAndSize( ::oPage, oFont, nSize )

   /* Rotating text */
   HPDF_Page_BeginText( ::oPage )
   HPDF_Page_SetTextMatrix( ::oPage, cos( nRadian ), sin( nRadian ), -( sin( nRadian ) ), cos( nRadian ), nLeft, ::Page_Height__-( nTop ) )
   HPDF_Page_ShowText( ::oPage, cTxt )
   HPDF_Page_EndText( ::oPage )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Text_Formated( nLeft, nTop, nRight, nBottom, cTxt, oFont, nSize, nAlign, nColor )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Text_Formated( nLeft, nTop, nRight, nBottom, cTxt, oFont, nSize, nAlign, nColor )
   LOCAL aColor
   LOCAL nAlignment

   /* FONT ALIGNMENT */
   nAlign := hb_defaultValue( nAlign, 4 )
   nAlignment := IIF( nAlign == 1, HPDF_TALIGN_LEFT, IIF( nAlign == 2, HPDF_TALIGN_RIGHT, IIF( nAlign == 3, HPDF_TALIGN_CENTER, HPDF_TALIGN_JUSTIFY ) ) )

   /* FONT COLOR */
   IF !( hb_ISNIL( nColor ) )
      aColor := IIF( nColor == 1, {255,0,0}, IIF( nColor == 2, {0,255,0}, IIF( nColor == 3, {0,0,255}, {0,0,0} ) ) )
      ::Set_Font_Color( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

   /* FONT and SIZE */
   HPDF_Page_SetFontAndSize( ::oPage, oFont, nSize )

   /* Print text */
   HPDF_Page_BeginText( ::oPage )
   HPDF_Page_TextRect( ::oPage, nLeft, ::Page_Height__-( nTop ), nRight, ::Page_Height__-( nBottom ), cTxt, nAlignment, NIL )
   HPDF_Page_EndText( ::oPage )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Box( x, y, w, h, nPenSize, aColor, nType )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Box( x, y, w, h, nPenSize, aColor, nType )

   /* hb_defaultValue */
   nType := hb_defaultValue( nType, 1 )

   /* Pen Size */
   HPDF_Page_SetLineWidth( ::oPage, nPenSize )

   /* Stroke */
   HPDF_Page_SetRGBStroke( ::oPage, 0, 0, 0 )

   /* Pen Fill */
   ::Set_Font_Color( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )

   /* Draw Rectangle */
   HPDF_Page_Rectangle( ::oPage, x, ( ::Page_Height__ - y ), w, h )

   /* only borders */
   IF nType == 1
     HPDF_Page_Stroke( ::oPage )
   ENDIF

   /* Fill borderless */
   IF nType == 2
   HPDF_Page_Fill( ::oPage )
   ENDIF

   /* Fill + borders */
   IF nType == 3
   HPDF_Page_FillStroke( ::oPage )
   ENDIF

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// Method MR_Print:Draw_Line( x, y, w, h, nPenSize )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Line( x, y, w, h, nPenSize )

   /* line output */
   HPDF_Page_SetLineWidth( ::oPage, nPenSize )
   HPDF_Page_MoveTo( ::oPage, x, ( ::Page_Height__ - y ) )
   HPDF_Page_LineTo( ::oPage, w, ( ::Page_Height__ - h ) )
   HPDF_Page_Stroke( ::oPage )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Image( nLeft, nTop, nWidth, nHeight, cFImage )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Image( nLeft, nTop, nWidth, nHeight, cFImage )
   Local oImage

   /* image output */
   IF hb_FileExists( cFImage )
      oImage := HPDF_LoadJPEGImageFromFile( ::obPdf, cFImage )
      HPDF_Page_DrawImage( ::oPage, oImage, nLeft, ( ::Page_Height__ - nTop ), nWidth, nHeight )
   ELSE
     ::Draw_Text( nLeft, nTop - ( ::Page_Height__ * 0.005 ), '! ' + cFImage + ' !', ::oFont_v______, 12 )
   ENDIF

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Draw_Zebra( ... )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Draw_Zebra( ... )

   LOCAL nRet

   /* barrcode output */
   IF ( nRet := hb_zebra_GetError( ::hZebra_______ ) ) <> 0
      nRet := HB_ZEBRA_ERROR_INVALIDZEBRA
   ELSE
     hb_zebra_draw( ::hZebra_______, {| x, y, w, h | HPDF_Page_Rectangle( ::oPage, x, y, w, h ) }, ... )

     HPDF_Page_Fill( ::oPage )
   ENDIF

   RETURN nRet

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Set_Font_Color( r, g, b )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Set_Font_Color( r, g, b )

   r := IIF( ( r / 255 ) < 0, 0, IIF( ( r / 255 ) > 1, 1, ( r / 255 ) ) )
   g := IIF( ( g / 255 ) < 0, 0, IIF( ( g / 255 ) > 1, 1, ( g / 255 ) ) )
   b := IIF( ( b / 255 ) < 0, 0, IIF( ( b / 255 ) > 1, 1, ( b / 255 ) ) )

   HPDF_Page_SetRGBFill( ::oPage, r, g, b )

   Return NIL

// *---------------------------------------------------------------------------*
//
// M., Ronaldo: Sistema de Impressão em harbour ( PDF Printer )
//
// MR_Print:Finish( lOpen )
//
// *---------------------------------------------------------------------------*
Method MR_Print:Finish( lOpen )

   IF hb_FileExists( ::oFile )
      FERASE( ::oFile )
   ENDIF

   HPDF_SaveToFile( ::obPdf, ::oFile )

   hPDF_Free( ::obPdf )

   IF lOpen
      IF hb_FileExists( ::oFile )

         hb_RUN( ::oFile )
*        wapi_ShellExecute( 0, 'Open', ::oFile, , , 3 ) // SW_SHOWMAXIMIZED  3

      ENDIF
   ENDIF

   Return NIL
