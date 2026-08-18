codeunit 50203 "EA Positive Pay File Naming"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"File Management",
        'OnBeforeBlobExport',
        '',
        false,
        false)]
    local procedure FileManagementOnBeforeBlobExport(
        var TempBlob: Codeunit "Temp Blob";
        Name: Text;
        CommonDialog: Boolean;
        var IsHandled: Boolean;
        var Result: Text)
    var
        InStr: InStream;
        NewFileName: Text;
    begin
        // Only affect the PNC Positive Pay file.
        if not IsPNCPositivePayFile(Name) then
            exit;

        NewFileName := BuildPNCPositivePayFileName();

        TempBlob.CreateInStream(InStr);

        DownloadFromStream(
            InStr,
            '',
            '',
            '',
            NewFileName);

        Result := NewFileName;
        IsHandled := true;
    end;

    local procedure IsPNCPositivePayFile(FileName: Text): Boolean
    begin
        exit(
            StrPos(
                UpperCase(FileName),
                'PNC-PP'
            ) = 1
        );
    end;

    local procedure BuildPNCPositivePayFileName(): Text
    var
        ExportDateTime: DateTime;
        ExportDate: Date;
        ExportTime: Time;
        DatePart: Text;
        TimePart: Text;
    begin
        ExportDateTime := CurrentDateTime();

        ExportDate := DT2Date(ExportDateTime);
        ExportTime := DT2Time(ExportDateTime);

        DatePart :=
            Format(
                ExportDate,
                0,
                '<Year4><Month,2><Day,2>'
            );

        TimePart :=
            Format(
                ExportTime,
                0,
                '<Hours24,2><Minutes,2><Seconds,2>'
            );

        exit(
            'arp.educationaffiliates0738.in.' +
            DatePart +
            '.' +
            TimePart
        );
    end;
}