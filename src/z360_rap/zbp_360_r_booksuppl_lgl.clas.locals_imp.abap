class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for BookingSupplement result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for BookingSupplement result result.

    methods calculateTotalPrice for determine on save
      importing keys for BookingSupplement~calculateTotalPrice.

    methods setBookingSupplNumber for determine on save
      importing keys for BookingSupplement~setBookingSupplNumber.

    methods validateCurrency for validate on save
      importing keys for BookingSupplement~validateCurrency.

    methods validatePrice for validate on save
      importing keys for BookingSupplement~validatePrice.

    methods validateSupplement for validate on save
      importing keys for BookingSupplement~validateSupplement.

endclass.

class lhc_BookingSupplement implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method calculateTotalPrice.
  endmethod.

  method setBookingSupplNumber.
  endmethod.

  method validateCurrency.
  endmethod.

  method validatePrice.
  endmethod.

  method validateSupplement.
  endmethod.

endclass.
