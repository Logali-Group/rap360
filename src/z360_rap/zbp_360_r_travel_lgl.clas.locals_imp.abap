class lhc_Travel definition inheriting from cl_abap_behavior_handler.
  private section.

    constants:
      begin of travel_status,
        open     type c length 1 value 'O', "Open
        accepted type c length 1 value 'A', "Accepted
        rejected type c length 1 value 'X', "Rejected
      end of travel_status.

    methods get_instance_features for instance features
      importing keys request requested_features for Travel result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Travel result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for Travel result result.

    methods precheck_create for precheck
      importing entities for create Travel.

    methods precheck_update for precheck
      importing entities for update Travel.

    methods acceptTravel for modify
      importing keys for action Travel~acceptTravel result result.

    methods rejectTravel for modify
      importing keys for action Travel~rejectTravel result result.

    methods deductDiscount for modify
      importing keys for action Travel~deductDiscount result result.

    methods reCalcTotalPrice for modify
      importing keys for action Travel~reCalcTotalPrice.

    methods Resume for modify
      importing keys for action Travel~Resume.

    methods calculateTotalPrice for determine on modify
      importing keys for Travel~calculateTotalPrice.

    methods setStatusToOpen for determine on modify
      importing keys for Travel~setStatusToOpen.

    methods setTravelNumber for determine on save
      importing keys for Travel~setTravelNumber.

    methods validateAgency for validate on save
      importing keys for Travel~validateAgency.

    methods validateBookingFee for validate on save
      importing keys for Travel~validateBookingFee.

    methods validateCustomer for validate on save
      importing keys for Travel~validateCustomer.

    methods validateDates for validate on save
      importing keys for Travel~validateDates.

endclass.

class lhc_Travel implementation.

  method get_instance_features.

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         fields ( OverallStatus )
         with corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
                                              %field-BookingFee = cond #( when travel-OverallStatus = travel_status-accepted
                                                                          then if_abap_behv=>fc-f-read_only
                                                                          else if_abap_behv=>fc-f-unrestricted )
                                              %action-acceptTravel =  cond #( when travel-OverallStatus = travel_status-accepted
                                                                              then if_abap_behv=>fc-o-disabled
                                                                              else if_abap_behv=>fc-o-enabled )
                                              %action-rejectTravel =  cond #( when travel-OverallStatus = travel_status-rejected
                                                                              then if_abap_behv=>fc-o-disabled
                                                                              else if_abap_behv=>fc-o-enabled )
                                              %action-deductDiscount =  cond #( when travel-OverallStatus = travel_status-accepted
                                                                              then if_abap_behv=>fc-o-disabled
                                                                              else if_abap_behv=>fc-o-enabled )
                                              %assoc-_Booking   =  cond #( when travel-OverallStatus = travel_status-rejected
                                                                              then if_abap_behv=>fc-o-disabled
                                                                              else if_abap_behv=>fc-o-enabled ) ) ).
  endmethod.

  method get_instance_authorizations.

    data: update_requested type abap_bool,
          update_granted   type abap_bool,
          delete_requested type abap_bool,
          delete_granted   type abap_bool.

    read entities of z360_r_travel_lgl in local mode
          entity Travel
          fields ( AgencyID )
          with corresponding #( keys )
          result data(travels).

    update_requested = cond #( when requested_authorizations-%update      = if_abap_behv=>mk-on
                                 or requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                               then abap_true
                               else abap_false ).

    delete_requested = cond #( when requested_authorizations-%delete      = if_abap_behv=>mk-on
                               then abap_true
                               else abap_false ).

    data(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).

    loop at travels into data(travel). "70012

      if travel-AgencyID is not initial.

        if update_requested eq abap_true.

          if lv_technical_name eq 'CB9980000785' and travel-AgencyID ne '70012'.
            update_granted = abap_true.
          else.

            update_granted = abap_false.

            append value #( %msg = new /dmo/cm_flight_messages( textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                                agency_id = travel-AgencyID
                                                                severity  = if_abap_behv_message=>severity-error )
                           %global = if_abap_behv=>mk-on ) to reported-travel.

          endif.

        endif.

      endif.

      if delete_requested eq abap_true.

        if lv_technical_name eq 'CB9980000785' and travel-AgencyID ne '70012'.
          delete_granted = abap_true.
        else.

          delete_granted = abap_false.

          append value #( %msg = new /dmo/cm_flight_messages( textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                              agency_id = travel-AgencyID
                                                              severity  = if_abap_behv_message=>severity-error )
                      %global = if_abap_behv=>mk-on ) to reported-travel.

        endif.
      endif.


      append value #( let upd_auth = cond #( when update_granted eq abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                          del_auth = cond #( when delete_granted eq abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                      in
                      %tky       = travel-%tky
                      %update      = upd_auth
                      %action-Edit = upd_auth
                      %delete      = del_auth ) to result.

    endloop.

  endmethod.

  method get_global_authorizations.

    data(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).

    "lv_technical_name = 'DIFFERENT'.

    if requested_authorizations-%create eq if_abap_behv=>mk-on.

      if lv_technical_name eq 'CB9980000785'. "REPLACE ME WITH THE BUSINESS LOGIC TO DETERMINE IF THE USER HAVE ACCESS
        result-%create = if_abap_behv=>auth-allowed.
      else.
        result-%create = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) to reported-travel.

      endif.

    endif.

    if requested_authorizations-%update      eq if_abap_behv=>mk-on or
       requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.

      if lv_technical_name eq 'CB9980000785'. "REPLACE ME WITH THE BUSINESS LOGIC TO DETERMINE IF THE USER HAVE ACCESS
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      else.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) to reported-travel.

      endif.

    endif.

    if requested_authorizations-%delete eq if_abap_behv=>mk-on.

      if lv_technical_name eq 'CB9980000785'. "REPLACE ME WITH THE BUSINESS LOGIC TO DETERMINE IF THE USER HAVE ACCESS
        result-%delete = if_abap_behv=>auth-allowed.
      else.
        result-%delete = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) to reported-travel.

      endif.

    endif.


  endmethod.

  method precheck_create.
  endmethod.

  method precheck_update.
  endmethod.

  method acceptTravel.

    modify entities of z360_r_travel_lgl in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky = key-%tky
                                           OverallStatus = travel_status-accepted ) ).

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         all fields
         with corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  endmethod.

  method deductDiscount.
  endmethod.

  method reCalcTotalPrice.
  endmethod.

  method rejectTravel.

    modify entities of z360_r_travel_lgl in local mode
             entity Travel
             update fields ( OverallStatus )
             with value #( for key in keys ( %tky = key-%tky
                                             OverallStatus = travel_status-rejected ) ).

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         all fields
         with corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  endmethod.

  method Resume.
  endmethod.

  method calculateTotalPrice.
  endmethod.

  method setStatusToOpen.

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         fields ( OverallStatus )
         with corresponding #( keys )
         result data(travels).

    delete travels where OverallStatus is not initial.

    check travels is not initial.

    modify entities of z360_r_travel_lgl in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for travel in travels index into i ( %tky        = travel-%tky
                                                             OverallStatus = travel_status-open ) ).

  endmethod.

  method setTravelNumber.

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         fields ( TravelID )
         with corresponding #( keys )
         result data(travels).

    delete travels where TravelID is not initial.

    check travels is not initial.

    select single from z360_travel_a
           fields max( travel_id )
           into @data(max_TravelId).

    "same request first item with TravelID
    "same request second item with TravelID
    "same request third item with TravelID

    " first  10171 + 1 = 10172
    " second 10171 + 2 = 10173
    " third  10171 + 3 = 10174

    modify entities of z360_r_travel_lgl in local mode
           entity Travel
           update fields ( TravelID )
           with value #( for travel in travels index into i ( %tky     = travel-%tky
                                                              TravelID = max_TravelId + i ) ).

  endmethod.

  method validateAgency.

    data agencies type sorted table of /dmo/agency with unique key client agency_id.

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         fields ( AgencyID )
         with corresponding #( keys )
         result data(travels).

    agencies = corresponding #( travels discarding duplicates mapping  agency_id = AgencyID except * ).
    delete agencies where agency_id is initial.

    if agencies is not initial.

      select from /dmo/agency as db
             inner join @agencies as it on db~agency_id = it~agency_id
             fields db~agency_id
             into table @data(valid_agencies).

    endif.

    loop at travels into data(travel).

      append value #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_AGENCY' ) to reported-Travel.

      if travel-AgencyID is initial.

        append value #( %tky = travel-%tky ) to failed-Travel.

        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY'
                        %msg        = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_agency_id
                                                                   severity = if_abap_behv_message=>severity-error )
                        %element-AgencyID = if_abap_behv=>mk-on ) to reported-Travel.

      elseif not line_exists( valid_agencies[ agency_id = travel-AgencyID ] ).

        append value #( %tky = travel-%tky ) to failed-Travel.

        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY'
                        %msg        = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>agency_unkown
                                                                   severity = if_abap_behv_message=>severity-error
                                                                   agency_id = travel-AgencyID )
                        %element-AgencyID = if_abap_behv=>mk-on ) to reported-Travel.

      endif.

    endloop.

  endmethod.

  method validateBookingFee.
  endmethod.

  method validateCustomer.

    data customers type sorted table of /dmo/customer with unique key client customer_id.

    read entities of z360_r_travel_lgl in local mode
         entity Travel
         fields ( CustomerID )
         with corresponding #( keys )
         result data(travels).

    customers = corresponding #( travels discarding duplicates mapping  customer_id = CustomerID except * ).
    delete customers where customer_id is initial.

    if customers is not initial.

      select from /dmo/customer as db
             inner join @customers as it on db~customer_id = it~customer_id
             fields db~customer_id
             into table @data(valid_customers).

    endif.

    loop at travels into data(travel).

      append value #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) to reported-Travel.

      if travel-CustomerID is initial.

        append value #( %tky = travel-%tky ) to failed-Travel.

        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg        = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                                   severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) to reported-Travel.

      elseif not line_exists( valid_customers[ customer_id = travel-CustomerID ] ).

        append value #( %tky = travel-%tky ) to failed-Travel.

        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg        = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>customer_unkown
                                                                   severity = if_abap_behv_message=>severity-error
                                                                   customer_id = travel-CustomerID )
                        %element-CustomerID = if_abap_behv=>mk-on ) to reported-Travel.

      endif.

    endloop.

  endmethod.

  method validateDates.
  endmethod.

endclass.
