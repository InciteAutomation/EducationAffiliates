/*
    Object: Report Extension 50195 "EA Check Vendor No."
    Extends: Standard report "Check (Stub/Check/Stub)"

    PURPOSE
    -------
    This report extension enriches the standard Business Central check report
    with vendor, reference number, invoice number, and invoice date data that
    can be consumed by a custom RDLC layout.

    WHY THIS EXTENSION EXISTS
    -------------------------
    The standard check report provides payment detail rows, but it does not
    expose all of the custom reference-number mappings needed by this layout.

    This extension therefore:

      1. Determines the vendor associated with the current payment journal line.
      2. Finds all related payment journal lines that belong to the same:
           - Journal Template
           - Journal Batch
           - Journal Document No.
           - Vendor
      3. Uses each journal line's "Applies-to Doc. No." to locate the matching
         Vendor Ledger Entry.
      4. Stores up to 100 mappings of:
           - RefNbr
           - Invoice Nbr
           - Invoice Posting Date
      5. Publishes those mappings into the report dataset for the RDLC.

    IMPORTANT RDLC NOTE
    -------------------
    Adding 100 mappings to the AL dataset does not automatically make the RDLC
    use all 100 mappings.

    The RDLC must also:
      - define the additional fields,
      - serialize them into FooterInfo if page-footer logic depends on FooterInfo,
      - and update its custom code / matching expressions to read mappings 11-100.

    If the RDLC only reads mappings 1-10, entries 11-100 will exist in the dataset
    but will not appear in the rendered report.

    IMPORTANT STANDARD REPORT LIMITATION
    ------------------------------------
    The standard report's "One Check per Vendor per Document No." request-page
    option is not exposed as a protected variable to this report extension.

    Because of that, this extension always builds the complete candidate mapping
    for the vendor and journal document. The RDLC is responsible for displaying
    only the mappings that correspond to the current printed check detail rows.

    CAPACITY
    --------
    This version supports a maximum of 100 unique invoice / RefNbr mappings per
    vendor-document group.

    If more than 100 unique entries are found:
      - the first 100 are retained,
      - remaining entries are ignored,
      - and the report continues without throwing an array-overflow error.
*/
reportextension 50195 "EA Check Vendor No." extends "Check (Stub/Check/Stub)"
{
    dataset
    {
        /*
            Add custom columns to the standard GenJnlLine data item.

            The standard report already iterates the payment journal lines.
            We enrich each dataset record with both row-level values and the
            larger 1-100 mapping arrays used by the custom RDLC.
        */
        add(GenJnlLine)
        {
            /*
                Vendor number resolved from either:
                  - Account Type = Vendor
                  - or Bal. Account Type = Vendor

                This is displayed in the custom stub header.
            */
            column(EAVendorNo; EAVendorNo)
            {
                Caption = 'Vendor No.';
            }

            /*
                Direct, row-specific value from the current Gen. Journal Line.

                This can be useful for:
                  - debugging,
                  - direct body-row display,
                  - or validating which Applies-to Doc. No. Business Central
                    assigned to the current payment line.
            */
            column(EARowRefNbr; GenJnlLine."Applies-to Doc. No.")
            {
                Caption = 'Row RefNbr';
            }

            /*
                Compatibility fields.

                These expose the first collected mapping using the original field
                names already referenced by earlier RDLC expressions.

                They should not be assumed to represent every row when multiple
                invoices are combined into one check.
            */
            column(EAAppliesToDocNo; EARefNbr[1])
            {
                Caption = 'RefNbr';
            }

            column(EAExternalDocumentNo; EAInvoiceNbr[1])
            {
                Caption = 'Invoice Nbr';
            }

            column(EADueDate; EAInvoicePostingDate[1])
            {
                Caption = 'Invc. Date';
            }

            /*
                Number of unique mappings successfully added to the arrays.

                Useful for:
                  - troubleshooting,
                  - RDLC logic,
                  - and detecting whether the 100-entry limit was reached.
            */
            column(EASelectedEntryCount; EASelectedEntryCount)
            {
                Caption = 'Selected Entry Count';
            }

            /*
                RefNbr mappings 1-100.

                Each entry normally contains Vendor Ledger Entry."Document No.".
                If a matching Vendor Ledger Entry cannot be found, the extension
                still preserves the payment line's "Applies-to Doc. No." as the
                RefNbr-only fallback.
            */
            column(EAFooterAppliesToDocNo1; EARefNbr[1]) { }
            column(EAFooterAppliesToDocNo2; EARefNbr[2]) { }
            column(EAFooterAppliesToDocNo3; EARefNbr[3]) { }
            column(EAFooterAppliesToDocNo4; EARefNbr[4]) { }
            column(EAFooterAppliesToDocNo5; EARefNbr[5]) { }
            column(EAFooterAppliesToDocNo6; EARefNbr[6]) { }
            column(EAFooterAppliesToDocNo7; EARefNbr[7]) { }
            column(EAFooterAppliesToDocNo8; EARefNbr[8]) { }
            column(EAFooterAppliesToDocNo9; EARefNbr[9]) { }
            column(EAFooterAppliesToDocNo10; EARefNbr[10]) { }
            column(EAFooterAppliesToDocNo11; EARefNbr[11]) { }
            column(EAFooterAppliesToDocNo12; EARefNbr[12]) { }
            column(EAFooterAppliesToDocNo13; EARefNbr[13]) { }
            column(EAFooterAppliesToDocNo14; EARefNbr[14]) { }
            column(EAFooterAppliesToDocNo15; EARefNbr[15]) { }
            column(EAFooterAppliesToDocNo16; EARefNbr[16]) { }
            column(EAFooterAppliesToDocNo17; EARefNbr[17]) { }
            column(EAFooterAppliesToDocNo18; EARefNbr[18]) { }
            column(EAFooterAppliesToDocNo19; EARefNbr[19]) { }
            column(EAFooterAppliesToDocNo20; EARefNbr[20]) { }
            column(EAFooterAppliesToDocNo21; EARefNbr[21]) { }
            column(EAFooterAppliesToDocNo22; EARefNbr[22]) { }
            column(EAFooterAppliesToDocNo23; EARefNbr[23]) { }
            column(EAFooterAppliesToDocNo24; EARefNbr[24]) { }
            column(EAFooterAppliesToDocNo25; EARefNbr[25]) { }
            column(EAFooterAppliesToDocNo26; EARefNbr[26]) { }
            column(EAFooterAppliesToDocNo27; EARefNbr[27]) { }
            column(EAFooterAppliesToDocNo28; EARefNbr[28]) { }
            column(EAFooterAppliesToDocNo29; EARefNbr[29]) { }
            column(EAFooterAppliesToDocNo30; EARefNbr[30]) { }
            column(EAFooterAppliesToDocNo31; EARefNbr[31]) { }
            column(EAFooterAppliesToDocNo32; EARefNbr[32]) { }
            column(EAFooterAppliesToDocNo33; EARefNbr[33]) { }
            column(EAFooterAppliesToDocNo34; EARefNbr[34]) { }
            column(EAFooterAppliesToDocNo35; EARefNbr[35]) { }
            column(EAFooterAppliesToDocNo36; EARefNbr[36]) { }
            column(EAFooterAppliesToDocNo37; EARefNbr[37]) { }
            column(EAFooterAppliesToDocNo38; EARefNbr[38]) { }
            column(EAFooterAppliesToDocNo39; EARefNbr[39]) { }
            column(EAFooterAppliesToDocNo40; EARefNbr[40]) { }
            column(EAFooterAppliesToDocNo41; EARefNbr[41]) { }
            column(EAFooterAppliesToDocNo42; EARefNbr[42]) { }
            column(EAFooterAppliesToDocNo43; EARefNbr[43]) { }
            column(EAFooterAppliesToDocNo44; EARefNbr[44]) { }
            column(EAFooterAppliesToDocNo45; EARefNbr[45]) { }
            column(EAFooterAppliesToDocNo46; EARefNbr[46]) { }
            column(EAFooterAppliesToDocNo47; EARefNbr[47]) { }
            column(EAFooterAppliesToDocNo48; EARefNbr[48]) { }
            column(EAFooterAppliesToDocNo49; EARefNbr[49]) { }
            column(EAFooterAppliesToDocNo50; EARefNbr[50]) { }
            column(EAFooterAppliesToDocNo51; EARefNbr[51]) { }
            column(EAFooterAppliesToDocNo52; EARefNbr[52]) { }
            column(EAFooterAppliesToDocNo53; EARefNbr[53]) { }
            column(EAFooterAppliesToDocNo54; EARefNbr[54]) { }
            column(EAFooterAppliesToDocNo55; EARefNbr[55]) { }
            column(EAFooterAppliesToDocNo56; EARefNbr[56]) { }
            column(EAFooterAppliesToDocNo57; EARefNbr[57]) { }
            column(EAFooterAppliesToDocNo58; EARefNbr[58]) { }
            column(EAFooterAppliesToDocNo59; EARefNbr[59]) { }
            column(EAFooterAppliesToDocNo60; EARefNbr[60]) { }
            column(EAFooterAppliesToDocNo61; EARefNbr[61]) { }
            column(EAFooterAppliesToDocNo62; EARefNbr[62]) { }
            column(EAFooterAppliesToDocNo63; EARefNbr[63]) { }
            column(EAFooterAppliesToDocNo64; EARefNbr[64]) { }
            column(EAFooterAppliesToDocNo65; EARefNbr[65]) { }
            column(EAFooterAppliesToDocNo66; EARefNbr[66]) { }
            column(EAFooterAppliesToDocNo67; EARefNbr[67]) { }
            column(EAFooterAppliesToDocNo68; EARefNbr[68]) { }
            column(EAFooterAppliesToDocNo69; EARefNbr[69]) { }
            column(EAFooterAppliesToDocNo70; EARefNbr[70]) { }
            column(EAFooterAppliesToDocNo71; EARefNbr[71]) { }
            column(EAFooterAppliesToDocNo72; EARefNbr[72]) { }
            column(EAFooterAppliesToDocNo73; EARefNbr[73]) { }
            column(EAFooterAppliesToDocNo74; EARefNbr[74]) { }
            column(EAFooterAppliesToDocNo75; EARefNbr[75]) { }
            column(EAFooterAppliesToDocNo76; EARefNbr[76]) { }
            column(EAFooterAppliesToDocNo77; EARefNbr[77]) { }
            column(EAFooterAppliesToDocNo78; EARefNbr[78]) { }
            column(EAFooterAppliesToDocNo79; EARefNbr[79]) { }
            column(EAFooterAppliesToDocNo80; EARefNbr[80]) { }
            column(EAFooterAppliesToDocNo81; EARefNbr[81]) { }
            column(EAFooterAppliesToDocNo82; EARefNbr[82]) { }
            column(EAFooterAppliesToDocNo83; EARefNbr[83]) { }
            column(EAFooterAppliesToDocNo84; EARefNbr[84]) { }
            column(EAFooterAppliesToDocNo85; EARefNbr[85]) { }
            column(EAFooterAppliesToDocNo86; EARefNbr[86]) { }
            column(EAFooterAppliesToDocNo87; EARefNbr[87]) { }
            column(EAFooterAppliesToDocNo88; EARefNbr[88]) { }
            column(EAFooterAppliesToDocNo89; EARefNbr[89]) { }
            column(EAFooterAppliesToDocNo90; EARefNbr[90]) { }
            column(EAFooterAppliesToDocNo91; EARefNbr[91]) { }
            column(EAFooterAppliesToDocNo92; EARefNbr[92]) { }
            column(EAFooterAppliesToDocNo93; EARefNbr[93]) { }
            column(EAFooterAppliesToDocNo94; EARefNbr[94]) { }
            column(EAFooterAppliesToDocNo95; EARefNbr[95]) { }
            column(EAFooterAppliesToDocNo96; EARefNbr[96]) { }
            column(EAFooterAppliesToDocNo97; EARefNbr[97]) { }
            column(EAFooterAppliesToDocNo98; EARefNbr[98]) { }
            column(EAFooterAppliesToDocNo99; EARefNbr[99]) { }
            column(EAFooterAppliesToDocNo100; EARefNbr[100]) { }

            /*
                Invoice number mappings 1-100.

                Each entry contains Vendor Ledger Entry."External Document No.".

                These values are used by the RDLC to match a printed invoice row
                to the correct RefNbr mapping.
            */
            column(EAFooterExternalDocumentNo1; EAInvoiceNbr[1]) { }
            column(EAFooterExternalDocumentNo2; EAInvoiceNbr[2]) { }
            column(EAFooterExternalDocumentNo3; EAInvoiceNbr[3]) { }
            column(EAFooterExternalDocumentNo4; EAInvoiceNbr[4]) { }
            column(EAFooterExternalDocumentNo5; EAInvoiceNbr[5]) { }
            column(EAFooterExternalDocumentNo6; EAInvoiceNbr[6]) { }
            column(EAFooterExternalDocumentNo7; EAInvoiceNbr[7]) { }
            column(EAFooterExternalDocumentNo8; EAInvoiceNbr[8]) { }
            column(EAFooterExternalDocumentNo9; EAInvoiceNbr[9]) { }
            column(EAFooterExternalDocumentNo10; EAInvoiceNbr[10]) { }
            column(EAFooterExternalDocumentNo11; EAInvoiceNbr[11]) { }
            column(EAFooterExternalDocumentNo12; EAInvoiceNbr[12]) { }
            column(EAFooterExternalDocumentNo13; EAInvoiceNbr[13]) { }
            column(EAFooterExternalDocumentNo14; EAInvoiceNbr[14]) { }
            column(EAFooterExternalDocumentNo15; EAInvoiceNbr[15]) { }
            column(EAFooterExternalDocumentNo16; EAInvoiceNbr[16]) { }
            column(EAFooterExternalDocumentNo17; EAInvoiceNbr[17]) { }
            column(EAFooterExternalDocumentNo18; EAInvoiceNbr[18]) { }
            column(EAFooterExternalDocumentNo19; EAInvoiceNbr[19]) { }
            column(EAFooterExternalDocumentNo20; EAInvoiceNbr[20]) { }
            column(EAFooterExternalDocumentNo21; EAInvoiceNbr[21]) { }
            column(EAFooterExternalDocumentNo22; EAInvoiceNbr[22]) { }
            column(EAFooterExternalDocumentNo23; EAInvoiceNbr[23]) { }
            column(EAFooterExternalDocumentNo24; EAInvoiceNbr[24]) { }
            column(EAFooterExternalDocumentNo25; EAInvoiceNbr[25]) { }
            column(EAFooterExternalDocumentNo26; EAInvoiceNbr[26]) { }
            column(EAFooterExternalDocumentNo27; EAInvoiceNbr[27]) { }
            column(EAFooterExternalDocumentNo28; EAInvoiceNbr[28]) { }
            column(EAFooterExternalDocumentNo29; EAInvoiceNbr[29]) { }
            column(EAFooterExternalDocumentNo30; EAInvoiceNbr[30]) { }
            column(EAFooterExternalDocumentNo31; EAInvoiceNbr[31]) { }
            column(EAFooterExternalDocumentNo32; EAInvoiceNbr[32]) { }
            column(EAFooterExternalDocumentNo33; EAInvoiceNbr[33]) { }
            column(EAFooterExternalDocumentNo34; EAInvoiceNbr[34]) { }
            column(EAFooterExternalDocumentNo35; EAInvoiceNbr[35]) { }
            column(EAFooterExternalDocumentNo36; EAInvoiceNbr[36]) { }
            column(EAFooterExternalDocumentNo37; EAInvoiceNbr[37]) { }
            column(EAFooterExternalDocumentNo38; EAInvoiceNbr[38]) { }
            column(EAFooterExternalDocumentNo39; EAInvoiceNbr[39]) { }
            column(EAFooterExternalDocumentNo40; EAInvoiceNbr[40]) { }
            column(EAFooterExternalDocumentNo41; EAInvoiceNbr[41]) { }
            column(EAFooterExternalDocumentNo42; EAInvoiceNbr[42]) { }
            column(EAFooterExternalDocumentNo43; EAInvoiceNbr[43]) { }
            column(EAFooterExternalDocumentNo44; EAInvoiceNbr[44]) { }
            column(EAFooterExternalDocumentNo45; EAInvoiceNbr[45]) { }
            column(EAFooterExternalDocumentNo46; EAInvoiceNbr[46]) { }
            column(EAFooterExternalDocumentNo47; EAInvoiceNbr[47]) { }
            column(EAFooterExternalDocumentNo48; EAInvoiceNbr[48]) { }
            column(EAFooterExternalDocumentNo49; EAInvoiceNbr[49]) { }
            column(EAFooterExternalDocumentNo50; EAInvoiceNbr[50]) { }
            column(EAFooterExternalDocumentNo51; EAInvoiceNbr[51]) { }
            column(EAFooterExternalDocumentNo52; EAInvoiceNbr[52]) { }
            column(EAFooterExternalDocumentNo53; EAInvoiceNbr[53]) { }
            column(EAFooterExternalDocumentNo54; EAInvoiceNbr[54]) { }
            column(EAFooterExternalDocumentNo55; EAInvoiceNbr[55]) { }
            column(EAFooterExternalDocumentNo56; EAInvoiceNbr[56]) { }
            column(EAFooterExternalDocumentNo57; EAInvoiceNbr[57]) { }
            column(EAFooterExternalDocumentNo58; EAInvoiceNbr[58]) { }
            column(EAFooterExternalDocumentNo59; EAInvoiceNbr[59]) { }
            column(EAFooterExternalDocumentNo60; EAInvoiceNbr[60]) { }
            column(EAFooterExternalDocumentNo61; EAInvoiceNbr[61]) { }
            column(EAFooterExternalDocumentNo62; EAInvoiceNbr[62]) { }
            column(EAFooterExternalDocumentNo63; EAInvoiceNbr[63]) { }
            column(EAFooterExternalDocumentNo64; EAInvoiceNbr[64]) { }
            column(EAFooterExternalDocumentNo65; EAInvoiceNbr[65]) { }
            column(EAFooterExternalDocumentNo66; EAInvoiceNbr[66]) { }
            column(EAFooterExternalDocumentNo67; EAInvoiceNbr[67]) { }
            column(EAFooterExternalDocumentNo68; EAInvoiceNbr[68]) { }
            column(EAFooterExternalDocumentNo69; EAInvoiceNbr[69]) { }
            column(EAFooterExternalDocumentNo70; EAInvoiceNbr[70]) { }
            column(EAFooterExternalDocumentNo71; EAInvoiceNbr[71]) { }
            column(EAFooterExternalDocumentNo72; EAInvoiceNbr[72]) { }
            column(EAFooterExternalDocumentNo73; EAInvoiceNbr[73]) { }
            column(EAFooterExternalDocumentNo74; EAInvoiceNbr[74]) { }
            column(EAFooterExternalDocumentNo75; EAInvoiceNbr[75]) { }
            column(EAFooterExternalDocumentNo76; EAInvoiceNbr[76]) { }
            column(EAFooterExternalDocumentNo77; EAInvoiceNbr[77]) { }
            column(EAFooterExternalDocumentNo78; EAInvoiceNbr[78]) { }
            column(EAFooterExternalDocumentNo79; EAInvoiceNbr[79]) { }
            column(EAFooterExternalDocumentNo80; EAInvoiceNbr[80]) { }
            column(EAFooterExternalDocumentNo81; EAInvoiceNbr[81]) { }
            column(EAFooterExternalDocumentNo82; EAInvoiceNbr[82]) { }
            column(EAFooterExternalDocumentNo83; EAInvoiceNbr[83]) { }
            column(EAFooterExternalDocumentNo84; EAInvoiceNbr[84]) { }
            column(EAFooterExternalDocumentNo85; EAInvoiceNbr[85]) { }
            column(EAFooterExternalDocumentNo86; EAInvoiceNbr[86]) { }
            column(EAFooterExternalDocumentNo87; EAInvoiceNbr[87]) { }
            column(EAFooterExternalDocumentNo88; EAInvoiceNbr[88]) { }
            column(EAFooterExternalDocumentNo89; EAInvoiceNbr[89]) { }
            column(EAFooterExternalDocumentNo90; EAInvoiceNbr[90]) { }
            column(EAFooterExternalDocumentNo91; EAInvoiceNbr[91]) { }
            column(EAFooterExternalDocumentNo92; EAInvoiceNbr[92]) { }
            column(EAFooterExternalDocumentNo93; EAInvoiceNbr[93]) { }
            column(EAFooterExternalDocumentNo94; EAInvoiceNbr[94]) { }
            column(EAFooterExternalDocumentNo95; EAInvoiceNbr[95]) { }
            column(EAFooterExternalDocumentNo96; EAInvoiceNbr[96]) { }
            column(EAFooterExternalDocumentNo97; EAInvoiceNbr[97]) { }
            column(EAFooterExternalDocumentNo98; EAInvoiceNbr[98]) { }
            column(EAFooterExternalDocumentNo99; EAInvoiceNbr[99]) { }
            column(EAFooterExternalDocumentNo100; EAInvoiceNbr[100]) { }

            /*
                Invoice date mappings 1-100.

                The current business requirement uses Vendor Ledger Entry.
                "Posting Date" as the invoice date displayed on the check stub.

                The dataset names intentionally remain "EAFooterDueDate..." for
                backward compatibility with the existing RDLC field names.
            */
            column(EAFooterDueDate1; EAInvoicePostingDate[1]) { }
            column(EAFooterDueDate2; EAInvoicePostingDate[2]) { }
            column(EAFooterDueDate3; EAInvoicePostingDate[3]) { }
            column(EAFooterDueDate4; EAInvoicePostingDate[4]) { }
            column(EAFooterDueDate5; EAInvoicePostingDate[5]) { }
            column(EAFooterDueDate6; EAInvoicePostingDate[6]) { }
            column(EAFooterDueDate7; EAInvoicePostingDate[7]) { }
            column(EAFooterDueDate8; EAInvoicePostingDate[8]) { }
            column(EAFooterDueDate9; EAInvoicePostingDate[9]) { }
            column(EAFooterDueDate10; EAInvoicePostingDate[10]) { }
            column(EAFooterDueDate11; EAInvoicePostingDate[11]) { }
            column(EAFooterDueDate12; EAInvoicePostingDate[12]) { }
            column(EAFooterDueDate13; EAInvoicePostingDate[13]) { }
            column(EAFooterDueDate14; EAInvoicePostingDate[14]) { }
            column(EAFooterDueDate15; EAInvoicePostingDate[15]) { }
            column(EAFooterDueDate16; EAInvoicePostingDate[16]) { }
            column(EAFooterDueDate17; EAInvoicePostingDate[17]) { }
            column(EAFooterDueDate18; EAInvoicePostingDate[18]) { }
            column(EAFooterDueDate19; EAInvoicePostingDate[19]) { }
            column(EAFooterDueDate20; EAInvoicePostingDate[20]) { }
            column(EAFooterDueDate21; EAInvoicePostingDate[21]) { }
            column(EAFooterDueDate22; EAInvoicePostingDate[22]) { }
            column(EAFooterDueDate23; EAInvoicePostingDate[23]) { }
            column(EAFooterDueDate24; EAInvoicePostingDate[24]) { }
            column(EAFooterDueDate25; EAInvoicePostingDate[25]) { }
            column(EAFooterDueDate26; EAInvoicePostingDate[26]) { }
            column(EAFooterDueDate27; EAInvoicePostingDate[27]) { }
            column(EAFooterDueDate28; EAInvoicePostingDate[28]) { }
            column(EAFooterDueDate29; EAInvoicePostingDate[29]) { }
            column(EAFooterDueDate30; EAInvoicePostingDate[30]) { }
            column(EAFooterDueDate31; EAInvoicePostingDate[31]) { }
            column(EAFooterDueDate32; EAInvoicePostingDate[32]) { }
            column(EAFooterDueDate33; EAInvoicePostingDate[33]) { }
            column(EAFooterDueDate34; EAInvoicePostingDate[34]) { }
            column(EAFooterDueDate35; EAInvoicePostingDate[35]) { }
            column(EAFooterDueDate36; EAInvoicePostingDate[36]) { }
            column(EAFooterDueDate37; EAInvoicePostingDate[37]) { }
            column(EAFooterDueDate38; EAInvoicePostingDate[38]) { }
            column(EAFooterDueDate39; EAInvoicePostingDate[39]) { }
            column(EAFooterDueDate40; EAInvoicePostingDate[40]) { }
            column(EAFooterDueDate41; EAInvoicePostingDate[41]) { }
            column(EAFooterDueDate42; EAInvoicePostingDate[42]) { }
            column(EAFooterDueDate43; EAInvoicePostingDate[43]) { }
            column(EAFooterDueDate44; EAInvoicePostingDate[44]) { }
            column(EAFooterDueDate45; EAInvoicePostingDate[45]) { }
            column(EAFooterDueDate46; EAInvoicePostingDate[46]) { }
            column(EAFooterDueDate47; EAInvoicePostingDate[47]) { }
            column(EAFooterDueDate48; EAInvoicePostingDate[48]) { }
            column(EAFooterDueDate49; EAInvoicePostingDate[49]) { }
            column(EAFooterDueDate50; EAInvoicePostingDate[50]) { }
            column(EAFooterDueDate51; EAInvoicePostingDate[51]) { }
            column(EAFooterDueDate52; EAInvoicePostingDate[52]) { }
            column(EAFooterDueDate53; EAInvoicePostingDate[53]) { }
            column(EAFooterDueDate54; EAInvoicePostingDate[54]) { }
            column(EAFooterDueDate55; EAInvoicePostingDate[55]) { }
            column(EAFooterDueDate56; EAInvoicePostingDate[56]) { }
            column(EAFooterDueDate57; EAInvoicePostingDate[57]) { }
            column(EAFooterDueDate58; EAInvoicePostingDate[58]) { }
            column(EAFooterDueDate59; EAInvoicePostingDate[59]) { }
            column(EAFooterDueDate60; EAInvoicePostingDate[60]) { }
            column(EAFooterDueDate61; EAInvoicePostingDate[61]) { }
            column(EAFooterDueDate62; EAInvoicePostingDate[62]) { }
            column(EAFooterDueDate63; EAInvoicePostingDate[63]) { }
            column(EAFooterDueDate64; EAInvoicePostingDate[64]) { }
            column(EAFooterDueDate65; EAInvoicePostingDate[65]) { }
            column(EAFooterDueDate66; EAInvoicePostingDate[66]) { }
            column(EAFooterDueDate67; EAInvoicePostingDate[67]) { }
            column(EAFooterDueDate68; EAInvoicePostingDate[68]) { }
            column(EAFooterDueDate69; EAInvoicePostingDate[69]) { }
            column(EAFooterDueDate70; EAInvoicePostingDate[70]) { }
            column(EAFooterDueDate71; EAInvoicePostingDate[71]) { }
            column(EAFooterDueDate72; EAInvoicePostingDate[72]) { }
            column(EAFooterDueDate73; EAInvoicePostingDate[73]) { }
            column(EAFooterDueDate74; EAInvoicePostingDate[74]) { }
            column(EAFooterDueDate75; EAInvoicePostingDate[75]) { }
            column(EAFooterDueDate76; EAInvoicePostingDate[76]) { }
            column(EAFooterDueDate77; EAInvoicePostingDate[77]) { }
            column(EAFooterDueDate78; EAInvoicePostingDate[78]) { }
            column(EAFooterDueDate79; EAInvoicePostingDate[79]) { }
            column(EAFooterDueDate80; EAInvoicePostingDate[80]) { }
            column(EAFooterDueDate81; EAInvoicePostingDate[81]) { }
            column(EAFooterDueDate82; EAInvoicePostingDate[82]) { }
            column(EAFooterDueDate83; EAInvoicePostingDate[83]) { }
            column(EAFooterDueDate84; EAInvoicePostingDate[84]) { }
            column(EAFooterDueDate85; EAInvoicePostingDate[85]) { }
            column(EAFooterDueDate86; EAInvoicePostingDate[86]) { }
            column(EAFooterDueDate87; EAInvoicePostingDate[87]) { }
            column(EAFooterDueDate88; EAInvoicePostingDate[88]) { }
            column(EAFooterDueDate89; EAInvoicePostingDate[89]) { }
            column(EAFooterDueDate90; EAInvoicePostingDate[90]) { }
            column(EAFooterDueDate91; EAInvoicePostingDate[91]) { }
            column(EAFooterDueDate92; EAInvoicePostingDate[92]) { }
            column(EAFooterDueDate93; EAInvoicePostingDate[93]) { }
            column(EAFooterDueDate94; EAInvoicePostingDate[94]) { }
            column(EAFooterDueDate95; EAInvoicePostingDate[95]) { }
            column(EAFooterDueDate96; EAInvoicePostingDate[96]) { }
            column(EAFooterDueDate97; EAInvoicePostingDate[97]) { }
            column(EAFooterDueDate98; EAInvoicePostingDate[98]) { }
            column(EAFooterDueDate99; EAInvoicePostingDate[99]) { }
            column(EAFooterDueDate100; EAInvoicePostingDate[100]) { }
        }

        /*
            Extend the standard GenJnlLine record trigger.

            For every row generated by the base report:
              1. Clear stale values from the previous record.
              2. Resolve the vendor.
              3. Build the invoice / RefNbr mapping arrays.
        */
        modify(GenJnlLine)
        {
            trigger OnAfterAfterGetRecord()
            begin
                ClearExtensionValues();
                ResolveVendorNo(GenJnlLine);
                PopulatePaymentJournalApplications(GenJnlLine);
            end;
        }
    }

    rendering
    {
        layout(EACheckVendorNo)
        {
            Type = RDLC;
            LayoutFile = './layouts/EA-Check-Stub-Check-Stub.rdlc';
            Caption = 'EA Check Vendor Number';
            Summary = 'Custom check layout supporting up to 100 RefNbr mappings.';
        }
    }

    var
        /*
            Vendor associated with the current payment journal line.
        */
        EAVendorNo: Code[20];

        /*
            Parallel arrays.

            The same index always represents one logical invoice mapping:

              EARefNbr[25]
              EAInvoiceNbr[25]
              EAInvoicePostingDate[25]
              EAVendorLedgerEntryNo[25]

            all describe the same Vendor Ledger Entry / payment application.

            Keeping the arrays parallel is critical. Do not insert into one array
            without inserting into all relevant arrays at the same index.
        */
        EARefNbr: array[100] of Code[20];
        EAInvoiceNbr: array[100] of Code[35];
        EAInvoicePostingDate: array[100] of Date;

        /*
            Internal deduplication helper.

            The Vendor Ledger Entry Entry No. is stored so the same invoice is
            not added more than once when related journal lines overlap.
        */
        EAVendorLedgerEntryNo: array[100] of Integer;

        /*
            Number of populated array slots.

            Valid populated indexes are always:
              1 .. EASelectedEntryCount
        */
        EASelectedEntryCount: Integer;

    /*
        Clears all extension values before the base report advances to the next
        Gen. Journal Line record.

        This prevents mappings from the previous printed check from leaking into
        the current check.
    */
    local procedure ClearExtensionValues()
    var
        RowNo: Integer;
    begin
        Clear(EAVendorNo);
        Clear(EASelectedEntryCount);

        for RowNo := 1 to ArrayLen(EARefNbr) do begin
            Clear(EARefNbr[RowNo]);
            Clear(EAInvoiceNbr[RowNo]);
            Clear(EAInvoicePostingDate[RowNo]);
            Clear(EAVendorLedgerEntryNo[RowNo]);
        end;
    end;

    /*
        Resolves the vendor number from the current payment journal line.

        A payment journal may place the vendor on either side of the entry:

          A. Main account side
             Account Type = Vendor
             Account No.   = Vendor No.

          B. Balancing account side
             Bal. Account Type = Vendor
             Bal. Account No.   = Vendor No.

        The main account side is checked first. If found, the procedure exits
        immediately to avoid accidentally overwriting the result.
    */
    local procedure ResolveVendorNo(
        GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
    begin
        /*
            Vendor on the main account side.
        */
        if GenJournalLine."Account Type" =
           GenJournalLine."Account Type"::Vendor
        then
            if Vendor.Get(GenJournalLine."Account No.") then begin
                EAVendorNo := Vendor."No.";
                exit;
            end;

        /*
            Vendor on the balancing-account side.
        */
        if GenJournalLine."Bal. Account Type" =
           GenJournalLine."Bal. Account Type"::Vendor
        then
            if Vendor.Get(GenJournalLine."Bal. Account No.") then
                EAVendorNo := Vendor."No.";
    end;

    /*
        Builds the candidate application mapping for the current vendor and
        journal document.

        FILTER STRATEGY
        ---------------
        Related payment journal lines are located using:

          - Journal Template Name
          - Journal Batch Name
          - Document No.
          - Account Type = Vendor
          - Account No. = resolved vendor
          - Applies-to Doc. No. is not blank

        WHY DOCUMENT NO. IS USED
        ------------------------
        When Business Central combines several invoices into one vendor check,
        the payment journal lines normally share the same journal Document No.
        while each line has its own Applies-to Doc. No.

        STANDARD REPORT OPTION LIMITATION
        ---------------------------------
        Because the base report does not expose the request-page Boolean for
        "One Check per Vendor per Document No.", this procedure cannot switch
        between "single current line" and "all related lines" in AL.

        Therefore:
          - AL collects the complete candidate set.
          - RDLC decides which mapping belongs to the currently printed row.

        FALLBACK
        --------
        If no related journal-line set is found, the current line's
        Applies-to Doc. No. is processed directly.
    */
    local procedure PopulatePaymentJournalApplications(
        GenJournalLine: Record "Gen. Journal Line")
    var
        RelatedGenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        /*
            Without a vendor, no vendor-ledger lookup can be performed.
        */
        if EAVendorNo = '' then
            exit;

        RelatedGenJournalLine.Reset();

        /*
            Restrict the search to the same payment journal template.
        */
        RelatedGenJournalLine.SetRange(
            "Journal Template Name",
            GenJournalLine."Journal Template Name");

        /*
            Restrict the search to the same payment journal batch.
        */
        RelatedGenJournalLine.SetRange(
            "Journal Batch Name",
            GenJournalLine."Journal Batch Name");

        /*
            Restrict the search to the same journal document number.

            This is what groups the payment lines that may belong to one
            combined vendor check.
        */
        RelatedGenJournalLine.SetRange(
            "Document No.",
            GenJournalLine."Document No.");

        /*
            Only vendor-account lines are relevant to this extension.
        */
        RelatedGenJournalLine.SetRange(
            "Account Type",
            RelatedGenJournalLine."Account Type"::Vendor);

        /*
            Restrict the search to the resolved vendor.
        */
        RelatedGenJournalLine.SetRange(
            "Account No.",
            EAVendorNo);

        /*
            Ignore unapplied journal lines.

            A blank Applies-to Doc. No. cannot be matched to a Vendor Ledger
            Entry invoice document.
        */
        RelatedGenJournalLine.SetFilter(
            "Applies-to Doc. No.",
            '<>%1',
            '');

        /*
            Preserve journal line order so the mappings are deterministic and
            align as closely as possible with the base report's printed order.
        */
        RelatedGenJournalLine.SetCurrentKey(
            "Journal Template Name",
            "Journal Batch Name",
            "Line No.");

        /*
            If no related set exists, process the current journal line directly.
        */
        if not RelatedGenJournalLine.FindSet() then begin
            AddApplicationFromDocumentNo(
                EAVendorNo,
                GenJournalLine."Applies-to Doc. No.");

            exit;
        end;

        repeat
            /*
                Stop safely at the declared 100-entry capacity.

                This prevents runtime array-overflow errors.
            */
            if EASelectedEntryCount >= ArrayLen(EARefNbr) then
                exit;

            VendorLedgerEntry.Reset();

            /*
                Match only entries for the current vendor.
            */
            VendorLedgerEntry.SetRange(
                "Vendor No.",
                EAVendorNo);

            /*
                The custom layout expects invoice entries.
            */
            VendorLedgerEntry.SetRange(
                "Document Type",
                VendorLedgerEntry."Document Type"::Invoice);

            /*
                "Applies-to Doc. No." on the payment journal line should match
                Vendor Ledger Entry."Document No.".
            */
            VendorLedgerEntry.SetRange(
                "Document No.",
                RelatedGenJournalLine."Applies-to Doc. No.");

            /*
                If a full Vendor Ledger Entry exists, store all mapped values.

                If no matching ledger entry exists, retain the RefNbr only so
                the report still has the journal line's reference number rather
                than failing the extension lookup.
            */
            if VendorLedgerEntry.FindFirst() then
                AddVendorLedgerEntry(VendorLedgerEntry)
            else
                AddRefNbrOnly(
                    RelatedGenJournalLine."Applies-to Doc. No.");

        until RelatedGenJournalLine.Next() = 0;
    end;

    /*
        Processes one Applies-to Document No. directly.

        Used as a fallback when the related journal-line search does not return
        a set.

        The lookup criteria are:
          - Vendor No.
          - Document Type = Invoice
          - Document No. = Applies-to Doc. No.
    */
    local procedure AddApplicationFromDocumentNo(
        VendorNo: Code[20];
        AppliesToDocumentNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        /*
            Nothing can be matched when no Applies-to Document No. exists.
        */
        if AppliesToDocumentNo = '' then
            exit;

        VendorLedgerEntry.Reset();

        VendorLedgerEntry.SetRange(
            "Vendor No.",
            VendorNo);

        VendorLedgerEntry.SetRange(
            "Document Type",
            VendorLedgerEntry."Document Type"::Invoice);

        VendorLedgerEntry.SetRange(
            "Document No.",
            AppliesToDocumentNo);

        /*
            Prefer a full invoice mapping when possible.
        */
        if VendorLedgerEntry.FindFirst() then begin
            AddVendorLedgerEntry(VendorLedgerEntry);
            exit;
        end;

        /*
            Preserve the reference number even if no ledger entry is found.
        */
        AddRefNbrOnly(AppliesToDocumentNo);
    end;

    /*
        Adds one complete Vendor Ledger Entry mapping to the parallel arrays.

        DEDUPLICATION
        -------------
        Vendor Ledger Entry."Entry No." is used as the unique key.

        This is safer than deduplicating only by Document No. because separate
        ledger entries can theoretically share visible document values in some
        migrated or customized datasets.

        ARRAY INDEXING
        --------------
        EASelectedEntryCount is incremented first, then that index is populated
        across all arrays.
    */
    local procedure AddVendorLedgerEntry(
        VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        /*
            Do not write beyond the fixed 100-entry capacity.
        */
        if EASelectedEntryCount >= ArrayLen(EARefNbr) then
            exit;

        /*
            Do not add the same ledger entry twice.
        */
        if VendorLedgerEntryAlreadyAdded(
            VendorLedgerEntry."Entry No.")
        then
            exit;

        EASelectedEntryCount += 1;

        /*
            Store Entry No. for duplicate detection only.
        */
        EAVendorLedgerEntryNo[EASelectedEntryCount] :=
            VendorLedgerEntry."Entry No.";

        /*
            RefNbr shown by the custom report.

            Current business definition:
              RefNbr = Vendor Ledger Entry."Document No."
        */
        EARefNbr[EASelectedEntryCount] :=
            VendorLedgerEntry."Document No.";

        /*
            Invoice Nbr shown by the custom report.

            Current business definition:
              Invoice Nbr = Vendor Ledger Entry."External Document No."
        */
        EAInvoiceNbr[EASelectedEntryCount] :=
            VendorLedgerEntry."External Document No.";

        /*
            Invoice date shown by the custom report.

            Current business definition:
              Invc. Date = Vendor Ledger Entry."Posting Date"
        */
        EAInvoicePostingDate[EASelectedEntryCount] :=
            VendorLedgerEntry."Posting Date";
    end;

    /*
        Adds a RefNbr when no matching Vendor Ledger Entry could be found.

        In that scenario:
          - RefNbr is populated.
          - Invoice Nbr remains blank.
          - Invoice Posting Date remains blank.
          - Vendor Ledger Entry No. remains zero.

        This allows the RDLC to display the journal's reference number without
        causing the extension itself to fail.
    */
    local procedure AddRefNbrOnly(
        AppliesToDocumentNo: Code[20])
    begin
        if AppliesToDocumentNo = '' then
            exit;

        /*
            Avoid adding the same fallback reference number twice.
        */
        if RefNbrAlreadyAdded(AppliesToDocumentNo) then
            exit;

        /*
            Respect the fixed 100-entry capacity.
        */
        if EASelectedEntryCount >= ArrayLen(EARefNbr) then
            exit;

        EASelectedEntryCount += 1;
        EARefNbr[EASelectedEntryCount] := AppliesToDocumentNo;
    end;

    /*
        Returns true when the Vendor Ledger Entry Entry No. has already been
        added to the mapping arrays.
    */
    local procedure VendorLedgerEntryAlreadyAdded(
        VendorLedgerEntryNo: Integer): Boolean
    var
        RowNo: Integer;
    begin
        /*
            Entry No. 0 means no real Vendor Ledger Entry was stored.
        */
        if VendorLedgerEntryNo = 0 then
            exit(false);

        for RowNo := 1 to EASelectedEntryCount do
            if EAVendorLedgerEntryNo[RowNo] =
               VendorLedgerEntryNo
            then
                exit(true);

        exit(false);
    end;

    /*
        Returns true when a fallback RefNbr has already been added.

        This is mainly used for entries where no full Vendor Ledger Entry could
        be found and therefore no Entry No. exists for deduplication.
    */
    local procedure RefNbrAlreadyAdded(
        RefNbr: Code[20]): Boolean
    var
        RowNo: Integer;
    begin
        if RefNbr = '' then
            exit(false);

        for RowNo := 1 to EASelectedEntryCount do
            if EARefNbr[RowNo] = RefNbr then
                exit(true);

        exit(false);
    end;
}
