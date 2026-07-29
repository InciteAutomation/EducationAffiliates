pageextension 50102 "PI Card Extension" extends "Purchase Invoice"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field("Jaggaer IN NBR"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer IN NBR';
            }
            field("Jaggaer PO Number"; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                Caption = 'Jaggaer PO Number';
            }
        }

    }
    actions
    {
        addafter(Post)
        {
            action(PostWithoutVendorDimensions)
            {
                ApplicationArea = All;
                Caption = 'Post NEW';
                ToolTip = 'Posts the purchase invoice without enforcing Code Mandatory dimensions configured on the vendor.';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                    BypassPosting: Codeunit "Post Purch. Invoice No Dims";
                    InvoiceWasPosted: Boolean;
                begin
                    /*
                      Save any unsaved changes on the Purchase Invoice page
                      before retrieving and posting the header.
                    */
                    CurrPage.SaveRecord();

                    PurchaseHeader.Get(
                        Rec."Document Type",
                        Rec."No.");

                    InvoiceWasPosted :=
                        BypassPosting.PostInvoice(PurchaseHeader);

                    if InvoiceWasPosted then
                        CurrPage.Close()
                    else
                        CurrPage.Update(false);
                end;
            }
        }
    }
}

