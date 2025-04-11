@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity z360_c_travel_lgl
  provider contract transactional_query
  as projection on z360_r_travel_lgl
{
  key TravelUUID,

      @Search.defaultSearchElement: true
      TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                     element: 'AgencyID' },
                                           useForValidation: true }]
      AgencyID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8      
      _Agency.Name              as AgencyName,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID' },
                                           useForValidation: true }]
      CustomerID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8 
      _Customer.LastName        as CustomerName,

      BeginDate,
      EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                           useForValidation: true }]
      CurrencyCode,
      Description,

      @ObjectModel.text.element: [ 'OverallStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH',
                                                     element: 'OverallStatus' },
                                           useForValidation: true }]
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Agency,
      _Booking : redirected to composition child z360_c_booking_lgl,
      _Currency,
      _Customer,
      _OverallStatus
}
