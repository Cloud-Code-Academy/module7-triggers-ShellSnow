trigger AccountTrigger on Account (before insert) {
    if (Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            // Set the account type to 'Prospect' if it's blank
            if (String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }
            // Copy the shipping address to the billing address
            if (!String.isBlank(acc.ShippingStreet)) {
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }
            // Set the account rating to 'Hot' if Phone, Website, and Fax all have values
            if (!String.isBlank(acc.Phone) && !String.isBlank(acc.Website) && !String.isBlank(acc.Fax)) {
                acc.Rating = 'Hot';
            }
        }
    }
}
}
