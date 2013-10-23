<!-- start orderItemShippingInfo.ftl -->
<div class="infoRow firstRow">
   <div class="infoEntry">
     <div class="infoCaption">
      <label>${uiLabelMap.ShipDateCaption}</label>
     </div>
     <#if orderItemShipDate?has_content>
          <#assign orderItemShipDate = orderItemShipDate?string(preferredDateFormat)!""/>
      </#if>
     <div class="infoValue medium">
       <#if orderItemShipDate?has_content>${orderItemShipDate!""}</#if>
     </div>
     <div class="infoCaption">
      <label>${uiLabelMap.CarrierCaption}</label>
     </div>
     <div class="infoValue">
     	<span><#if orderItemCarrier?has_content>${orderItemCarrier!}</#if></span>
     </div>
   </div>
</div>

<div class="infoRow firstRow">
   <div class="infoEntry">
     <div class="infoCaption">
      <label>${uiLabelMap.TrackingNoCaption}</label>
     </div>
     <div class="infoValue medium">
       <#if orderItemTrackingNo?has_content><p>${orderItemTrackingNo!""}</p></#if>
       <#--
       <a href="<@ofbizUrl>orderShipmentDetail?orderId=${parameters.orderId}</@ofbizUrl>"><span class="shipmentDetailIcon"></span></a>
       -->
       <#if trackingURL?has_content><a href="JavaScript:newPopupWindow('${trackingURL!""}');" ><span class="shipmentDetailIcon"></span></a></#if>
     </div>
   </div>
</div>

<!-- end orderItemShippingInfo.ftl -->


