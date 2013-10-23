<div class="boxBody">
    <div class="heading">${orderShippingDetailsInfoHeading!}</div>
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipmentNoCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderShipment?has_content>${orderShipment.shipmentId!""}</#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.StatusCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderShipment?has_content>
                    <#assign statusItem = orderShipment.getRelatedOne("StatusItem")?if_exists />
                </#if>
                <#if statusItem?has_content>${statusItem.description!""}</#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipmentTypeCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderShipment?has_content>
                    <#assign shipmentType = orderShipment.getRelatedOne("ShipmentType")?if_exists />
                </#if>
                <#if shipmentType?has_content>${shipmentType.description!""}</#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipDateCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderItemShipGroup?has_content>
                    ${(orderItemShipGroup.estimatedShipDate?string(preferredDateFormat))!""}
                </#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipMethodCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderItemShipGroup?has_content>
                    <#assign shipmentMethodType = orderItemShipGroup.getRelatedOne("ShipmentMethodType")?if_exists>
                    <#if orderItemShipGroup.carrierPartyId?has_content>
		                <#assign carrier =  delegator.findByPrimaryKey("PartyGroup", Static["org.ofbiz.base.util.UtilMisc"].toMap("partyId", orderItemShipGroup.carrierPartyId))?if_exists />
		                <#if carrier?has_content>${carrier.groupName?default(carrier.partyId)!}&nbsp;</#if>
		            </#if>
		            ${shipmentMethodType.get("description","OSafeAdminUiLabels",locale)?default("")}
                </#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.TrackingNoCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderItemShipGroup?has_content>
                    ${orderItemShipGroup.trackingNumber!""}
                </#if>
            </div>
            <div class="infoIcon">
                <#if orderItemShipGroup?has_content && orderItemShipGroup.carrierPartyId != "_NA_" && orderItemShipGroup.trackingNumber?has_content>
                    <#assign trackingURLPartyContents = delegator.findByAnd("PartyContent", {"partyId": orderItemShipGroup.carrierPartyId, "partyContentTypeId": "TRACKING_URL"})/>
                    <#if trackingURLPartyContents?has_content>
                        <#assign trackingURLPartyContent = Static["org.ofbiz.entity.util.EntityUtil"].getFirst(trackingURLPartyContents)/>
                        <#if trackingURLPartyContent?has_content>
                            <#assign content = trackingURLPartyContent.getRelatedOne("Content")/>
                            <#if content?has_content>
                                <#assign dataResource = content.getRelatedOne("DataResource")!""/>
                                <#if dataResource?has_content>
                                    <#assign electronicText = dataResource.getRelatedOne("ElectronicText")!""/>
                                    <#assign trackingURL = electronicText.textData!""/>
                                    <#if trackingURL?has_content>
                                        <#assign trackingURL = Static["org.ofbiz.base.util.string.FlexibleStringExpander"].expandString(trackingURL, {"TRACKING_NUMBER":orderItemShipGroup.trackingNumber})/>
                                    </#if>
                                </#if>
                            </#if>
                        </#if>
                    </#if>
                </#if>
                <#if trackingURL?has_content>
                    <a href="JavaScript:newPopupWindow('${trackingURL!""}');" onMouseover="javascript:showTooltip(event,'${uiLabelMap.ShowTrackingInfo}');" onMouseout="hideTooltip()"><span class="shipmentDetailIcon"></span></a>
                </#if>
            </div>
            <div class="infoIcon">
                <a href="JavaScript:newPopupWindow('<@ofbizUrl>ShippingLabel.pdf?shipmentId=${orderShipment.shipmentId}</@ofbizUrl>','popUpWindow','height=500,width=600,left=400,top=200,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes');" onMouseover="javascript:showTooltip(event,'${uiLabelMap.GenerateShippingLabelInfo}');" onMouseout="hideTooltip()"><span class="shippingLabelPrintIcon"></span></a>
            </div>
        </div>
    </div>
    
    <div class="infoRow row">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.ShipInstructionsCaption}</label>
            </div>
            <div class="infoValue">
                <#if orderItemShipGroup?has_content>
                    ${orderItemShipGroup.shippingInstructions!""}
                </#if>
            </div>
        </div>
    </div>
</div>

