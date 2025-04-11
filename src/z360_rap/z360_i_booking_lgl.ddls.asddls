@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity z360_i_booking_lgl
  as projection on z360_r_booking_lgl
{
  key BookingUUID,
      TravelUUID,
      BookingID,
      BookingDate,
      CustomerID,
      AirlineID,
      ConnectionID,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */

      _BookingStatus,
      _BookingSupplement : redirected to composition child z360_i_bookingsuppl_lgl,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent z360_i_travel_lgl
}
