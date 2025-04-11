@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity z360_c_bookingsuppl_lgl
  as projection on z360_r_bookingsuppl_lgl
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      
      @Search.defaultSearchElement: true
      BookingSupplementID,
      
      @ObjectModel.text.element: [ 'SupplementDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Supplement_StdVH',
                                                     element: 'SupplementID' },
                                            additionalBinding: [{ localElement: 'Price',
                                                                 element: 'Price',
                                                                 usage: #FILTER_AND_RESULT },

                                                               { localElement: 'CurrencyCode',
                                                                 element: 'CurrencyCode',
                                                                 usage: #FILTER_AND_RESULT }],
                                           useForValidation: true }]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                           useForValidation: true }]
      CurrencyCode,
      
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent z360_c_booking_lgl,
      _Product,
      _SupplementText,
      _Travel : redirected to z360_c_travel_lgl
}
