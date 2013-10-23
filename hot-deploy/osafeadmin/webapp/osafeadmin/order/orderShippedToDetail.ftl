<div class="boxBody">
    <div class="heading">${orderShippedToInfoHeading!}</div>
    <div class="infoRow row">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipToCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderShipment?has_content>${orderShipment.partyIdTo!""}</#if>
            </div>
        </div>
    </div>
    
    <#assign orderContactMechs = Static["org.ofbiz.party.contact.ContactMechWorker"].getOrderContactMechValueMaps(delegator, orderHeader.get("orderId"))>
    <#list orderContactMechs as orderContactMechValueMap>
        <#assign contactMech = orderContactMechValueMap.contactMech>
        <#assign contactMechPurpose = orderContactMechValueMap.contactMechPurposeType>
        <#if contactMechPurpose.contactMechPurposeTypeId == "BILLING_LOCATION" || (contactMechPurpose.contactMechPurposeTypeId == "SHIPPING_LOCATION" && (!isStorePickup?has_content || isStorePickup != "Y"))>
            <#if contactMech.contactMechTypeId == "POSTAL_ADDRESS">
                <#if contactMechPurpose.contactMechPurposeTypeId == "SHIPPING_LOCATION">
                    <div class="infoRow row">
                        <div class="infoEntry">
                            <div class="infoCaption">
                                <label>${uiLabelMap.AddressCaption}</label>
                            </div>
                            <div class="infoValue">
                                <#assign postalAddress = orderContactMechValueMap.postalAddress />
                                <#if postalAddress?has_content>
                                    <#if postalAddress.toName?has_content>${postalAddress.toName}</br></#if>
                                    ${postalAddress.address1}</br>
                                    <#if postalAddress.address2?has_content>${postalAddress.address2}</br></#if>
                                    ${postalAddress.city?if_exists}<#if postalAddress.stateProvinceGeoId?has_content && postalAddress.stateProvinceGeoId != '_NA_'>, ${postalAddress.stateProvinceGeoId} </#if>
                                    ${postalAddress.postalCode?if_exists}</br>
                                    ${postalAddress.countryGeoId?if_exists}</br>
                                </#if>
                            </div>
                        </div>
                    </div>
                </#if>
            </#if>
        </#if>
    </#list>
</div>

