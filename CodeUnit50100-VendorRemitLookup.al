codeunit 50100 "Vendor Remit Lookup"
{
    procedure PopulateBuffer(var ResultBuffer: Record "Vendor Remit Result Buffer"; VendorNo: Code[20]; CompanyDimValue: Code[20])
    var
        DefaultDim: Record "Default Dimension";
        AllowedValue: Record "Dim. Value per Account";
        RemitAddr: Record "Remit Address";
    begin
        if (VendorNo = '') or (CompanyDimValue = '') then begin
            ResultBuffer."Debug Message" := 'FAILED: VendorNo or CompanyDimValue is empty';
            exit;
        end;

        DefaultDim.SetRange("Table ID", Database::Vendor);
        DefaultDim.SetRange("No.", VendorNo);
        DefaultDim.SetFilter("Dimension Code", '%1|%2|%3|%4|%5', 'REMIT1', 'REMIT2', 'REMIT3', 'REMIT4', 'REMIT5');

        if not DefaultDim.FindSet() then begin
            ResultBuffer."Vendor No." := VendorNo;
            ResultBuffer."Debug Message" := 'DEFAULT';
            exit;
        end;



        DefaultDim.FindSet();
        repeat
            AllowedValue.Reset();
            AllowedValue.SetRange("Table ID", Database::Vendor);
            AllowedValue.SetRange("No.", VendorNo);
            AllowedValue.SetRange("Dimension Code", DefaultDim."Dimension Code");
            AllowedValue.SetRange("Dimension Value Code", CompanyDimValue);
            AllowedValue.SetRange(Allowed, true);

            if AllowedValue.FindFirst() then begin
                RemitAddr.SetRange("Vendor No.", VendorNo);
                RemitAddr.SetRange(Code, DefaultDim."Dimension Code");
                if RemitAddr.FindFirst() then begin
                    ResultBuffer."Vendor No." := VendorNo;
                    ResultBuffer."Company Dim Value" := CompanyDimValue;
                    ResultBuffer."Remit Code" := RemitAddr.Code;
                    ResultBuffer.Name := RemitAddr.Name;
                    ResultBuffer.Address := RemitAddr.Address;
                    ResultBuffer."Address 2" := RemitAddr."Address 2";
                    ResultBuffer.City := RemitAddr.City;
                    ResultBuffer.State := RemitAddr.County;
                    ResultBuffer."Post Code" := RemitAddr."Post Code";
                    ResultBuffer."Country Code" := RemitAddr."Country/Region Code";
                    ResultBuffer."Debug Message" := 'SUCCESS';
                    exit;
                end
            end
        until DefaultDim.Next() = 0;

        ResultBuffer."Vendor No." := VendorNo;

    end;
}

