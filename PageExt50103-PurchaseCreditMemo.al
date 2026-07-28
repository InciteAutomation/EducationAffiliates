pageextension 50103 "PCM Card Extension" extends "Purchase Credit Memo"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
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
                Caption = 'Post Without Vendor Dimensions';
                ToolTip = 'Posts the purchase credit memo without enforcing Code Mandatory dimensions configured on the vendor.';
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
                      Save any unsaved changes on the Purchase Credit Memo page
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