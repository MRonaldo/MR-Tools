#include "hbclass.ch"
#include "harupdf.ch"
#include "hbzebra.ch"

#define Pdf_Instrucoes    8
#define Pdf_Demonstr__   20

#define Bol_Start_Date    STOD( "19971007" )

#define Font_Fixa_____    "Courier"
#define Font_Variavel_    "Helvetica"
#define Font_Code_Page    'WinAnsiEncoding'
#define Font_Small____   06
#define Font_Normal___   09
#define Font_Large____   12

#define Page_Left_____    1
#define Page_Line_Size    2
#define Page_Pos_S00__   10
#define Page_Pos_S01__   11
#define Page_Pos_v____   12
#define Page_Pos_z____   13

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Classe: MR_Boleto
//
//*----------------------------------------------------------------------------*
Create Class MR_Boleto

   //*-------------------------------------------------------------------------*
   // Objeto: HaruPDF
   //*-------------------------------------------------------------------------*
   VAR o_Pdf

   //*-------------------------------------------------------------------------*
   // Objeto: Página PDF
   //*-------------------------------------------------------------------------*
   VAR oPage

   //*-------------------------------------------------------------------------*
   // Arquivo PDF
   //*-------------------------------------------------------------------------*
   VAR oFile

   //*-------------------------------------------------------------------------*
   // Fonte para Impressão
   //*-------------------------------------------------------------------------*
   VAR oFont_f______
   VAR oFont_v______

   //*-------------------------------------------------------------------------*
   // Cedente: Banco
   //*-------------------------------------------------------------------------*
   VAR Banco________   INIT '104'
   VAR Banco_Nome___   INIT ''
   VAR Banco_Dv_____   INIT '0'
   VAR Banco_Agencia   INIT ''
   VAR Banco_Ag_Dv__   INIT ''
   VAR Banco_Ag_Un_A   INIT ''

   VAR Ag_Cod_Cedent   INIT ''

   VAR Moeda________   INIT '9'

   //*-------------------------------------------------------------------------*
   // Local de Pagamento
   //*-------------------------------------------------------------------------*
   VAR Local_Pagamen   INIT ''

   //*-------------------------------------------------------------------------*
   // Cedente: Conta
   //*-------------------------------------------------------------------------*
   VAR Conta________   INIT ''
   VAR Conta_DV_____   INIT ''
   VAR Conta_OP_____   INIT ''

   //*-------------------------------------------------------------------------*
   // Cedente: Prefixo ( Parte Integrante do Nosso Numero )
   //*-------------------------------------------------------------------------*
   VAR Prefixo______   INIT '0'
   VAR Prefixo_DV___   INIT ''

   //*-------------------------------------------------------------------------*
   // Cedente: Carteira
   //*-------------------------------------------------------------------------*
   VAR Carteira_____   INIT ''
   VAR Carteira_Tipo   INIT ''

   //*-------------------------------------------------------------------------*
   // Cedente: Nosso Numero
   //*-------------------------------------------------------------------------*
   VAR NossoNumero__   INIT ''
   VAR NossoNumer_DV   INIT ''
   VAR NossoNumero_z   INIT ''

   //*-------------------------------------------------------------------------*
   // Boleto: Linha Digitavel
   //*-------------------------------------------------------------------------*
   VAR Campo_Livre__   INIT ''
   VAR Ln_Digitavel_   INIT REPL( '0', 44 )

   //*-------------------------------------------------------------------------*
   // Boleto: Representação Numerica do Código de Barras
   //*-------------------------------------------------------------------------*
   VAR Cod_Barras___   INIT ''
   VAR Cod_Barras_DV   INIT ''

   //*-------------------------------------------------------------------------*
   // Boleto: Origem do valor ( NF, NFe, NFSe, Duplicata, Promissória, etc... )
   //*-------------------------------------------------------------------------*
   VAR Doc_Origem___   INIT ''
   VAR Doc_Numero___   INIT ''
   VAR Doc_Data_____   INIT DATE()
   VAR Doc_Aceite___   INIT ''
   VAR Doc_Especie__   INIT ''

   //*-------------------------------------------------------------------------*
   // Boleto: Dados Base
   //*-------------------------------------------------------------------------*
   VAR Vencimento___   INIT DATE()
   VAR Vencim_Fator_   INIT DATE()
   VAR Valor________   INIT 0
   VAR Multa_Auto___   INIT 0
   VAR Juros_Mes____   INIT 0
   VAR Numero_Vias__   INIT 2

   //*-------------------------------------------------------------------------*
   // Boleto: Instruções: {} ( Exemplo: instruções e discriminação da cobrança)
   //*-------------------------------------------------------------------------*
   VAR Instrucoes___   INIT AFILL( ARRAY( Pdf_Instrucoes ), '' )
   VAR Demonstrativo   INIT AFILL( ARRAY( Pdf_Demonstr__ ), '' )

   //*-------------------------------------------------------------------------*
   // Boleto: Cedente {}
   //*-------------------------------------------------------------------------*
   VAR Cedente______   INIT AFILL( ARRAY( 4 ), '' )

   //*-------------------------------------------------------------------------*
   // Boleto: Sacado {}
   //*-------------------------------------------------------------------------*
   VAR Sacado_______   INIT AFILL( ARRAY( 4 ), '' )

   //*-------------------------------------------------------------------------*
   // Boleto: avalista {}
   //*-------------------------------------------------------------------------*
   VAR Avalista_____   INIT AFILL( ARRAY( 4 ), '' )

   //*-------------------------------------------------------------------------*
   // Representação gráfica para o Código de Barras
   //*-------------------------------------------------------------------------*
   VAR hZebra_______

   //*-------------------------------------------------------------------------*
   // Dimensoes da Pagina utilizada
   //*-------------------------------------------------------------------------*
   VAR Page_Height__   INIT 0
   VAR Page_Width___   INIT 0

   //*-------------------------------------------------------------------------*
   // Metodos da Classe
   //*-------------------------------------------------------------------------*
   Method New( cFilePdf ) Constructor
   Method AddPage()
   Method Draw_Text( nLeft, nTop, cTxt, oFont, nSize )
   Method Draw_Line( x, y, w, z, nPenSize )
   Method Draw_Image( nLeft, nTop, nWidth, nHeight )
   Method Draw_Zebra( ... )
   Method Update()
   Method Execute()
   Method Banco_001()
   Method Banco_033()
   Method Banco_104()
   Method Banco_237()
   Method Banco_341()
   Method Banco_399()
   Method Banco_422()
   Method Banco_748()
   Method Finish( lOpen )
   Method DC_Mod10( c_Banco, mNMOG )
   Method DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 )
   Method DC_ModEsp( c_Banco, mNMOG )
   Method Interleaved_2of5()

   EndClass

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method New( cFilePdf ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method New( cFilePdf ) Class MR_Boleto

   ::o_Pdf := HPDF_New()
   ::oFile := cFilePdf

   HPDF_SetCompressionMode( ::o_Pdf, HPDF_COMP_ALL )

   //*-------------------------------------------------------------------------*
   // Fonte Tamanho Fixo
   //*-------------------------------------------------------------------------*
   ::oFont_f______ := HPDF_GetFont( ::o_Pdf, Font_Fixa_____, Font_Code_Page )

   //*-------------------------------------------------------------------------*
   // Fonte Espaçamento Variavel
   //*-------------------------------------------------------------------------*
   ::oFont_v______ := HPDF_GetFont( ::o_Pdf, Font_Variavel_, Font_Code_Page )

   Return( Self )

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method AddPage() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method AddPage() Class MR_Boleto
   LOCAL aPos := Afill( Array( 20 ), 0 )
   LOCAL i
   LOCAL cAux

   ::Update()

   ::Execute()

   ::oPage := HPDF_AddPage( ::o_Pdf )

   HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )

   ::Page_Height__ := HPDF_Page_GetHeight( ::oPage )
   ::Page_Width___ := HPDF_Page_GetWidth( ::oPage )

   //*-------------------------------------------------------------------------*
   // Dimensoes para objetos
   //*-------------------------------------------------------------------------*
   aPos[ Page_Left_____ ] += ( ::Page_Width___ * 0.033 )
   aPos[ Page_Line_Size ] += ( ::Page_Width___ - aPos[ Page_Left_____ ] )

   //*-------------------------------------------------------------------------*
   // 1a Via - Controle do Cedente
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] += ( ::Page_Height__ * 0.026 )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.044 )

   IF ::Numero_Vias__ > 2
   
   //*-------------------------------------------------------------------------*
   // Código do Banco e Linha Digitavel
   //*-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   //*-------------------------------------------------------------------------*
   // Logo do Banco
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Cedente', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Cedente______[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Vencimento___, "@E")
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + 0, aPos[ Page_Pos_v____ ], TRAN( 'Agência/Código do Cedente', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.200 ), aPos[ Page_Pos_v____ ], TRAN( 'Número do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.400 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Número', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := ::Ag_Cod_Cedent
   ::Draw_Text( aPos[ Page_Left_____ ] + 0, aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.200 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.400 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical *
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Sacado:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Sacado_______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 3 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 4 ], '@A' ), ::oFont_v______, Font_Normal___ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'VIA PARA CONTROLE DO CEDENTE', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.026 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ] * 0.440, aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.560 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.455 ), aPos[ Page_Pos_v____ ] + ( ::Page_Height__ * 0.002 ), TRAN( 'Recorte Aqui', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // 2a Via - RECIBO DO SACADO
   //*-------------------------------------------------------------------------*

   //*-------------------------------------------------------------------------*
   // Coordenadas
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := ( ::Page_Height__ * 0.170 )
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.186 )

   ENDIF

   //*-------------------------------------------------------------------------*
   // Código do Banco e Linha Digitavel
   //*-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   //*-------------------------------------------------------------------------*
   // Logo do Banco
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Local de Pagamento:', '@A' ), ::oFont_v______, Font_Small____ )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
     cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
     ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 2 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ELSE
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , TRAN( ::Vencimento___, "@E"), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Cedente', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Cedente______[ 1 ] + SPACE( 3 ) + ::Cedente______[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Agência/Código do Cedente', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Cedente______[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := ::Ag_Cod_Cedent
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Data do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], TRAN( 'Número do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Espécie Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], TRAN( 'Aceite', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Data de Processamento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Número', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Doc_Data_____, '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Origem___, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Aceite___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( DATE(), '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical *
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Demonstrativo da Cobrança:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.004 )
   FOR i := 1 TO ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
      aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( STRZERO( i, 2 ) + SPACE( 2 ) + ::Demonstrativo[ i ], '@A' ), ::oFont_f______, Font_Small____ )
   NEXT

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Instruções: ( Todas as informações impressas neste boleto, são de exclusiva responsabilidade do cedente )', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Desconto/Abatimento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto: Instruções
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] := aPos[ Page_Pos_v____ ]
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Multa Automática - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ::Multa_Auto___ / 100 ), 2 ), '@E 999,999,999.99' ) + ' : Acrescer ao valor total para pagamento em atrazo.', ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto: Instruções
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Juros de Mora de - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ), '@E 999,999,999.99' ) + ' / Dia.', ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.010 )
   FOR i := 1 TO Pdf_Instrucoes
      aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], TRAN( STRZERO( i, 2 ) + SPACE( 2 ) + ::Instrucoes___[ i ], '@A' ), ::oFont_v______, Font_Small____ )
   NEXT

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Outras Deduções', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Mora / Multa', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Outros Acrescimos', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor Cobrado', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Sacado:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Sacado_______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 3 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 4 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Sacador / Avalista:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.000 )
   //*-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ], TRAN( ::Avalista_____[ 1 ] + SPACE( 3 ) + ::Avalista_____[ 2 ] +  SPACE( 3 ) + ::Avalista_____[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'MR Boleto: Título processado e impresso pelo cedente', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Autenticação Mecanica - Recibo do Sacado', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // 3a Via - Ficha de Compensação
   //*-------------------------------------------------------------------------*

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.655 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ] * 0.440, aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.560 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.455 ), aPos[ Page_Pos_v____ ] + ( ::Page_Height__ * 0.002 ), TRAN( 'Recorte Aqui', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Coordenadas
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := ( ::Page_Height__ * 0.670 )
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.686 )

   //*-------------------------------------------------------------------------*
   // Código do Banco e Linha Digitavel
   //*-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   //*-------------------------------------------------------------------------*
   // Logo do Banco
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Local de Pagamento', '@A' ), ::oFont_v______, Font_Small____ )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 2 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ELSE
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , TRAN( ::Vencimento___, "@E"), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Cedente', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Cedente______[ 1 ] + SPACE( 3 ) + ::Cedente______[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Agência/Código do Cedente', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Cedente______[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := ::Ag_Cod_Cedent
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Data do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], TRAN( 'Número do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Espécie Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], TRAN( 'Aceite', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Data de Processamento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Número', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Doc_Data_____, '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Origem___, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Aceite___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( DATE(), '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Save last Vertical Pos
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Uso do Banco', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.220 ), aPos[ Page_Pos_v____ ], TRAN( 'Carteira', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Espécie', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.420 ), aPos[ Page_Pos_v____ ], TRAN( 'Quantidade', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Valor', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Carteira_____, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.220 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Especie__, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.215 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.215 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.415 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.415 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Instruções: ( Todas as informações impressas neste boleto, são de exclusiva responsabilidade do cedente )', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Desconto/Abatimento', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto: Instruções
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] := aPos[ Page_Pos_v____ ]
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.004 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Multa Automática - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ::Multa_Auto___ / 100 ), 2 ), '@E 999,999,999.99' ) + ' : Acrescer ao valor total para pagamento em atrazo.', ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto: Instruções
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Juros de Mora de - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ), '@E 999,999,999.99' ) + ' / Dia.', ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.004 )
   FOR i := 1 TO Pdf_Instrucoes
      aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], TRAN( STRZERO( i, 2 ) + SPACE( 2 ) + ::Instrucoes___[ i ], '@A' ), ::oFont_v______, Font_Small____ )
   NEXT

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Outras Deduções', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Mora / Multa', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Outros Acrescimos', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor Cobrado', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Linha Vertical
   //*-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Sacado:', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Código de Baixa:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Sacado_______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 3 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Sacado_______[ 4 ], '@A' ), ::oFont_v______, Font_Normal___ )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Sacador / Avalista:', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.000 )
   //*-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ], TRAN( ::Avalista_____[ 1 ] + SPACE( 3 ) + ::Avalista_____[ 2 ] +  SPACE( 3 ) + ::Avalista_____[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'MR Boleto: Título processado e impresso pelo cedente', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   //*-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Autenticação Mecanica - Ficha de Compensação', '@A' ), ::oFont_v______, Font_Small____ )

   //*-------------------------------------------------------------------------*
   // IMAGEM DO CÓDIGO DE BARRAS
   //*-------------------------------------------------------------------------*
   ::hZebra_______ := hb_zebra_create_itf( ::Cod_Barras___, HB_ZEBRA_FLAG_WIDE2_5 )
   IF ( ::hZebra_______ != NIL )

      IF hb_zebra_geterror( ::hZebra_______ ) == 0
         ::Draw_Zebra( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.010 ), ( ::Page_Height__ * 0.060 ), 0.40, -( ::Page_Height__ * 0.045 ) )
      ELSE
         ? "Error", hb_zebra_geterror( ::hZebra_______ )
      ENDIF

   ENDIF

   //*-------------------------------------------------------------------------*
   // Kill object
   //*-------------------------------------------------------------------------*
   hb_zebra_destroy( ::hZebra_______ )

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Update() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Update() Class MR_Boleto

   if HB_ISSTRING( ::Instrucoes___ )
      ::Instrucoes___ := { ::Instrucoes___ }
   endif

   IF Len( ::Instrucoes___ ) < Pdf_Instrucoes
      WHILE Len( ::Instrucoes___ ) < Pdf_Instrucoes
         AADD( ::Instrucoes___, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Demonstrativo )
      ::Demonstrativo := { ::Demonstrativo }
   endif

   IF Len( ::Demonstrativo ) < ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
      WHILE Len( ::Demonstrativo ) < ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
         AADD( ::Demonstrativo, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Local_Pagamen )
      ::Local_Pagamen := { ::Local_Pagamen }
   endif

   IF Len( ::Local_Pagamen ) < 2
      WHILE Len( ::Local_Pagamen ) < 2
         AADD( ::Local_Pagamen, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Cedente______ )
      ::Cedente______ := { ::Cedente______ }
   endif

   IF Len( ::Cedente______ ) < 4
      WHILE Len( ::Cedente______ ) < 4
         AADD( ::Cedente______, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Sacado_______ )
      ::Sacado_______ := { ::Sacado_______ }
   endif

   IF Len( ::Sacado_______ ) < 4
      WHILE Len( ::Sacado_______ ) < 4
         AADD( ::Sacado_______, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Avalista_____ )
      ::Avalista_____ := { ::Avalista_____ }
   endif

   IF Len( ::Avalista_____ ) < 4
      WHILE Len( ::Avalista_____ ) < 4
         AADD( ::Avalista_____, '' )
      ENDDO
   ENDIF

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Execute() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Execute() Class MR_Boleto
   LOCAL aAux := ARRAY( 5 )

   DO CASE

   CASE ::Banco________ == "001"

        ::Banco_001()

   CASE ::Banco________ == "033"

        ::Banco_033()

   CASE ::Banco________ == "104"

        ::Banco_104()

   CASE ::Banco________ == "237"

        ::Banco_237()

   CASE ::Banco________ == "341"

        ::Banco_341()

   CASE ::Banco________ == "399"

        ::Banco_399()

   CASE ::Banco________ == "422"

        ::Banco_422()

   CASE ::Banco________ == "748"

        ::Banco_748()

   OTHERWISE

        ::Banco_Dv_____ := "X"
        ::Banco_Nome___ := "Banco Inválido"

        ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + '-' + ::Banco_Ag_Dv__ + '/'+ ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ENDCASE

   ::Vencim_Fator_ := STRZERO( ::Vencimento___ - Bol_Start_Date, 4 )

   //*-------------------------------------------------------------------------*
   // Monta Código de Barras (p/ Banco)
   //*-------------------------------------------------------------------------*
   ::Cod_Barras_DV := ::DC_Mod11( ::Banco________, 9, .T. , ::Banco________ + ::Moeda________ + ::Vencim_Fator_ + StrZero( ::Valor________ * 100,10 ) + ::Campo_Livre__, .F. )
   ::Cod_Barras___ := ::Banco________ + ::Moeda________ + ::Cod_Barras_DV + ::Vencim_Fator_ + StrZero( ::Valor________ * 100, 10 ) + ::Campo_Livre__

   //*-------------------------------------------------------------------------*
   // REPRESENTAÇÃO NUMERICA DO CODIGO DE BARRAS
   //*-------------------------------------------------------------------------*
   aAux[ 1 ] := ::Banco________ + ::Moeda________ + SubStr( ::Campo_Livre__,  1, 5 )
   aAux[ 1 ] += ::DC_Mod10( ::Banco________, aAux[  1 ] )
   aAux[ 2 ] := SubStr( ::Campo_Livre__,  6, 10 )
   aAux[ 2 ] += ::DC_Mod10( ::Banco________, aAux[  2 ] )
   aAux[ 3 ] := SubStr( ::Campo_Livre__, 16, 10 )
   aAux[ 3 ] += ::DC_Mod10( ::Banco________, aAux[  3 ] )
   aAux[ 4 ] := ::Cod_Barras_DV
   aAux[ 5 ] := ::Vencim_Fator_ + StrZero( ::Valor________ * 100, 10 )
   //*-------------------------------------------------------------------------*
   // LINHA DIGITAVEL - 05 Conjuntos Numericos
   //*-------------------------------------------------------------------------*
   ::Ln_Digitavel_ := LEFT( aAux[ 1 ], 5 ) + '.' + SubStr( aAux[ 1 ], 6 ) + " " + ;
                      Left( aAux[ 2 ], 5 ) + "." + SubStr( aAux[ 2 ], 6 ) + " " + ;
                      Left( aAux[ 3 ], 5 ) + "." + SubStr( aAux[ 3 ], 6 ) + " " + ;
                      aAux[ 4 ] + " " +  ;
                      aAux[ 5 ]

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_001() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_001() Class MR_Boleto

   ::Banco_Dv_____ := "9"
   ::Banco_Nome___ := "Banco do Brasil"

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______, 6 ) ), 6, '0' )
   ::Prefixo_DV___ := PADL( ALLTRIM( Left( ::Prefixo_DV___, 1 ) ), 1, '0' )

   IF Left( ::Carteira_____, 2 ) $ "16|18|SR"

      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )

      ::NossoNumero__ := ::Prefixo______ + ::Prefixo_DV___+ PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F. , ::NossoNumero__, .F. )

      ::NossoNumero_z := ::NossoNumero__ + '-' + ::NossoNumer_DV

           //*-----------------------------------------------------------------*
           // Indicacao do NN com 17 Posicoes Livres
           //*-----------------------------------------------------------------*
      ::Campo_Livre__:= REPL( '0', 6 ) + ::NossoNumero__ + ::Carteira_____

   ELSE

      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 8, '0' )

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )

      ::NossoNumero__ := ::Prefixo______ + PADL( ALLTRIM( Left( ::NossoNumero__, 5 ) ), 5, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

      ::NossoNumero_z := Tran( ::NossoNumero__, "@R 99.999.999.999" ) + "-" + ::NossoNumer_DV

      ::Campo_Livre__:= ::NossoNumero__ + ::Banco_Agencia + ::Conta________ + ::Carteira_____

   ENDIF

   ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + '-' + ::Banco_Ag_Dv__ + '/'+ ::Conta________ + '-' + ::Conta_DV_____, "@!")

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_033() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_033() Class MR_Boleto

   ::Banco_Dv_____ := "7"
   ::Banco_Nome___ := "Banco Santander"

   IF EMPTY( ::Prefixo______ )
      ::Prefixo______ := ::Conta________
      ::Conta________ := ''
      ::Prefixo_DV___ := ::Conta_DV_____
      ::Conta_DV_____ := ''
   ENDIF

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  6 ) ),  6, '0' )
   ::Prefixo_DV___ := PADL( ALLTRIM( Left( ::Prefixo_DV___,  1 ) ),  1, '0' )

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 12 ) ), 12, '0' )
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

   ::NossoNumero_z := ::NossoNumero__ + " " + ::NossoNumer_DV

   ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + '/' + ::Prefixo______ + '-' + ::Prefixo_DV___, "@!")

   ::Campo_Livre__ := '9' + ::Prefixo______ + ::NossoNumero__ + ::NossoNumer_DV  + '0102'

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_104() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_104() Class MR_Boleto

   ::Banco_Dv_____ := "0"
   ::Banco_Nome___ := "Caixa"

   IF EMPTY( ::Prefixo______ )
      ::Prefixo______ := ::Conta________
      ::Conta________ := ''
      ::Prefixo_DV___ := ::Conta_DV_____
      ::Conta_DV_____ := ''
   ENDIF

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  8 ) ), 8, '0' )

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

   ::NossoNumero_z := ::NossoNumero__ + "-" + ::NossoNumer_DV

   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia,  4 ) ),  4, '0' )

   ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + '.' + ::Conta_OP_____ + '.' + ::Prefixo______ + '.' + ::Prefixo_DV___, "@!")

   ::Campo_Livre__:= ::NossoNumero__ + ::Banco_Agencia + ::Conta_OP_____ + ::Prefixo______

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_237() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_237() Class MR_Boleto

   ::Banco_Dv_____ := "2"
   ::Banco_Nome___ := "Bradesco"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 3 ) ), 3, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 7 ) ), 7, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ), 4, '0' )

   ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + iif( Empty( ::Banco_Ag_Dv__ ), "", "-" + ::Banco_Ag_Dv__ ) + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   IF Len( ::NossoNumero__ ) < 8
      ::NossoNumero__ := ::Banco_Agencia + PADL( ALLTRIM( Left( ::NossoNumero__, 7 ) ), 7, '0' )
   ELSE
      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 11 ) ), 11, '0' )
   ENDIF
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .F. , ::Carteira_____ + ::NossoNumero__, .F. )

   ::NossoNumero_z := ::Carteira_____ + '/' + TRANS( ::NossoNumero__, "@R 9999/9999999" ) + "-" + ::NossoNumer_DV

   ::Campo_Livre__ := ::Banco_Agencia + SubStr( ::Carteira_____, 2, 2 ) + ::NossoNumero__ + ::Conta________ + "0"

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_341() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_341() Class MR_Boleto

   ::Banco_Dv_____ := "7"
   ::Banco_Nome___ := "Itaú"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 3 ) ), 3, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ),  4, '0' )

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 8 ) ), 8, '0' )
   ::NossoNumer_DV := ::DC_Mod10( ::Banco________, ::Banco_Agencia + ::Conta________ + ::Carteira_____ + ::NossoNumero__ )

   ::NossoNumero_z := ::Carteira_____ + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV

   ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ::Campo_Livre__:= ::Carteira_____ + ::NossoNumero__ + ::NossoNumer_DV  + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____ + "000"

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_399() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_399() Class MR_Boleto
   LOCAL cDataHSBC := StrZero( ::Vencimento___ - SToD( Str( Year( ::Vencimento___  ), 4 ) + "0101" ), 3 ) + Right( Str( Year( ::Vencimento___ ), 4 ), 1 )

   ::Banco_Dv_____ := "9"
   ::Banco_Nome___ := "HSBC"

   ::Carteira_____ := ALLTRIM( ::Carteira_____ )

   IF ::Carteira_____ == "00"

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
      ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
      ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ), 4, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .T. , ::NossoNumero__, .F. )
      ::NossoNumero_z := ::NossoNumero__ + "-" + ::NossoNumer_DV

      ::Campo_Livre__ := ::NossoNumero__ + ::NossoNumer_DV + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____ + "00" + "1"

      ::Ag_Cod_Cedent := TRAN( ::Banco_Agencia + IF( Empty( ::Banco_Ag_Dv__ ), "", "-" + ::Banco_Ag_Dv__ ) + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ELSE       // Sem Registro

      ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  7 ) ),  7, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 16 ) ), 16, '0' )
      ::NossoNumero_z := PADL( ALLTRIM( RIGHT( ::NossoNumero__, 14 ) ), 14, '0' )

      ::Campo_Livre__ := ::Prefixo______ + ::NossoNumero__ + cDataHSBC + "2"

      ::Ag_Cod_Cedent := PADL( ::Prefixo______, 12, '0' )

   ENDIF

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_422() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_422() Class MR_Boleto

   ::Banco_Dv_____   := "7"
   ::Banco_Nome___   := "Safra"

   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia,  4 ) ),  4, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________,  8 ) ),  8, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____,  1 ) ),  1, '0' )

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____,  2 ) ),  2, '0' )
   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  6 ) ),  6, '0' )

   ::Ag_Cod_Cedent := '0' + ::Banco_Agencia + '/' + ::Conta________ + '-' + ::Conta_DV_____

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 11 ) ), 11, '0' )
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .T. , ::NossoNumero__, .F. )

   IF ::Carteira_____ == '06'
      ::NossoNumero_z := ::Carteira_____ + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV
      ::Campo_Livre__:= '7' + ::Prefixo______ + ::NossoNumero__ + '4'
   ELSE
      ::NossoNumero_z := '0' + ::Banco_Agencia + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV
      ::Campo_Livre__ := '70' + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____  + ::NossoNumero__ + ::NossoNumer_DV + '1'
   ENDIF

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Banco_748() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Banco_748() Class MR_Boleto

   LOCAL cAux
   LOCAL cAno := RIGHT( hb_NtoS( YEAR(::Doc_Data_____ ) ), 2 )
   LOCAL cNNr := PADL( ALLTRIM( Left( ::NossoNumero__, 5 ) ), 5, '0' )

   ::Banco_Dv_____ := "X"
   ::Banco_Nome___ := "Banco Cooperativo Sicredi"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )
   ::Carteira_Tipo := PADL( ALLTRIM( Left( ::Carteira_Tipo, 1 ) ), 1, '0' )

   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ),  4, '0' )
   ::Banco_Ag_Un_A := PADL( ALLTRIM( Left( ::Banco_Ag_Un_A, 2 ) ),  2, '0' )

   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )

   ::NossoNumero__ := cAno + '3' + cNNr

   cAux := ::Banco_Agencia + ::Banco_Ag_Un_A + ::Conta________ + cAno + ::Carteira_Tipo + cNNr
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .T. , cAux, .F. )

   ::NossoNumero_z := cAno + '/' + ::Carteira_Tipo + cNNr + '-' + ::NossoNumer_DV

   ::Ag_Cod_Cedent := ::Banco_Agencia + '/' + ::Banco_Ag_Un_A + '/' + ::Conta________ + '-' + ::Conta_DV_____

   ::Campo_Livre__ := ::Carteira_Tipo + ::Conta________ + cAno + cNNr + ::NossoNumer_DV  + ::Banco_Agencia + ::Conta________ + "10"
   ::Campo_Livre__ += ::DC_Mod11( ::Banco________, 7, .T. , ::Campo_Livre__, .F. )

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Draw_Text( nLeft, nTop, cTxt, nSize ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Draw_Text( nLeft, nTop, cTxt, oFont, nSize ) Class MR_Boleto

   HPDF_Page_SetFontAndSize( ::oPage, oFont, nSize )

   /* text output */
   HPDF_Page_BeginText( ::oPage )
   HPDF_Page_TextOut( ::oPage, nLeft, ( ::Page_Height__ - nTop ), cTxt )
   HPDF_Page_EndText( ::oPage )

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Draw_Line( x, y, w, z, nPenSize ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Draw_Line( x, y, w, z, nPenSize ) Class MR_Boleto

   HPDF_Page_SetLineWidth( ::oPage, nPenSize )

   HPDF_Page_MoveTo( ::oPage, x, ( ::Page_Height__ - y ) )

   HPDF_Page_LineTo( ::oPage, w, ( ::Page_Height__ - z ) )

   HPDF_Page_Stroke( ::oPage )

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Draw_Image( nLeft, nTop, nWidth, nHeight ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Draw_Image( nLeft, nTop, nWidth, nHeight ) Class MR_Boleto
   Local cFile := 'resources\Logo_' + ::Banco________ + '.jpg'
   Local oImage

   IF hb_FileExists( cFile )

      oImage := HPDF_LoadJPEGImageFromFile( ::o_Pdf, cFile )
      HPDF_Page_DrawImage( ::oPage, oImage, nLeft, ( ::Page_Height__ - nTop ), nWidth, nHeight )

   ELSE

     ::Draw_Text( nLeft, nTop - ( ::Page_Height__ * 0.005 ), ::Banco_Nome___, ::oFont_v______, Font_Large____ )

   ENDIF

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Draw_Zebra( ... ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Draw_Zebra( ... ) Class MR_Boleto

   IF hb_zebra_GetError( ::hZebra_______ ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF

   hb_zebra_draw( ::hZebra_______, {| x, y, w, z | HPDF_Page_Rectangle( ::oPage, x, y, w, z ) }, ... )

   HPDF_Page_Fill( ::oPage )

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Finish() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Finish( lOpen ) Class MR_Boleto

   IF hb_FileExists( ::oFile )
      FERASE( ::oFile )
   ENDIF

   HPDF_SaveToFile( ::o_Pdf, ::oFile)

   hPDF_Free( ::o_Pdf )

   IF lOpen
      IF hb_FileExists( ::oFile )

#ifdef __GCC__
         hb_RUN( 'explorer.exe ' + ::oFile )
#else
         wapi_ShellExecute( 0, 'open', ::oFile, , , 3 ) // SW_SHOWMAXIMIZED  3
#endif

      ENDIF
   ENDIF

   Return NIL

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method DC_Mod10( c_Banco, mNMOG ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method DC_Mod10( c_Banco, mNMOG ) Class MR_Boleto
   LOCAL mVLDG
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mRSDV
   LOCAL mDCMD

   mSMMD := IIF( EMPTY( c_Banco ), 0, 0 )

   FOR mCTDG := 1 TO Len( mNMOG )
      mVLDG := Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * IF( Mod( mCTDG,2 ) == 0, 1, 2 )
      mSMMD += mVLDG - IF( mVLDG > 9, 9, 0 )
   NEXT
   mRSDV := Mod( mSMMD, 10 )
   mDCMD := IF( mRSDV == 0, "0", Str( 10 - mRSDV,1 ) )

   RETURN mDCMD

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 ) Class MR_Boleto
//
// bradesco -> DC_Mod11("237", 7, .F., carteira+agencia+nossonumero, .F.)
//
//*----------------------------------------------------------------------------*
Method DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 ) Class MR_Boleto
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mSQMP
   LOCAL mRSDV
   LOCAL mDCMD

   // mFGCB := IIF( EMPTY( mFGCB ), .F., mFGCB )
   // mFGCB := IIF( EMPTY( lMult10 ), .F., lMult10 )

   mSMMD := 0
   mSQMP := 2

   FOR mCTDG := 1 TO Len( mNMOG )
      mSMMD += Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * ( mSQMP )
      mSQMP := IF( mSQMP == mBSDG, 2, mSQMP + 1 )
   NEXT
   IF lMult10
      mSMMD *= 10
   ENDIF
   //  mRSDV := MOD(mSMMD,11)
   mRSDV := ( mSMMD % 11 )
   IF mFGCB
      mDCMD := IF( mRSDV > 9 .OR. mRSDV < 2, "1", Str( 11 - mRSDV,1 ) )
   ELSE
      IF c_Banco == "001"                 // Brasil
         mDCMD := IF( mRSDV == 0, "0", IF( mRSDV == 1,"X",Str(11 - mRSDV,1 ) ) )
      ELSEIF c_Banco $ "008|033|353" //Santander Banespa
         mDCMD := IF( mRSDV < 2, "0", IF( mRSDV == 10,"1",Str(11 - mRSDV,1 ) ) )
         //         mDCMD := IF(mRSDV == 0, "0", IF(mRSDV == 1, "X", STR(11 - mRSDV, 1)))
      ELSEIF c_Banco == "104"             // Caixa
         mRSDV := 11 - mRSDV
         mDCMD := IF( mRSDV > 9, "0", Str( mRSDV,1 ) )
      ELSEIF c_Banco == "237"             // Bradesco
         mDCMD := IF( mRSDV == 0, "0", IF( mRSDV == 1,"P",Str(11 - mRSDV,1 ) ) )
      ELSEIF c_Banco == "341"             // Itau
         mDCMD := IF( mRSDV == 11, "1", Str( 11 - mRSDV,1 ) )
      ELSEIF c_Banco == "409"             // Unibanco
         mDCMD := IF( mRSDV == 0 .OR. mRSDV == 10, "0", Str( mRSDV,1 ) )
      ELSEIF c_Banco == "422"             // Safra
         mDCMD := IF( mRSDV == 0, "1", IF( mRSDV == 1,"0",Str(11 - mRSDV,1 ) ) )
      ENDIF
   ENDIF

   RETURN mDCMD

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method DC_ModEsp( c_Banco, mNMOG ) Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method DC_ModEsp( c_Banco, mNMOG ) Class MR_Boleto

   LOCAL mVLDG
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mSQMP
   LOCAL mRSDV
   LOCAL mDCMD := 0

   IF c_Banco == "033"                  // Banespa
      mSMMD := 0
      mSQMP := 3
      FOR mCTDG := 1 TO Len( mNMOG )
         mVLDG := Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * ( mSQMP )
         mSMMD += mVLDG - ( Int( mVLDG / 10 ) * 10 )
         mSQMP := IF( mSQMP == 3, 7, IF( mSQMP == 7,9,IF(mSQMP == 9,1,3 ) ) )
      NEXT
      mRSDV := mSMMD - ( Int( mSMMD / 10 ) * 10 )
      mDCMD := IF( mRSDV == 0, 0, 10 - mRSDV )
   ENDIF

   RETURN Str( mDCMD, 1 )

//*----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Method Interleaved_2of5() Class MR_Boleto
//
//*----------------------------------------------------------------------------*
Method Interleaved_2of5() Class MR_Boleto
   Local n
   Local m
   Local cIz
   Local cDer
   Local nCheck := 0
   Local cBar   := []
   Local cBarra := []
   Local cCode  := Transform( ::Cod_Barras___, "@9")
   Local aBar   := {[00110], [10001], [01001], [11000], [00101], [10100], [01100], [00011], [10010], [01010]}
   Local lMode  := .F.

   If ( LEN( cCode ) % 2 == 1 .and. !( lMode ) )
      cCode+= [0]
   Endif

   If lMode
      For n:= 1 to len(cCode) step 2
          nCheck+= val(substr(cCode, n, 1)) * 3 + val(substr(cCode, n + 1, 1))
      Next
      cCode+= right(str(nCheck, 10, 0), 1)
   Endif

   cBarra:= [0000]
   For n:= 1 to len(cCode) Step 2
       cIz := aBar[val(substr(cCode, n, 1)) + 1]
       cDer:= aBar[val(substr(cCode, n + 1, 1)) + 1]
       For m:= 1 to 5
           cBarra+= substr(cIz, m, 1) + substr(cDer, m, 1)
       Next
   Next

   cBarra+= [100]
   For n:= 1 To Len(cBarra) Step 2
       If substr(cBarra, n, 1) == [1]
          cBar+= [111]
       Else
          cBar+= [1]
       Endif
       If substr(cBarra, n + 1, 1) == [1]
          cBar+= [000]
       Else
          cBar+= [0]
       Endif
   Next

Return( cBar )
