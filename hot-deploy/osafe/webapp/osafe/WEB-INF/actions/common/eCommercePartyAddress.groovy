package common;

import org.ofbiz.base.util.UtilMisc;
import org.ofbiz.base.util.UtilValidate;
import javolution.util.FastList;
import org.ofbiz.entity.GenericValue;
import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.party.contact.ContactHelper;

cart = session.getAttribute("shoppingCart");
party = userLogin.getRelatedOneCache("Party");
partyId = party.partyId;
context.party = party;

shippingContactMechList = FastList.newInstance();
billingContactMechList = FastList.newInstance();
addressContactMechList = FastList.newInstance();
if (UtilValidate.isNotEmpty(party))
{
	partyContactMechPurpose = party.getRelatedCache("PartyContactMechPurpose");
	partyContactMechPurpose = EntityUtil.filterByDate(partyContactMechPurpose,true);

	// This should return the current billing address
	partyBillingLocations = EntityUtil.filterByAnd(partyContactMechPurpose, UtilMisc.toMap("contactMechPurposeTypeId", "BILLING_LOCATION"));
	partyBillingLocations = EntityUtil.getRelatedCache("PartyContactMech", partyBillingLocations);
	partyBillingLocations = EntityUtil.filterByDate(partyBillingLocations,true);
	partyBillingLocations = EntityUtil.orderBy(partyBillingLocations, UtilMisc.toList("fromDate DESC"));
    if (UtilValidate.isNotEmpty(partyBillingLocations)) 
    {
        billingContactMechList = EntityUtil.getRelated("ContactMech",partyBillingLocations);
        addressContactMechList.addAll(billingContactMechList);
        billingAddressContactMech = EntityUtil.getFirst(billingContactMechList);
        if (UtilValidate.isNotEmpty(billingAddressContactMech)) 
        {
            billingPostalAddress = delegator.findOne("PostalAddress", [contactMechId : billingAddressContactMech.contactMechId], true);
            context.BILLINGPostalAddress = billingPostalAddress;
            context.firstBillingContactMechId=billingAddressContactMech.contactMechId;
        }
        
    }
	
    partyShippingLocations = EntityUtil.filterByAnd(partyContactMechPurpose, UtilMisc.toMap("contactMechPurposeTypeId", "SHIPPING_LOCATION"));
    partyShippingLocations = EntityUtil.getRelatedCache("PartyContactMech", partyShippingLocations);
    partyShippingLocations = EntityUtil.filterByDate(partyShippingLocations,true);
    partyShippingLocations = EntityUtil.orderBy(partyShippingLocations, UtilMisc.toList("fromDate DESC"));
    if (UtilValidate.isNotEmpty(partyShippingLocations)) 
    {
        shippingContactMechList=EntityUtil.getRelated("ContactMech",partyShippingLocations);
        addressContactMechList.addAll(shippingContactMechList);
        shippingAddressContactMech = EntityUtil.getFirst(shippingContactMechList);
        if (UtilValidate.isNotEmpty(shippingAddressContactMech)) 
        {
            shippingPostalAddress = delegator.findOne("PostalAddress", [contactMechId : shippingAddressContactMech.contactMechId], true);
            context.SHIPPINGPostalAddress = shippingPostalAddress;
        }
    }
    
}



context.shoppingCart = cart;
context.addressContactMechList = addressContactMechList;

