// query 11147641 "IDYS SC Shipping Price"
// {
//     QueryType = Normal;
//     Caption = 'Shipping Price Overview';
//     OrderBy = ascending(Price);

//     elements
//     {

//         dataitem(IDYS_Provider_Carrier; "IDYS Provider Carrier")
//         {

//             dataitem("IDYS_Provider_Booking_Profile"; "IDYS Provider Booking Profile")
//             {
//                 DataItemLink = "Carrier Entry No." = IDYS_Provider_Carrier."Entry No.";
//                 SqlJoinType = InnerJoin;

//                 column(Entry_No_; "Entry No.")
//                 {
//                 }
//                 column(Carrier_Entry_No_; "Carrier Entry No.")
//                 {
//                 }
//                 column(Is_Return; "Is Return")
//                 {
//                 }
//                 column(Carrier_Name; "Carrier Name")
//                 {
//                 }
//                 column(Id; Id)
//                 {
//                 }
//                 column(Description; Description)
//                 {
//                 }
//                 column(Max__Weight; "Max. Weight")
//                 {
//                 }
//                 column(Min__Weight; "Min. Weight")
//                 {
//                 }
//                 dataitem(IDYS_SC_Shipping_Price; "IDYS SC Shipping Price")
//                 {
//                     DataItemLink = "Booking Profile Entry No." = IDYS_Provider_Booking_Profile."Entry No.", "Carrier Entry No." = IDYS_Provider_Booking_Profile."Carrier Entry No.";
//                     SqlJoinType = InnerJoin;
//                     column(Country__from_; "Country (from)")  //ISO 2
//                     {
//                     }
//                     column(Country__to_; "Country (to)")  //ISO 2
//                     {
//                     }
//                     column(Price; Price)
//                     {
//                     }
//                 }
//             }
//         }
//     }

//     procedure SetWeightFilters(_Weight: Decimal)
//     begin
//         SetFilter(Min__Weight, '<%1', _Weight);
//         SetFilter(Max__Weight, '>%1', _Weight);
//         Weight := _Weight;
//     end;

//     procedure GetWeight(): Decimal
//     begin
//         exit(Weight);
//     end;

//     var
//         Weight: Decimal;
// }