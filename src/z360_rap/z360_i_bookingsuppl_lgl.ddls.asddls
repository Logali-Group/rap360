@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity z360_i_bookingsuppl_lgl
  as projection on z360_r_bookingsuppl_lgl
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      
      /* Associations */
      _Booking : redirected to parent z360_i_booking_lgl,
      _Product,
      _SupplementText,
      _Travel : redirected to z360_i_travel_lgl
}
