enum 11147647 "IDYS Source Document Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "0") { Caption = 'Quote'; }
    value(1; "1") { Caption = 'Order'; }
    value(2; "2") { Caption = 'Invoice'; }
    value(3; "3") { Caption = 'Credit Memo'; }
    value(4; "4") { Caption = 'Blanket Order'; }
    value(5; "5") { Caption = 'Return Order'; }

    #region [WhseShipLines]
    //table 7321 "Warehouse Shipment Line"."Source Subtype"
    value(6; "6") { Caption = ''; }
    value(7; "7") { Caption = ''; }
    value(8; "8") { Caption = ''; }
    value(9; "9") { Caption = ''; }
    value(10; "10") { Caption = ''; }
    #endregion

    #region [Unknown - to avoid breaking changes]
    value(11; "11") { Caption = ''; }
    value(12; "12") { Caption = ''; }
    value(13; "13") { Caption = ''; }
    value(14; "14") { Caption = ''; }
    #endregion
}