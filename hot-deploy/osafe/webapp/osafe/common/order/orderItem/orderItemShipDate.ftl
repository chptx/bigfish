<li class="${request.getAttribute("attributeClass")!}">
   <div>
    <#if shpDate?exists && shipDate?has_content>
	      <label>${uiLabelMap.ShipDateCaption}</label>
	      <span>${(Static["com.osafe.util.Util"].convertDateTimeFormat(shipDate, FORMAT_DATE))!"N/A"}</span>
	</#if>
   </div>
</li>